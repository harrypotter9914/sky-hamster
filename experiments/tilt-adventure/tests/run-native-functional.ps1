# Capture one phase of the hardware assertion runner. Installation is separate.
param([string]$Port='COM4',[string]$Log='native-functional-v0.12.9.log',[int]$TimeoutSeconds=1800,[switch]$Resume)
$ErrorActionPreference='Stop'
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
$started=$false
for($attempt=0;$attempt -lt 12;$attempt++){
 if($attempt -gt 0){Start-Sleep -Milliseconds 750}
 & "$sdk/bin/pdutil.exe" run '/Games/sky-hamster-tilt.pdx'
 if($LASTEXITCODE -eq 0){$started=$true;break}
}
if(-not $started){throw 'Hardware runner launch failed'}
$connection=[IO.Ports.SerialPort]::new($Port,115200)
$connection.DtrEnable=$true
$writer=[IO.StreamWriter]::new((Join-Path $PSScriptRoot $Log),[bool]$Resume,[Text.UTF8Encoding]::new($false))
$tail='';$done=$false
$expected=if($Resume){'FUNCTION COMPLETE'}else{'FUNCTION RESTART READY'}
try {
 $connection.Open();$watch=[Diagnostics.Stopwatch]::StartNew()
 while($watch.Elapsed.TotalSeconds -lt $TimeoutSeconds){
  $part=$connection.ReadExisting()
  if($part){
   $writer.Write($part);$writer.Flush();Write-Output $part
   $tail+=$part
   if($tail.Contains('FUNCTION ERROR')){throw 'Native assertion failed; inspect retained log'}
   if($tail.Contains($expected)){$done=$true;break}
   if($tail.Length -gt 4096){$tail=$tail.Substring($tail.Length-4096)}
  }
  Start-Sleep -Milliseconds 50
 }
 if(-not $done){throw "Timed out before $expected; partial log retained"}
} finally {$writer.Dispose();$connection.Close();$connection.Dispose()}
