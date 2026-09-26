# Same installation folder as the release; restore the release after measuring.
param([switch]$Smooth,[switch]$Profile)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=Resolve-Path (Join-Path $root '../..')
$qa=Join-Path $repo 'builds/tilt-perf-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
@'
Bench={select=function(n)
 selectLevel(n);while Loading.busy do Loading.step(1/30) end;lesson=false;title=false;for i=1,60 do Tilt.update(1/30) end
end,place=function(a,b)
 x=a;y=b;ballHeight=floorAt(x,y);jumpZ=ballHeight;airborne=false;state='play';vx=90;vy=0;Dock.active=nil;Dock.blocked=nil
end,cache=function() return terrainChunks and terrainChunks.misses or 0,terrainChunks and terrainChunks.count or 0 end}
'@ | Add-Content "$qa/game.lua"
if($Smooth){'Bench.smooth=true' | Add-Content "$qa/game.lua"}
if($Profile){'Bench.profile=true' | Add-Content "$qa/game.lua"}
if($Profile){foreach($module in @('mechanism_cache','expansion','workshop','machine_art')){"PerfLayers.wrap('$module')" | Add-Content "$qa/$module.lua"}}
Copy-Item "$PSScriptRoot/perf.lua" "$qa/main.lua"
$out=Join-Path $repo 'builds/tilt-perf/sky-hamster-tilt.pdx'
New-Item -ItemType Directory -Force (Split-Path $out -Parent) | Out-Null
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa $out
if($LASTEXITCODE -ne 0){throw 'Performance build failed'}
