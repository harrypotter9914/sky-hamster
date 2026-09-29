param()
$ErrorActionPreference='Stop'
& "$PSScriptRoot/art/check-bake.ps1"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
$out=Join-Path $PSScriptRoot '../../builds/sky-hamster-tilt.pdx'
& "$sdk/bin/pdc.exe" -sdkpath $sdk "$PSScriptRoot/source" $out
if($LASTEXITCODE -ne 0){throw 'Build failed'}
Write-Output $out
