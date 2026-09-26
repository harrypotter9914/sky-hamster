$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=[IO.Path]::GetFullPath((Join-Path $root '../..'))
$qa=Join-Path $repo 'builds/loading-review-source'
New-Item -ItemType Directory -Path $qa -Force | Out-Null
Copy-Item -LiteralPath "$root/source/loading.lua","$root/source/ui-mascot.png" -Destination $qa -Force
Copy-Item -LiteralPath "$root/source/loading" -Destination $qa -Recurse -Force
Copy-Item -LiteralPath "$root/source/fonts" -Destination $qa -Recurse -Force
Copy-Item -LiteralPath "$PSScriptRoot/loading_review.lua" -Destination "$qa/main.lua" -Force
"name=Loading Review`nbundleID=com.wangyibo.skyhamster.loading-review`nversion=0.10.4" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa (Join-Path $repo 'builds/loading-review.pdx')
if($LASTEXITCODE -ne 0){throw 'Loading review build failed'}
