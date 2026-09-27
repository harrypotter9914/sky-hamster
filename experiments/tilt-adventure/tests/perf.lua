-- Automated device workload, not a substitute for physical grip playtesting.
local writeReport=playdate.datastore.write
local results={device=false,stages={}}
playdate.datastore.read=function() return nil end
playdate.datastore.write=function() end
playdate.readAccelerometer=function() return 0,0,1 end
playdate.buttonJustPressed=function() return false end
playdate.buttonIsPressed=function() return false end
playdate.getCrankChange=function() return 0 end
PerfLayers={values={}}
function PerfLayers.wrap(label)
 local f=Mechanisms.draw
 Mechanisms.draw=function(...)
  local t=playdate.getCurrentTimeMilliseconds();f(...)
  PerfLayers.values[label]=(PerfLayers.values[label] or 0)+playdate.getCurrentTimeMilliseconds()-t
 end
end
import 'game'
local update=playdate.update
local stages={14,19,24,30,34,36,40,44}
local smooth=Bench.smooth
if smooth then stages={30,44,44,44,44,44,44,44} end
local anchors={{96,112},{48,80},{480,80},{1264,80},{1752,112},{2128,112},{4800,112},{5600,240}}
if Bench.profile then smooth=true;stages={44};anchors={{2128,112}} end
if Bench.joins then stages={11,12,17,19,22,26} end
results.mode=smooth and '90-units-per-second camera samples' or 'full-route camera/cache stress'
if Bench.joins then results.mode='moving dock, lift and aiming animation samples' end
local stage,frame=0,0
local samples,costs={},{}
local now=playdate.getCurrentTimeMilliseconds
local profile={}
if Bench.profile then
 for _,spec in ipairs({{MechanismAudio,'update','machineAudio'},{Audio,'update','ballAudio'},{Mechanisms,'support','support'},{Mechanisms,'collide','collide'},{Mechanisms,'wind','wind'},{Mechanisms,'draw','machines'},{Spatial,'occluders','occluders'},{Spatial,'maskPolygon','mask'},{Spatial,'sides','sides'},{Terrain,'draw','terrain'},{Dock,'draw','stations'},{UI,'hud','hud'},{Tilt,'update','tilt'},{DepthOrder,'roads','roadCover'},{Structures,'drawTop','structureTop'},{Structures,'drawUnder','structureUnder'}}) do
  local owner,key,label=spec[1],spec[2],spec[3];local f=owner[key]
  owner[key]=function(...) local t=now();local a,b,c,d,e=f(...);profile[label]=(profile[label] or 0)+now()-t;return a,b,c,d,e end
 end
end
local start,last=now(),nil
local function report()
 if #samples==0 then return end
 table.sort(samples);table.sort(costs)
 local total=0;for _,v in ipairs(samples) do total=total+v end
 local misses,count=Bench.cache()
 print(string.format('BENCH route=%d frames=%d fps=%.2f frame95=%.2f frameMax=%.2f cpu95=%.2f cpuMax=%.2f cacheMiss=%d chunks=%d luaKB=%.0f',stages[stage],#samples,1000*#samples/total,samples[math.ceil(#samples*.95)],samples[#samples],costs[math.ceil(#costs*.95)],costs[#costs],misses,count,collectgarbage('count')))
 local stats=playdate.getStats();if stats then print('STATS',stats) end
 results.device=stats~=nil
 if Bench.profile then
  for key,value in pairs(profile) do print('PROFILE',key,value/#costs) end;profile={}
  for key,value in pairs(PerfLayers.values) do print('LAYER',key,value/#costs) end
 end
 results.stages[#results.stages+1]={route=stages[stage],frames=#samples,fps=1000*#samples/total,frame95=samples[math.ceil(#samples*.95)],frameMax=samples[#samples],cpu95=costs[math.ceil(#costs*.95)],cpuMax=costs[#costs],cacheMiss=misses,chunks=count,luaKB=collectgarbage('count')}
 writeReport(results,'tilt-perf-report')
end
function playdate.update()
 if now()-start<4500 then playdate.graphics.clear(playdate.graphics.kColorWhite);playdate.graphics.drawText('Hardware workload starting...',30,100);return end
 if stage==0 or frame>=180 then
  report();stage=stage+1;frame=0;samples={};costs={};last=nil
  if stage>#stages then results.complete=true;writeReport(results,'tilt-perf-report');print('BENCH COMPLETE');playdate.update=function() playdate.graphics.clear(playdate.graphics.kColorWhite);playdate.graphics.drawText('Hardware check complete.',35,100) end;return end
  Bench.select(stages[stage]);profile={};PerfLayers.values={};print('BENCH BEGIN',stages[stage])
 end
 local c=Courses[stages[stage]]
 -- Traverse the sorted road tiles in batches; this deliberately stresses camera/cache misses.
 local tile=c.tiles[math.min(#c.tiles,1+math.floor(frame/180*(#c.tiles-1)))]
 if Bench.joins then Bench.joinSample(stages[stage],frame)
 elseif smooth then Bench.place(anchors[stage][1]+frame*3,anchors[stage][2]) else Bench.place(tile.x*32+16,tile.y*32+16) end
 local t=now();if last then samples[#samples+1]=t-last end;last=t
 update();costs[#costs+1]=now()-t;frame=frame+1
end
local workload=playdate.update
function playdate.update()
 local ok,err=pcall(workload)
 if not ok then
  results.error=tostring(err);writeReport(results,'tilt-perf-report');print('BENCH ERROR',err)
  playdate.update=function() playdate.graphics.drawText('Workload error; see report.',20,100) end
 end
end
