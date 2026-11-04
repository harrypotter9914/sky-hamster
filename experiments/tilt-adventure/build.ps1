param()
$ErrorActionPreference='Stop'
& "$PSScriptRoot/art/check-bake.ps1"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{Join-Path $env:USERPROFILE 'Documents/PlaydateSDK'}
if(-not (Test-Path -LiteralPath "$sdk/bin/pdc.exe")){throw 'Set PLAYDATE_SDK_PATH to the installed Playdate SDK directory.'}
$out=Join-Path $PSScriptRoot '../../builds/sky-hamster-tilt.pdx'
New-Item -ItemType Directory -Path (Split-Path $out -Parent) -Force | Out-Null
& "$sdk/bin/pdc.exe" -sdkpath $sdk "$PSScriptRoot/source" $out
if($LASTEXITCODE -ne 0){throw 'Build failed'}
Write-Output $out
