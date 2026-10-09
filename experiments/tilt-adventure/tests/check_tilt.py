"""Host-side Lua checks. Requires Python package lupa; no SDK modifications."""
from pathlib import Path
import os
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1] / 'source'
lua = LuaRuntime()
loaded = set()

def load(name):
    # Explicit historical geometry fixture run; current campaign is exercised
    # separately by check_curriculum.py using the full production imports.
    if name == 'curriculum' and os.environ.get('SKY_LEGACY_FIXTURES') == '1':
        return
    if name.startswith('CoreLibs/') or name in loaded:
        return
    loaded.add(name)
    lua.execute((root / (name + '.lua')).read_text(encoding='utf-8'))

lua.globals()['import'] = load
load('physics_tests')

# Execute the real update and UI code with only device I/O replaced.
lua.execute('''
clock=0; pressed={}; held={}; crank=0; menu={}
kTextAlignment={center=0}
local noop=function() end
local gfx=setmetatable({font={new=function() return {getHeight=function() return 14 end} end},image={new=function() return {getSize=function() return 48,48 end,setMaskImage=noop,getMaskImage=function() return {draw=noop} end,draw=noop,drawFaded=noop,drawRotated=noop,drawScaled=noop,sample=function() return 0 end} end},getTextSize=function(s) return #s*8,16 end}, {__index=function() return noop end})
local function player()
 return {plays=0,playing=false,setVolume=noop,setRate=noop,setPaused=noop,
 play=function(self) self.plays=self.plays+1;self.playing=true end,
 stop=function(self) self.playing=false end,isPlaying=function(self) return self.playing end}
end
playdate={graphics=gfx,display={setRefreshRate=noop},kButtonA='a',kButtonB='b',kButtonLeft='left',kButtonRight='right',kButtonUp='up',kButtonDown='down',
 sound={sampleplayer={new=player}},
 getCurrentTimeMilliseconds=function() return clock end,
 buttonJustPressed=function(k) return pressed[k] end,
 buttonIsPressed=function(k) return held[k] end,
 getCrankChange=function() local c=crank;crank=0;return c end,
 getSystemMenu=function() return {addMenuItem=function(self,k,f) menu[k]=f end,removeAllMenuItems=function() menu={} end} end}
function drainLoading()
 while Loading and Loading.busy do clock=clock+1000/30;Loading.step(1/30) end
end
function frame(keys,down,angle)
 clock=clock+1000/30;pressed=keys or {};held=down or {};crank=angle or 0;playdate.update();drainLoading();pressed={}
end
''')

lua.execute("""
accel={0,0,1};store={}
playdate.startAccelerometer=function() end
playdate.readAccelerometer=function() return table.unpack(accel) end
playdate.datastore={read=function() return store.saved end,write=function(v) store.saved=v end}
""")
load('engine')
lua.execute("""
-- Historical scenarios use road axes; screen mapping has its own production-input checks.
Tilt.mode='road'
function get(name)
 for i=1,100 do local n,v=debug.getupvalue(playdate.update,i);if n==name then return v end end
 error('missing '..name)
end
function put(name,value)
 for i=1,100 do local n=debug.getupvalue(playdate.update,i);if n==name then debug.setupvalue(playdate.update,i,value);return end end
 error('missing '..name)
end
function selectReady(n)
 get('selectLevel')(n);drainLoading();accel={0,0,1};for i=1,60 do Tilt.update(1/30) end
end
function sensorForForce(ax,ay,power)
 local n=math.sqrt(ax*ax+ay*ay)
 if n<.00001 or power<=0 then return {0,0,1} end
 local sx,sy=ax/n,ay/n
 if Tilt.mode=='screen' then sx,sy=(sx-sy)*.9,(sx+sy)*.45;local q=math.sqrt(sx*sx+sy*sy);sx,sy=sx/q,sy/q end
 local magnitude=.045+.4*math.min(1,power)^(1/1.05)
 return {sx*magnitude,sy*magnitude,math.sqrt(1-magnitude*magnitude)}
end
for i=1,40 do frame() end
assert(Tilt.ready and Tilt.power==0)
accel={.25,0,.968};for i=1,20 do frame() end
assert(Tilt.power>.49 and Tilt.power<.52 and Tilt.dx>0 and math.abs(Tilt.dy)<.0001 and not Tilt.jump)
accel={.42,0,.907};for i=1,20 do frame() end
assert(Tilt.power>.92 and Tilt.power<.95)
accel={0,0,1};for i=1,40 do frame() end
accel={0,0,1.9};Tilt.update(1/30);assert(Tilt.consumeJump())
Tilt.update(1/30);assert(not Tilt.consumeJump())
accel={0,0,1};for i=1,40 do frame() end
assert(Tilt.power==0)
local c=Courses.legacy[15];Dock.reset(c)
local d=Dock.update(c,112,80,0,0,false,0,false,false);assert(d.locked)
Dock.update(c,112,80,0,0,false,-90,false,false);assert(math.abs(c.mechanisms[1].angle)<.001)
d=Dock.update(c,112,80,0,0,false,0,false,true);assert(d.exit and not Dock.active)
assert(not Dock.update(c,112,80,0,0,false,0,false,false))
Dock.update(c,48,80,0,0,false,0,false,false)
assert(Dock.update(c,112,80,0,0,false,0,false,false).locked)
Dock.reset(Courses.legacy[16]);Dock.update(Courses.legacy[16],112,80,0,0,false,0,false,false)
d=Dock.update(Courses.legacy[16],112,80,0,0,false,0,true,false);assert(d.launch and d.vx==210)
-- Drive the actual game update through all courses and menus.
local select=selectReady
for n=1,#Courses do select(n);put('lesson',false);for i=1,3 do frame() end end
select(Courses.legacyIndex[16]);put('lesson',false);put('x',112);put('y',80);frame();assert(Dock.active)
frame({a=true});assert(get('airborne') and not Dock.active)
for i=1,33 do frame() end
assert(get('state')=='play' and not get('airborne'),'cannon must land on receiving platform')
select(Courses.legacyIndex[5]);put('lesson',false);frame({a=true});assert(get('airborne'))
select(Courses.legacyIndex[1]);put('lesson',false);frame({a=true});assert(not get('airborne'))
select(Courses.legacyIndex[1]);put('lesson',false);frame({up=true});assert(get('overview'));frame({b=true});assert(not get('overview'))
frame({down=true});assert(Tilt.calibrating);for i=1,40 do frame() end;assert(Tilt.ready)
select(#Courses);put('lesson',false);put('x',Courses[#Courses].goal[1]);put('y',Courses[#Courses].goal[2]);frame()
assert(get('state')=='win' and store.saved.completed[#Courses])
frame({a=true});assert(get('ending'));frame({a=true});assert(get('title') and not get('ending'))
select(Courses.legacyIndex[1]);put('lesson',false);put('state','dead');frame({a=true});assert(get('state')=='play')
print('PASS: calibration, neutral drift, proportional tilt, jump debounce, dock re-entry, bridge, cannon landing, all courses, map, retry, save and campaign ending')
""")

# Menu transitions and options must never advance the live course.
lua.execute("""
menu['Title / settings']();assert(get('title'))
frame({down=true});frame({down=true});assert(get('titleChoice')==2)
local elapsed=get('elapsed');local pos=get('x')
frame({a=true});assert(get('settings'))
frame({a=true});assert(not Audio.effects and store.saved.options.effects==false)
frame({down=true});frame({a=true});assert(not Audio.musicEnabled and not store.saved.options.music)
frame({down=true});frame({a=true});assert(not UI.motion and not store.saved.options.motion)
frame({down=true});frame({a=true});assert(not get('gesture') and not store.saved.options.gesture)
for i=1,10 do frame() end
assert(get('elapsed')==elapsed and get('x')==pos)
frame({b=true});assert(not get('settings') and get('title'))
frame({up=true});frame({a=true});if get('startMenu') then frame({a=true}) end;assert(not get('title'))
put('lesson',false);for i=1,40 do frame() end
local level=get('level');local before=get('elapsed');local xx=get('x')
menu['Level select']();assert(get('choosing'));frame({right=true});frame({b=true})
assert(not get('choosing') and get('level')==level and get('x')==xx and get('elapsed')==before)
for _,kind in ipairs({'gate','trap','ferry','rotor','sweeper','control','cannon','relay'}) do UI.lesson(kind,1) end
for i=1,#Courses do UI.selector(i,{}) end
UI.settings(4,false,false,false);UI.calibration();UI.failure(1,true);UI.result(60,1,55,false);UI.ending({[1]=true})
assert(UI.moveSelection(3,'right',17)==6 and UI.moveSelection(6,'right',17)==9)
print('PASS: two home entries, settings persistence, paused menus, selector return, all UI states and column-first navigation')
""")

# First-encounter guides are persistent, pause physics, and cover direct level selection.
lua.execute("""
Guide.seen={};local select=selectReady;select(Courses.legacyIndex[1])
assert(get('lesson') and Guide.key()=='arrival')
local xx,yy,tt=get('x'),get('y'),get('elapsed')
for i=1,40 do frame() end
assert(get('x')==xx and get('y')==yy and get('elapsed')==tt)
frame({b=true});assert(Guide.time==0 and not Guide.seen.arrival)
frame({a=true});assert(Guide.key()=='roll' and store.saved.guides.arrival)
assert(get('steeringMenu') and get('steeringChoice')==2)
frame({a=true});assert(get('steeringNotice') and store.saved.steeringChosen)
frame({a=true});assert(not get('steeringNotice') and get('lesson'))
frame({a=true});assert(not get('lesson') and Guide.seen.roll)
select(Courses.legacyIndex[1]);assert(not get('lesson'))
select(Courses.legacyIndex[5]);assert(Guide.key()=='jump');frame({a=true});assert(not get('lesson') and store.saved.guides.jump)
select(Courses.legacyIndex[6]);assert(not get('lesson'))
select(Courses.legacyIndex[8]);assert(Guide.key()=='gate');frame({a=true});select(Courses.legacyIndex[13])
assert(Guide.key()=='ferry');frame({a=true});assert(not get('lesson'))
select(Courses.legacyIndex[15]);assert(Guide.key()=='control');frame({a=true});select(Courses.legacyIndex[16]);assert(Guide.key()=='cannon');frame({a=true})
select(Courses.legacyIndex[17]);assert(not get('lesson'),'mixed levels must not repeat known tutorials')
local memory=store.saved.guides;Guide.seen=memory;select(Courses.legacyIndex[16]);assert(not get('lesson'))
Guide.seen={};select(Courses.legacyIndex[14])
local keys={};while Guide.key() do keys[Guide.key()]=true;Guide.advance() end
assert(keys.arrival and keys.roll and keys.jump and keys.rotor and keys.sweeper and keys.trap and keys.gate)
for _,kind in ipairs({'arrival','roll','jump','control','cannon','gate','trap','ferry','rotor','sweeper'}) do
 for _,t in ipairs({0,.5,1,1.6,1.85,2.4,3.4,4.5,5.9,6}) do UI.lesson(kind,t) end
end
print('PASS: first encounters, persisted acknowledgements, no repeated jump tutorial, replay, paused world, mixed-route queue and every animation phase')
""")

# Every stable grip establishes a two-axis tangent frame; world axes project diagonally.
lua.execute("""
local function settle(a,n) accel=a;for i=1,n or 90 do Tilt.update(1/30) end end
for _,pose in ipairs({{0,0,1},{0,1,0},{1,0,0},{0,0,-1},{.3,.4,.866}}) do
 Tilt.startCalibration();settle(pose);assert(Tilt.ready and not Tilt.calibrating and Tilt.power==0)
 local nx,ny,nz=Tilt.nx,Tilt.ny,Tilt.nz
 local rx,ry,rz=Tilt.rx,Tilt.ry,Tilt.rz;local ux,uy,uz=Tilt.ux,Tilt.uy,Tilt.uz
 assert(math.abs(nx*rx+ny*ry+nz*rz)<.00001 and math.abs(nx*ux+ny*uy+nz*uz)<.00001)
 for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
  settle({nx*.954+.3*(d[1]*rx+d[2]*ux),ny*.954+.3*(d[1]*ry+d[2]*uy),nz*.954+.3*(d[1]*rz+d[2]*uz)})
  assert(Tilt.power>.61 and Tilt.power<.64 and math.abs(Tilt.dx-d[1])<.001 and math.abs(Tilt.dy-d[2])<.001)
  local px,py=(Tilt.dx-Tilt.dy)*.9,(Tilt.dx+Tilt.dy)*.45
  assert(px*(d[1]-d[2])>0 and py*(d[1]+d[2])>0)
 end
 settle(pose);assert(Tilt.power==0)
end
Tilt.startCalibration()
for i=1,120 do settle({i%2==0 and .2 or -.2,0,.98},1) end
assert(Tilt.calibrating and not Tilt.ready,'moving input cannot calibrate')
settle({0,0,1});assert(Tilt.ready)
local select=get('selectLevel');select(Courses.legacyIndex[2]);drainLoading();assert(Tilt.calibrating and not Tilt.ready)
settle({0,.6,.8});assert(Tilt.ready and Tilt.power==0)
local vx,vy=100,0
vx,vy=Physics.step(vx,vy,-1,0,1,0,0,1/30);assert(vx>0 and vx<100)
print('PASS: arbitrary steady grips, stable tangent basis, four world directions and diagonal arrows, motion rejection, per-course calibration and inertial reversal')
""")

# Current screen-normal translation is accepted; lateral shakes are rejected.
lua.execute("""
local function settle(a) accel=a;for i=1,50 do Tilt.update(1/30) end end
Tilt.startCalibration();settle({0,0,1})
accel={0,0,1.9};Tilt.update(1/30);assert(Tilt.consumeJump())
for i=1,5 do Tilt.update(1/30);assert(not Tilt.consumeJump()) end
settle({0,1,0});accel={0,1,1};Tilt.update(1/30);assert(Tilt.consumeJump())
settle({0,0,1});accel={1,0,1.9};Tilt.update(1/30);assert(not Tilt.consumeJump())
settle({0,0,1});accel={0,0,1.9};Tilt.update(1/30);assert(Tilt.consumeJump())
assert(store.saved.guideRevision==3)
print('PASS: screen-normal pulse, single trigger, upright support and lateral shake rejection, rearming and tutorial revision')
""")

# Manual help and route notes pause the current run, including a docked cannon.
lua.execute("""
local select=selectReady;select(Courses.legacyIndex[14]);put('lesson',false);Tilt.calibrating=false;accel={0,0,1}
local xx,yy,tt,wt=get('x'),get('y'),get('elapsed'),get('worldTime')
frame({left=true});assert(get('lesson') and Guide.manual and Guide.key()=='roll')
local keys={};for _,k in ipairs(Guide.queue) do keys[k]=true end
assert(keys.jump and keys.rotor and keys.trap and keys.sweeper and keys.gate and not keys.arrival)
for i=1,10 do frame() end
assert(get('x')==xx and get('y')==yy and get('elapsed')==tt and get('worldTime')==wt)
frame({b=true});assert(not get('lesson') and not get('airborne'))
frame({right=true});assert(get('briefing'));assert(#UI.goalPages(Courses.legacy[14],Courses.legacyIndex[14])==7)
for i=1,10 do frame() end
assert(get('x')==xx and get('elapsed')==tt and get('worldTime')==wt)
frame({a=true});assert(get('infoPage')==2 and not get('airborne'))
frame({left=true});assert(get('infoPage')==1)
frame({b=true});assert(not get('briefing') and get('x')==xx)
frame({left=true});while get('lesson') do frame({a=true}) end
assert(get('x')==xx and get('elapsed')==tt)
select(Courses.legacyIndex[16]);put('lesson',false);put('x',112);put('y',80);frame();assert(Dock.active)
local dock=Dock.active;local angle=dock.angle
frame({right=true});frame(nil,nil,90);frame({b=true});assert(Dock.active==dock and dock.angle==angle)
frame({left=true});frame({b=true});assert(Dock.active==dock)
for n,c in ipairs(Courses) do for i=1,#UI.goalPages(c,n) do UI.goal(c,n,i) end end
print('PASS: Help replay, B return, full replay resume, Goal paging, frozen physics/time, no accidental jump or cannon release, all route notes')
""")


lua.execute("""
for _,n in ipairs({{0,.6,.8},{0,1,0},{1,0,0}}) do
 Tilt.startCalibration();accel=n;for i=1,60 do Tilt.update(1/30) end
 assert(Tilt.ready and Tilt.power==0)
 accel={n[1],n[2],n[3]+.9};Tilt.update(1/30);assert(Tilt.consumeJump())
 Tilt.update(1/30);assert(not Tilt.consumeJump())
end
print('PASS: lift impulse follows device Z in angled, upright and side-on grips')
""")

lua.execute("""
selectReady(1);put('lesson',false);put('x',80);put('y',80);put('vx',100);put('vy',0)
put('airborne',true);put('jumpZ',.1);put('jumpV',-120);accel={0,0,1}
frame()
assert(not get('airborne') and get('state')=='play','top landing must stay supported')
assert(get('vx')>98 and math.abs(get('vy'))<.01,'top landing must not be resolved as a side-wall impact')
print('PASS: downward top contact preserves horizontal momentum')
""")


lua.execute("""
-- Calibrate one pose, then rotate elsewhere: jump must follow device Z, not old gravity.
Tilt.startCalibration();accel={0,.6,.8};for i=1,60 do Tilt.update(1/30) end
accel={.5,0,.866};for i=1,60 do Tilt.update(1/30) end
local power,dx,dy=Tilt.power,Tilt.dx,Tilt.dy
accel={.5,0,1.766};Tilt.update(1/30);assert(Tilt.consumeJump())
assert(math.abs(Tilt.power-power)<.00001 and Tilt.dx==dx and Tilt.dy==dy,'lift pulse must not contaminate steering')
local c=Courses.legacy[16];Dock.reset(c);assert(Dock.status()==nil)
Dock.update(c,112,80,0,0,false,0,false,false);assert(Dock.status()=='LOCKED')
Dock.update(c,112,80,0,0,false,0,false,true);assert(Dock.status()=='UNLOCKED')
assert(not Dock.update(c,115,80,0,0,false,0,false,false));assert(Dock.status()=='UNLOCKED')
Dock.update(c,48,80,0,0,false,0,false,false);assert(Dock.status()==nil)
Dock.update(c,112,80,0,0,false,0,false,false);assert(Dock.status()=='LOCKED')
for _,vel in ipairs({{100,0},{-100,0},{0,100},{0,-100}}) do
 selectReady(1);put('lesson',false);put('x',80);put('y',48);put('vx',vel[1]);put('vy',vel[2])
 put('airborne',true);put('jumpZ',.1);put('jumpV',-120);accel={0,0,1};frame()
 assert(not get('airborne') and get('state')=='play')
 assert(get('vx')*vel[1]+get('vy')*vel[2]>9800,'landing must preserve travel direction and momentum')
end
print('PASS: current pose normal after turning, unpolluted steering, locked/released/leave/relock states, four-direction landing momentum')
""")
