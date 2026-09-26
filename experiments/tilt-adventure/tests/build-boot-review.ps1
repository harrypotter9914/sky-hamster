$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=[IO.Path]::GetFullPath((Join-Path $root '../..'))
$qa=Join-Path $repo 'builds/boot-review-source'
New-Item -ItemType Directory -Path $qa -Force | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/main.lua" "$qa/bootstrap.lua" -Force
'ReviewLoadCourse=selectLevel' | Add-Content "$qa/engine.lua"
Copy-Item "$PSScriptRoot/boot_review.lua" "$qa/main.lua" -Force
"name=Boot Review`nbundleID=com.wangyibo.skyhamster.boot-review`nversion=0.10.4" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa (Join-Path $repo 'builds/boot-review.pdx')
if($LASTEXITCODE -ne 0){throw 'Boot review build failed'}
