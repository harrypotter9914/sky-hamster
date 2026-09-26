# Isolated SDK visual review bundle. No review hooks enter the shipping source.
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=Resolve-Path (Join-Path $root '../..')
$qa=Join-Path $repo 'builds/tilt-ui-qa-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/main.lua" "$qa/game.lua"
@"
Review={select=selectLevel,render=renderWorld,place=function(a,b)
 x=a;y=b;ballHeight=course:height(x,y);jumpZ=ballHeight
 Dock.update(course,x,y,0,0,false,0,false,false)
end}
"@ | Add-Content "$qa/game.lua"
Copy-Item "$PSScriptRoot/ui_review.lua" "$qa/main.lua"
"name=Tilt UI Review`nbundleID=com.wangyibo.skyhamster.ui-review`nversion=0.1.2" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa (Join-Path $repo 'builds/tilt-ui-qa.pdx')
if($LASTEXITCODE -ne 0){throw 'Review build failed'}
