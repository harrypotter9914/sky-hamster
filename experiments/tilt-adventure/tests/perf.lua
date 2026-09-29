-- Automated device workload, not a substitute for physical grip playtesting.
-- No physical inputs occur during long unattended workloads. Charging alone
-- does not necessarily disable the firmware's inactivity lock. Normal builds
-- instead use Awake's USB-only policy, restoring auto-lock on battery power.
if playdate.setAutoLockDisabled then playdate.setAutoLockDisabled(true) end
local writeReport=playdate.datastore.write
local results={device=false,stages={}}
local readData=playdate.datastore.read
playdate.datastore.read=function(name) if name~='tilt-progress' then return readData(name) end end
playdate.datastore.write=function() end
playdate.readAccelerometer=function() return 0,0,1 end
playdate.buttonJustPressed=function() return false end
playdate.buttonIsPressed=function() return false end
playdate.getCrankChange=function() return Bench and Bench.crank or 0 end
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
local specs
local function planAll()
 specs={};stages={}
 for n,c in ipairs(Courses) do
  local included=not Bench.routes
  for _,route in ipairs(Bench.routes or {}) do if route==n then included=true end end
  if included then
  if Curriculum then Curriculum.ensure(c) end
  if Bench.travel then
   specs[#specs+1]={route=n,kind='stream',frames=math.ceil((c.goal[1]-c.start[1])/8)*2,name='240-units-per-second'}
  elseif Bench.fields then
   for _,fraction in ipairs({.1,.5,.9}) do specs[#specs+1]={route=n,kind='normal',fraction=fraction,frames=60} end
   for i,m in ipairs(c.mechanisms or {}) do if m.kind=='fan' or m.kind=='magnet' then
    for _,side in ipairs({-1,1}) do specs[#specs+1]={route=n,kind='field',index=i,name=m.kind,side=side,frames=90} end
   end end
   for i,p in ipairs(c.pads or {}) do if p.kind=='fan' then specs[#specs+1]={route=n,kind='pad',index=i,name='fan',frames=90} end end
  elseif Bench.survey then
   for _,fraction in ipairs({.1,.5,.9}) do specs[#specs+1]={route=n,kind='normal',fraction=fraction,frames=60} end
   local count=#(c.mechanisms or {})
   if count>0 then
    local i=math.max(1,math.ceil(count/2));local m=c.mechanisms[i]
    specs[#specs+1]={route=n,kind='mechanism',index=i,name=m.kind,frames=90}
   elseif #(c.pads or {})>0 then
    specs[#specs+1]={route=n,kind='pad',index=1,name=c.pads[1].kind,frames=90}
   end
  else
  specs[#specs+1]={route=n,kind='road',frames=180}
  for _,fraction in ipairs({.1,.5,.9}) do specs[#specs+1]={route=n,kind='normal',fraction=fraction,frames=120} end
  for i,m in ipairs(c.mechanisms or {}) do specs[#specs+1]={route=n,kind='mechanism',index=i,name=m.retract and 'extend' or m.kind,frames=120} end
  for i,p in ipairs(c.pads or {}) do specs[#specs+1]={route=n,kind='pad',index=i,name=p.kind,frames=120} end
  end
  if Curriculum then Curriculum.release(c) end
  collectgarbage('collect')
  end
 end
 if Bench.mechanismIndices then
  local focus={}
  for _,spec in ipairs(specs) do if spec.kind=='mechanism' then
   for _,index in ipairs(Bench.mechanismIndices) do if spec.index==index then focus[#focus+1]=spec;break end end
  end end
  specs=focus
 end
 for _,spec in ipairs(specs) do stages[#stages+1]=spec.route end
 results.mode='all courses: road traversal stress plus each machinery and control station; production update and audio'
 print('BENCH PLAN courses='..#Courses..' scenes='..#specs)
end
local samples,costs={},{}
local now=playdate.getCurrentTimeMilliseconds
local profile={}
if Bench.profile then
 for _,spec in ipairs({{Passage,'draw','passage'},{MechanismAudio,'update','machineAudio'},{Audio,'update','ballAudio'},{Mechanisms,'support','support'},{Mechanisms,'collide','collide'},{Mechanisms,'wind','wind'},{Mechanisms,'draw','machines'},{Spatial,'occluders','occluders'},{Spatial,'maskPolygon','mask'},{Spatial,'sides','sides'},{Terrain,'draw','terrain'},{Dock,'draw','stations'},{UI,'hud','hud'},{Tilt,'update','tilt'},{DepthOrder,'roads','roadCover'},{Structures,'drawTop','structureTop'},{Structures,'drawUnder','structureUnder'}}) do
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
 local stats=playdate.getStats();if stats then
  local values={};for key,value in pairs(stats) do values[#values+1]=key..'='..tostring(value) end
  table.sort(values);print('STATS',table.concat(values,' '))
 end
 results.device=stats~=nil
 if Bench.profile then
  for key,value in pairs(profile) do print('PROFILE',key,value/#costs) end;profile={}
  for key,value in pairs(PerfLayers.values) do print('LAYER',key,value/#costs) end
 end
 results.stages[#results.stages+1]={route=stages[stage],frames=#samples,fps=1000*#samples/total,frame95=samples[math.ceil(#samples*.95)],frameMax=samples[#samples],cpu95=costs[math.ceil(#costs*.95)],cpuMax=costs[#costs],cacheMiss=misses,chunks=count,luaKB=collectgarbage('count')}
 if specs then results.stages[#results.stages].scenario=specs[stage] end
 writeReport(results,'tilt-perf-report')
end
local preparing=false
local loadLabel
local loadStart,loadMax
local loadWork={}
Loading.traceSlice=function(label,ms)
 local row=loadWork[label] or {total=0,max=0,count=0};loadWork[label]=row
 row.total=row.total+ms;row.max=math.max(row.max,ms);row.count=row.count+1
end
local planning=false
local function beginScene()
 profile={};PerfLayers.values={};print('BENCH BEGIN',stages[stage])
 if specs then print('SCENE',stage,specs[stage].kind,specs[stage].index or 0,specs[stage].name or 'traverse') end
end
function playdate.update()
 if now()-start<4500 then playdate.graphics.clear(playdate.graphics.kColorWhite);playdate.graphics.drawText('Hardware workload starting...',30,100);return end
 if planning then
  Loading.step(1/30)
  if not Loading.busy then planning=false;collectgarbage('collect') end
  return
 end
 if Bench.all and not specs then
  Loading.begin(planAll,'PLANNING THE BENCHMARK');planning=true;return
 end
 -- Match production loading: one cooperative step per display frame. Draining
 -- the entire long-course loader inside one callback bypasses frame-time GC.
 if preparing then
  local loadTick=now();Loading.step(1/30);loadMax=math.max(loadMax,now()-loadTick)
  if Loading.label~=loadLabel then
   loadLabel=Loading.label;print('LOAD',loadLabel,'luaKB='..math.floor(collectgarbage('count')))
  end
  if not Loading.busy then
   print('LOAD COMPLETE route='..stages[stage]..' elapsedMS='..(now()-loadStart)..' maxUpdateMS='..loadMax)
   print('ROAD ASSETS',Courses[stages[stage]].roadBaked and 'PACKAGED' or 'RUNTIME')
   for label,row in pairs(loadWork) do print('LOAD WORK',label,'total='..row.total,'max='..row.max,'slices='..row.count) end
   Bench.ready();preparing=false;beginScene()
  end
  return
 end
 if stage==0 or frame>=(specs and specs[stage].frames or 180) then
  report();stage=stage+1;frame=0;samples={};costs={};last=nil
  if stage>#stages then results.complete=true;writeReport(results,'tilt-perf-report');print('BENCH COMPLETE');playdate.update=function() playdate.graphics.clear(playdate.graphics.kColorWhite);playdate.graphics.drawText('Hardware check complete.',35,100) end;return end
  if not specs or stage==1 or stages[stage]~=stages[stage-1] then
   collectgarbage('collect');loadWork={};loadStart=now();loadMax=0;Bench.select(stages[stage]);preparing=true;loadLabel=nil;return
  end
  beginScene()
 end
 local c=Courses[stages[stage]]
 -- Traverse the sorted road tiles in batches; this deliberately stresses camera/cache misses.
 local tile=c.tiles[math.min(#c.tiles,1+math.floor(frame/180*(#c.tiles-1)))]
 if specs then Bench.sample(specs[stage],frame)
 elseif Bench.joins then Bench.joinSample(stages[stage],frame)
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
