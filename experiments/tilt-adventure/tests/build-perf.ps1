# Same installation folder as the release; restore the release after measuring.
param([switch]$Smooth,[switch]$Profile,[switch]$AudioAudit,[switch]$Joins,[switch]$All,[int[]]$Routes=@(),[int[]]$MechanismIndices=@())
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=Resolve-Path (Join-Path $root '../..')
$qa=Join-Path $repo 'builds/tilt-perf-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
@'
Bench={select=function(n) selectLevel(n) end,ready=function()
 lesson=false;title=false;for i=1,60 do Tilt.update(1/30) end
end,place=function(a,b)
 x=a;y=b;ballHeight=floorAt(x,y);jumpZ=ballHeight;airborne=false;state='play';vx=90;vy=0;Dock.active=nil;Dock.blocked=nil
end,cache=function() return terrainChunks and terrainChunks.misses or 0,terrainChunks and terrainChunks.count or 0 end}
'@ | Add-Content "$qa/game.lua"
if($Smooth){'Bench.smooth=true' | Add-Content "$qa/game.lua"}
if($Routes.Count){("Bench.routes={"+($Routes -join ',')+"}") | Add-Content "$qa/game.lua"}
if($MechanismIndices.Count){("Bench.mechanismIndices={"+($MechanismIndices -join ',')+"}") | Add-Content "$qa/game.lua"}
if($All){
 @'
Bench.all=true
Bench.sample=function(spec,frame)
 local c=Courses[spec.route]
 local u=(1-math.cos(frame/120*math.pi*2))/2
 Bench.crank=0
 Dock.active=nil;Dock.blocked=nil
 if spec.kind=='road' then
  local tile=c.tiles[math.min(#c.tiles,1+math.floor(frame/180*(#c.tiles-1)))]
  x,y=tile.x*32+16,tile.y*32+16;vx,vy=70,20
 elseif spec.kind=='normal' then
  local tile=c.tiles[math.max(1,math.floor(#c.tiles*spec.fraction))]
  x,y=tile.x*32+16+frame*.6,tile.y*32+16;vx,vy=70,0
 else
  local m=spec.kind=='pad' and c.pads[spec.index] or c.mechanisms[spec.index]
  if spec.kind=='pad' then
   if m.kind=='cannon' then m.angle=-math.pi/3+u*math.pi*2/3 end
   x,y=m.x,m.y;Dock.active=m
   Bench.crank=6*math.cos(frame/120*math.pi*2)
  else
   if m.kind=='lift' then m.elevation=m.minHeight+u*(m.maxHeight-m.minHeight)
   elseif m.manual and m.kind=='ferry' then m.progress=u
   elseif m.manual and not m.retract then m.angle=u*math.pi end
   x,y=Mechanisms.pose(m,worldTime)
  end
  vx,vy=0,0
 end
 ballHeight=floorAt(x,y);jumpZ=ballHeight;airborne=false;state='play'
end
'@ | Add-Content "$qa/game.lua"
}
if($Joins){
 @'
Bench.joins=true
Bench.joinSample=function(n,frame)
 local c=Courses[n];local m=c.mechanisms and c.mechanisms[1];local u=(1-math.cos(frame/180*math.pi*2))/2
 worldTime=frame/30+2.4
 local p=c.pads and c.pads[1]
 Dock.active=nil;Dock.blocked=p
 if n==26 then p.angle=-math.pi/3+u*math.pi*2/3;x=p.x;y=p.y;Dock.active=p
 else
  if m.kind=='lift' then m.elevation=m.minHeight+u*(m.maxHeight-m.minHeight)
  elseif m.manual and m.kind=='ferry' then m.progress=u
  elseif m.manual then m.angle=u*math.pi end
  x,y=Mechanisms.pose(m,worldTime)
 end
 ballHeight=floorAt(x,y);jumpZ=ballHeight;airborne=false;state='play';vx=0;vy=0
end
'@ | Add-Content "$qa/game.lua"
}
if($Profile){'Bench.profile=true' | Add-Content "$qa/game.lua"}
if($Profile){foreach($module in @('mechanism_cache','expansion','workshop','machine_art')){"PerfLayers.wrap('$module')" | Add-Content "$qa/$module.lua"}}
Copy-Item "$PSScriptRoot/perf.lua" "$qa/main.lua"
if($AudioAudit){
 $code=Get-Content -LiteralPath "$qa/main.lua" -Raw
 ("AudioAuditWrite=playdate.datastore.write`n"+$code+"`nimport 'audio_device'`n") | Set-Content "$qa/main.lua"
 Copy-Item "$PSScriptRoot/audio_device.lua" "$qa/audio_device.lua"
}
$out=Join-Path $repo 'builds/tilt-perf/sky-hamster-tilt.pdx'
New-Item -ItemType Directory -Force (Split-Path $out -Parent) | Out-Null
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa $out
if($LASTEXITCODE -ne 0){throw 'Performance build failed'}
