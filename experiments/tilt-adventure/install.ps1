# Always replace the one current installation; versioned archives stay on the PC.
param()
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'build.ps1')
if($LASTEXITCODE -ne 0){throw 'Build failed'}
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
$package=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../builds/sky-hamster-tilt.pdx'))
& "$sdk/bin/pdutil.exe" install $package
if($LASTEXITCODE -ne 0){throw 'Device installation failed'}
# USB storage ejection briefly removes the serial device while it reconnects.
$started=$false
for($attempt=0;$attempt -lt 10;$attempt++){
 if($attempt -gt 0){Start-Sleep -Milliseconds 750}
 & "$sdk/bin/pdutil.exe" run '/Games/sky-hamster-tilt.pdx'
 if($LASTEXITCODE -eq 0){$started=$true;break}
}
if(-not $started){throw 'Installed successfully, but device did not reconnect for launch'}
