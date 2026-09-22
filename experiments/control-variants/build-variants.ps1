$ErrorActionPreference = 'Stop'
$sdk = if ($env:PLAYDATE_SDK_PATH) { $env:PLAYDATE_SDK_PATH } else { 'C:/Users/12063/Documents/PlaydateSDK' }
$rules = @('speed','throttle','brake','direct','latch','reverse','track','lock')
$out = Join-Path $PSScriptRoot 'builds/variants'
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($rule in $rules) {
    $stage = Join-Path $PSScriptRoot "builds/stage/$rule"
    New-Item -ItemType Directory -Force $stage | Out-Null
    Copy-Item "$PSScriptRoot/source/*.lua" $stage
    Copy-Item "$PSScriptRoot/variants/$rule/build.lua","$PSScriptRoot/variants/$rule/pdxinfo" $stage
    & "$sdk/bin/pdc.exe" -sdkpath $sdk $stage "$out/sky-hamster-$rule.pdx"
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $rule" }
}
Write-Output "Eight games: $out"
