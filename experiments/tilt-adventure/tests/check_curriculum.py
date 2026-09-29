"""Production chapter order, all-feature expeditions, migration and traversable joins."""
from pathlib import Path
import os
os.environ.pop('SKY_LEGACY_FIXTURES', None)
fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
scope={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0]+"load('engine')",str(fixture),'exec'),scope)
lua=scope['lua']
helpers='function get(name)'+source.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0]
lua.execute(helpers)
lua.execute('''
assert(#Courses==53,'campaign must have 49 teaching/review courses and four finales')
local seen={};local tileCount=0
for n,c in ipairs(Courses) do
 Curriculum.ensure(c)
 assert(not seen[c.id]);seen[c.id]=true;assert(Courses.indexById[c.id]==n)
 tileCount=tileCount+#c.tiles
 for _,p in ipairs({c.start,c.goal}) do assert(c.lookup[math.floor(p[1]/32)..','..math.floor(p[2]/32)],'off-road endpoint '..n) end
 for _,p in ipairs(c.checkpoints) do assert(c.lookup[math.floor(p[1]/32)..','..math.floor(p[2]/32)],'off-road checkpoint '..n) end
 assert((n>49)==(c.finale==true),'teaching after finale')
 if c.review or c.finale then
  local features={}
  for _,s in ipairs(c.sections) do features[s.kind]=true end
  local limit=c.finale and #Curriculum.chapters-1 or c.chapter
  for i=1,limit do assert(features[Curriculum.chapters[i].new],'review omits learned mechanic '..n..':'..i) end
  assert(#c.checkpoints==#c.sections-1)
 end
end
for i,ch in ipairs(Curriculum.chapters) do assert(ch.last-ch.first>=1,'new mechanic every single level') end
for n=50,53 do
 local c=Courses[n]
 local function signature(v) local keys={};for _,s in ipairs(v.sections) do keys[#keys+1]=s.kind end;return table.concat(keys,',') end
 assert(signature(c)~=signature(Courses[n-1]),'finale repeats the preceding encounter order')
 local actual={}
 for _,m in ipairs(c.mechanisms) do
  local key=m.kind
  if key=='rotor' then key=m.retract and 'extend' or m.turnSquare and 'onboard' or m.manual and 'bridge' or 'rotor'
  elseif key=='ferry' and m.manual then key='slider'
  elseif key=='gate' and m.switchGate then key='switch' end
  actual[key]=true
 end
 for _,p in ipairs(c.pads) do if p.kind=='cannon' then actual.cannon=true elseif p.kind=='fan' then actual.windcontrol=true end end
 for _,key in ipairs(Curriculum.allFeatures) do if key~='terrain' and key~='valley' and key~='jump' then assert(actual[key],'feature named but not actually placed '..key) end end
 for _,key in ipairs({'slope','valley','narrow','hairpin','gap','island','elevation','flight','diagonalRide'}) do assert(c.features[key],'finale missing terrain '..key) end
 for _,key in ipairs(Curriculum.allFeatures) do assert(c.features[key],'finale missing '..key) end
 assert(#c.sections==({21,23,25,28})[n-49] and #c.mechanisms>=19 and #c.pads>=9 and c.goal[1]>10000,'finale too short')
 if n>50 then assert(c.goal[1]>Courses[n-1].goal[1],'finales do not grow') end
end
-- Every prior index maps by identity; changed geometry retains wins but resets
-- incomparable time records. Settings and seen tutorials are untouched.
for old=1,48 do
 local s={campaignRevision=2,level=old,completed={[old]=true},best={[tostring(old)]=42},options={music=false},guides={jump=true}}
 local got=Courses.migrate(s);local n=Courses.indexById[Curriculum.previousIds[old]]
 assert(got.level==n and got.completed[n] and got.campaignRevision==5)
 assert(got.options.music==false and got.guides.jump)
 assert((got.best[tostring(n)]~=nil)==(not Courses[n].layoutRevision))
 assert(Courses.migrate(got)==got)
end
for old=1,17 do assert(Courses.migrate({level=old}).level==Courses.indexById['legacy-'..old]) end
local prior={campaignRevision=3,level=53,completed={[51]=true},best={['2']=12,['49']=16,['50']=13,['51']=14,['53']=15},guides={cannon=true}}
assert(Courses.migrate(prior)==prior and prior.level==53 and prior.completed[51] and prior.guides.cannon)
assert(prior.best['2']==12 and prior.best['49']==nil and prior.best['50']==nil and prior.best['51']==nil and prior.best['53']==nil)
print('PASS: 53 stable identities, 20 teaching chapters, cumulative reviews, four 21/23/25/28-encounter finales, 48+17 save migrations; '..tileCount..' tiles')
-- Exact joins at every moving landing, using current production support.
local joins=0
for _,c in ipairs(Courses) do
 Curriculum.ensure(c)
 Dock.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do for _,p in ipairs(Passage.ports(m)) do
  if m.kind=='lift' then m.elevation=p.z
  elseif m.kind=='ferry' then m.progress=p.dx<0 and 0 or 1
  elseif m.retract then m.w=m.maxWidth
  else m.angle=math.atan(p.dy,p.dx) end
  local t=m.kind=='ferry' and not m.manual and (p.dx<0 and 0 or (m.period or 10)*.5) or 0
  assert(Passage.ready(c,m,p,t),'landing cannot open '..c.id..':'..m.kind)
  joins=joins+1
 end end
end
print('PASS: '..joins..' production landing ports meet their road at the correct height')
Guide.seen={}
for n,c in ipairs(Courses) do
 Guide.enter(c)
 if c.finale then assert(#Guide.queue==0,'finale unexpectedly teaches a new mechanic')
 elseif n>1 then assert(#Guide.queue<=1,'several new mechanics introduced together at '..n) end
 while Guide.key() do Guide.advance() end
end
print('PASS: sequential teaching introduces at most one new lesson per course; final four introduce none')
''')
lua.execute('''
local context=''
local function alive()
 assert(get('state')=='play' or get('state')=='win',context..' fell at '..get('x')..','..get('y'))
end
local function walk(tx,ty,speed,want)
 local target=string.format(' toward %.1f,%.1f',tx,ty)
 for i=1,1000 do
  assert(get('state')=='play' or get('state')=='win',context..target..' fell at '..get('x')..','..get('y'));if get('state')=='win' then return end
  if Dock.active then if want and Dock.active==want then return else frame({b=true}) end end
  local dx,dy=tx-get('x'),ty-get('y');local d=math.sqrt(dx*dx+dy*dy)
  if d<2 and not want then return end
  local v=math.min(speed or 90,d*6)
  if want and d<30 then v=math.min(v,25) end
  put('vx',d>0 and dx/d*v or 0);put('vy',d>0 and dy/d*v or 0)
  frame()
 end
 error(context..' blocked at '..get('x')..','..get('y')..' toward '..tx..','..ty)
end
local function dock(p,crank)
 walk(p.x,p.y,70,p);assert(Dock.active==p,context..' failed to dock')
 frame(nil,nil,crank);frame({b=true})
end
local function hop(speed)
 Tilt.cooldown=0;put('vx',speed);put('vy',0);frame({a=true})
 assert(get('airborne'),context..' jump not triggered')
 for i=1,80 do
  alive();if not get('airborne') then return end
  put('vx',speed);put('vy',0);frame()
 end
 error(context..' never landed')
end
for n=50,53 do
 selectReady(n);put('lesson',false);put('title',false);Tilt.calibrating=false
 local c=Courses[n]
 for index,s in ipairs(c.sections) do
  local x=s.x;local key=s.kind;context=n..'/'..index..'/'..key
  walk(x+48,80)
  if s.route then
   for _,step in ipairs(s.route) do
    if step.kind=='walk' then walk(step.x,step.y,75)
    elseif step.kind=='hop' then
     local dx,dy=step.x-get('x'),step.y-get('y')
     Tilt.cooldown=0;put('vx',dx);put('vy',dy);frame({a=true})
     assert(get('airborne'),context..' diagonal hop failed')
     for i=1,90 do alive();if not get('airborne') then break end;frame() end
     assert(not get('airborne'),context..' diagonal hop missed')
    elseif step.kind=='clock' then put('worldTime',step.value)
    elseif step.kind=='dock' then dock(step.pad,step.crank)
    elseif step.kind=='fire' then
     local p=step.pad;walk(p.x,p.y,60,p)
     frame(nil,nil,math.deg(step.angle-(p.angle or 0)));frame({a=true})
     assert(get('airborne'),context..' angled cannon did not fire')
     for i=1,90 do alive();if not get('airborne') then break end;frame() end
     assert(not get('airborne'),context..' angled cannon did not land')
     assert((get('x')-step.landing[1])^2+(get('y')-step.landing[2])^2<48^2,context..' wrong landing island')
    end
   end
  elseif key=='terrain' then
   for _,p in ipairs({{144,80},{272,80},{272,208},{400,208},{400,80}}) do walk(x+p[1],p[2]) end
  elseif key=='jump' then walk(x+112,80);hop(105);walk(x+240,80);hop(105)
  elseif key=='gate' then walk(x+128,80);put('worldTime',3);walk(x+224,80,130)
  elseif key=='trap' then walk(x+112,80);put('worldTime',0);walk(x+240,80,130)
  elseif key=='rotor' then walk(x+112,80);put('worldTime',0);walk(x+304,80,150)
  elseif key=='ferry' then
   walk(x+112,80);put('worldTime',0);walk(x+168,80,95)
   for i=1,230 do put('vx',0);put('vy',0);frame();alive();if get('worldTime')>=6.05 then break end end
   walk(x+384,80,120)
  elseif key=='sweeper' then walk(x+144,16);walk(x+168,16);put('worldTime',.7);walk(x+256,16,140);walk(x+304,80)
  elseif key=='bridge' then dock(c.pads[s.firstPad],-90)
  elseif key=='onboard' then
   if n==53 then walk(x+48,80);put('worldTime',4);walk(x+120,80,140) end
   dock(c.pads[s.firstPad],-90);dock(c.pads[s.firstPad+1],-90)
   walk(x+320,-48);walk(x+512,-48);walk(x+512,80)
  elseif key=='lift' then
   dock(c.pads[s.firstPad],384);walk(x+224,48);walk(x+336,48);walk(x+336,80)
  elseif key=='slider' then dock(c.pads[s.firstPad],540);walk(x+400,176);walk(x+448,176);walk(x+448,80)
  elseif key=='windcontrol' then dock(c.pads[s.firstPad],-90)
  elseif key=='extend' then dock(c.pads[s.firstPad],400)
  elseif key=='switch' then
   dock(c.pads[s.firstPad],0);walk(x+144,32);walk(x+384,32);walk(x+400,80)
  elseif key=='cannon' then
   local p=c.pads[s.firstPad];walk(p.x,p.y,60,p);frame({a=true})
   assert(get('airborne'),context..' cannon did not fire')
   for i=1,90 do alive();if not get('airborne') then break end;frame() end
   assert(not get('airborne'),context..' cannon did not land')
  end
  walk(s.finish[1],s.finish[2]);alive()
 end
 assert(get('state')=='win' and get('falls')==0,'finale incomplete '..n)
 assert(get('checkpoint')==#c.checkpoints,'finale missed its checkpoint sequence')
 print('PASS: production finale '..n..' traverses '..#c.sections..' encounters, '..#c.checkpoints..' checkpoints, reaches win with zero falls')
end
''')
lua.execute('''
for _,c in ipairs(Courses) do Curriculum.release(c) end
local generated=0;for _,c in ipairs(Courses) do if c.blueprint then generated=generated+#c.tiles end end
assert(generated==0,'released future courses retain geometry')
local maximum=0
for n=50,53 do
 local c=Courses[n];Curriculum.ensure(c)
 local cache=Terrain.new(c,function()end);Terrain.prepare(cache,0,0)
 assert(cache.stream and not cache.keepAll and cache.count<=35,'long course must prepare only the starting neighbourhood')
 maximum=math.max(maximum,cache.count)
 for wx=48,c.goal[1],5 do
  clock=clock+1000/30
  Terrain.draw(cache,(wx-80)*.9,(wx+80)*.45-c:height(wx,80)*.65)
  maximum=math.max(maximum,cache.count)
 end
 assert(cache.misses==0,'150 units/sec traversal outran the terrain preparation margin')
 assert(cache.count<=48,'streamed road images grew without a bound')
 UI.mapSection=nil;UI.mapMove(c,48,1);assert(UI.mapSection==2)
 for i=1,100 do UI.mapMove(c,48,1) end;assert(UI.mapSection==#c.sections)
 Curriculum.release(c);assert(not c.materialized and #c.tiles==0 and #c.mechanisms==0)
 Curriculum.ensure(c);assert(#c.sections==({21,23,25,28})[n-49]);Curriculum.release(c)
end
print('PASS: lazy geometry release/re-entry; four streamed long maps, zero visible chunk misses at 150 units/sec, maximum '..maximum..' chunks; section navigation clamps')
''')
