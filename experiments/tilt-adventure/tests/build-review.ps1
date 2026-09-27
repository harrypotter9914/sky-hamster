# Isolated SDK visual review bundle. No review hooks enter the shipping source.
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=Resolve-Path (Join-Path $root '../..')
$qa=Join-Path $repo 'builds/tilt-ui-qa-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
@'
function Structures.reviewArt()
 local out={};for name,frames in pairs(rotorTables) do out[name]=frames:getLength() end;return out
end
'@ | Add-Content "$qa/structures.lua"
@"
Review={select=function(n) selectLevel(n);while Loading.busy do Loading.step(1/30) end end,render=renderWorld,animate=function(t,crank)
 worldTime=t;MachineArt.time=t
 if crank then Dock.update(course,x,y,0,0,false,crank,false,false);ballHeight=floorAt(x,y) end
 for _,m in ipairs(course.mechanisms or {}) do if m.kind=='bumper' then m.hitAt=0 end end
end,place=function(a,b)
 x=a;y=b;ballHeight=floorAt(x,y);jumpZ=ballHeight
 Dock.update(course,x,y,0,0,false,0,false,false)
end}
"@ | Add-Content "$qa/game.lua"
Copy-Item "$PSScriptRoot/ui_review.lua" "$qa/main.lua"
$releaseInfo=Get-Content "$root/source/pdxinfo" -Raw
$releaseVersion=[regex]::Match($releaseInfo,'(?m)^version=([^\r\n]+)').Groups[1].Value
"name=Tilt UI Review`nbundleID=com.wangyibo.skyhamster.ui-review`nversion=$releaseVersion" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa (Join-Path $repo 'builds/tilt-ui-qa.pdx')
if($LASTEXITCODE -ne 0){throw 'Review build failed'}
