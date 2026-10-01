$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
& "$root/art/check-bake.ps1"
$repo=[IO.Path]::GetFullPath((Join-Path $root '../..'))
$qa=Join-Path $repo 'builds/tilt-playtest-review-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
@'
Review={begin=function(n) selectLevel(n) end,render=function() lesson=false;title=false;renderWorld() end}
'@ | Add-Content "$qa/game.lua"
Copy-Item "$PSScriptRoot/playtest_review.lua" "$qa/main.lua"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa "$repo/builds/tilt-perf/sky-hamster-tilt.pdx"
if($LASTEXITCODE -ne 0){throw 'Device visual review build failed'}
