# Persistent, bounded USB console session. Screens are binary; never print them.
param([string]$Port='COM4',[string[]]$Commands=@(),[string]$Output,[int]$Seconds=8,[switch]$Screen)
$ErrorActionPreference='Stop'
$connection=[IO.Ports.SerialPort]::new($Port,115200)
$connection.DtrEnable=$true
$capture=[IO.MemoryStream]::new()
try {
 $connection.Open();$connection.DiscardInBuffer()
 foreach($command in $Commands){$connection.Write($command+"`n")}
 $timer=[Diagnostics.Stopwatch]::StartNew();$buffer=[byte[]]::new(32768)
 while($timer.Elapsed.TotalSeconds -lt $Seconds){
  if($connection.BytesToRead -gt 0){
   $count=$connection.Read($buffer,0,[Math]::Min($buffer.Length,$connection.BytesToRead))
   $capture.Write($buffer,0,$count)
  } else {Start-Sleep -Milliseconds 10}
 }
 $bytes=$capture.ToArray()
 if($Output){[IO.File]::WriteAllBytes([IO.Path]::GetFullPath($Output),$bytes);Write-Output "Captured $($bytes.Length) bytes: $Output"}
 elseif(-not $Screen){[Text.Encoding]::UTF8.GetString($bytes)}
 else {Write-Output "Screen capture $($bytes.Length) bytes (Output required to save)"}
} finally {$connection.Close();$connection.Dispose();$capture.Dispose()}
