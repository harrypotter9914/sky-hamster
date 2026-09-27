# Firmware USB console; do not use while another capture owns the serial port.
param([string]$Port='COM4',[Parameter(Mandatory=$true)][string]$Command,[string]$Output)
$ErrorActionPreference='Stop'
$pdPort=[IO.Ports.SerialPort]::new($Port,115200)
$pdPort.DtrEnable=$true
$capture=[IO.MemoryStream]::new()
try {
 $pdPort.Open();$pdPort.DiscardInBuffer();$pdPort.Write($Command+"`n")
 $watch=[Diagnostics.Stopwatch]::StartNew();$last=0
 $buffer=[byte[]]::new(16384)
 while($watch.Elapsed.TotalSeconds -lt 5){
  if($pdPort.BytesToRead -gt 0){
   $n=$pdPort.Read($buffer,0,[Math]::Min($buffer.Length,$pdPort.BytesToRead))
   $capture.Write($buffer,0,$n);$last=$watch.ElapsedMilliseconds
  } elseif($capture.Length -gt 0 -and $watch.ElapsedMilliseconds-$last -gt 500){break}
  Start-Sleep -Milliseconds 25
 }
 $bytes=$capture.ToArray()
 if($Output){[IO.File]::WriteAllBytes([IO.Path]::GetFullPath($Output),$bytes);Write-Output "Captured $($bytes.Length) bytes"}
 else {[Text.Encoding]::UTF8.GetString($bytes)}
} finally {$pdPort.Close();$pdPort.Dispose();$capture.Dispose()}
