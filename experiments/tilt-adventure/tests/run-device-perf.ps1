param([string]$Log='device-all-v0.10.8.log',[int]$TimeoutSeconds=2400,[switch]$CaptureOnly)
$ErrorActionPreference='Stop'
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
$package=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../builds/tilt-perf/sky-hamster-tilt.pdx'))
Get-Process PlaydateSimulator -ErrorAction SilentlyContinue | Stop-Process
if(-not $CaptureOnly){
& "$sdk/bin/pdutil.exe" install $package
if($LASTEXITCODE -ne 0){throw 'Device installation failed'}
$started=$false
for($attempt=0;$attempt -lt 12;$attempt++){
 if($attempt -gt 0){Start-Sleep -Milliseconds 750}
 & "$sdk/bin/pdutil.exe" run '/Games/sky-hamster-tilt.pdx'
 if($LASTEXITCODE -eq 0){$started=$true;break}
}
if(-not $started){throw 'Installed, but launch failed; restore normal game when reconnected'}
}
$ports=@([IO.Ports.SerialPort]::GetPortNames())
if($ports.Count -ne 1){throw 'Expected one connected serial device; identify Playdate port before capture'}
$pdPort=[IO.Ports.SerialPort]::new($ports[0],115200)
$pdPort.DtrEnable=$true
$path=Join-Path $PSScriptRoot $Log
$writer=[IO.StreamWriter]::new($path,[bool]$CaptureOnly,[Text.UTF8Encoding]::new($false))
$tail='';$done=$false
try {
 $pdPort.Open();$watch=[Diagnostics.Stopwatch]::StartNew()
 while($watch.Elapsed.TotalSeconds -lt $TimeoutSeconds){
  try {$part=$pdPort.ReadExisting()} catch {
   Write-Output 'Serial connection interrupted; retrying capture without restarting the game.'
   $pdPort.Close();$reconnected=$false
   for($retry=0;$retry -lt 30;$retry++){
    Start-Sleep -Milliseconds 1000
    try {$pdPort.Open();$reconnected=$true;break} catch {}
   }
   if(-not $reconnected){throw 'Serial device did not reconnect; partial log retained'}
   continue
  }
  if($part){
   $writer.Write($part);$writer.Flush();Write-Output $part
   $tail+=$part
   if($tail.Contains('BENCH ERROR')){throw 'Device workload reported an error; inspect log'}
   if($tail.Contains('BENCH COMPLETE')){$done=$true;break}
   if($tail.Length -gt 4096){$tail=$tail.Substring($tail.Length-4096)}
  }
  Start-Sleep -Milliseconds 100
 }
 if(-not $done){throw 'Timed out before BENCH COMPLETE; partial log retained'}
} finally {$writer.Dispose();$pdPort.Close();$pdPort.Dispose()}
