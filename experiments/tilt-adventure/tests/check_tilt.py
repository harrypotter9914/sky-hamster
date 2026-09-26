"""Host-side Lua checks. Requires Python package lupa; no SDK modifications."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1] / 'source'
lua = LuaRuntime()
loaded = set()

def load(name):
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
local gfx=setmetatable({font={new=function() return {getHeight=function() return 14 end} end},image={new=function() return {setMaskImage=noop,getMaskImage=function() return {draw=noop} end,draw=noop,drawRotated=noop,drawScaled=noop,sample=function() return 0 end} end},getTextSize=function(s) return #s*8,16 end}, {__index=function() return noop end})
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
function frame(keys,down,angle)
 clock=clock+1000/30;pressed=keys or {};held=down or {};crank=angle or 0;playdate.update();pressed={}
end
''')

lua.execute("""
accel={0,0,1};store={}
playdate.startAccelerometer=function() end
playdate.readAccelerometer=function() return table.unpack(accel) end
playdate.datastore={read=function() return store.saved end,write=function(v) store.saved=v end}
""")
load('main')
lua.execute("""
function get(name)
 for i=1,100 do local n,v=debug.getupvalue(playdate.update,i);if n==name then return v end end
 error('missing '..name)
end
function put(name,value)
 for i=1,100 do local n=debug.getupvalue(playdate.update,i);if n==name then debug.setupvalue(playdate.update,i,value);return end end
 error('missing '..name)
end
for i=1,40 do frame() end
assert(Tilt.ready and Tilt.power==0)
accel={.25,0,.968};for i=1,20 do frame() end
assert(Tilt.power>.3 and Tilt.dx>0 and Tilt.dy<0 and not Tilt.jump)
accel={.42,0,.907};for i=1,20 do frame() end
assert(Tilt.power>.8)
accel={0,0,1};for i=1,40 do frame() end
accel={0,0,1.9};Tilt.update(1/30);assert(Tilt.consumeJump())
Tilt.update(1/30);assert(not Tilt.consumeJump())
accel={0,0,1};for i=1,40 do frame() end
assert(Tilt.power==0)
local c=Courses[15];Dock.reset(c)
local d=Dock.update(c,112,80,0,0,false,0,false,false);assert(d.locked)
Dock.update(c,112,80,0,0,false,-90,false,false);assert(math.abs(c.mechanisms[1].angle)<.001)
d=Dock.update(c,112,80,0,0,false,0,false,true);assert(d.exit and not Dock.active)
assert(not Dock.update(c,112,80,0,0,false,0,false,false))
Dock.update(c,48,80,0,0,false,0,false,false)
assert(Dock.update(c,112,80,0,0,false,0,false,false).locked)
Dock.reset(Courses[16]);Dock.update(Courses[16],112,80,0,0,false,0,false,false)
d=Dock.update(Courses[16],112,80,0,0,false,0,true,false);assert(d.launch and d.vx==210)
-- Drive the actual game update through all courses and menus.
local select=get('selectLevel')
for n=1,#Courses do select(n);put('lesson',false);for i=1,3 do frame() end end
select(16);put('lesson',false);put('x',112);put('y',80);frame();assert(Dock.active)
frame({a=true});assert(get('airborne') and not Dock.active)
for i=1,33 do frame() end
assert(get('state')=='play' and not get('airborne'),'cannon must land on receiving platform')
select(5);put('lesson',false);frame({a=true});assert(get('airborne'))
select(1);put('lesson',false);frame({a=true});assert(not get('airborne'))
select(1);put('lesson',false);frame({up=true});assert(get('overview'));frame({b=true});assert(not get('overview'))
frame({down=true});assert(Tilt.calibrating);for i=1,40 do frame() end;assert(Tilt.ready)
select(#Courses);put('lesson',false);put('x',Courses[#Courses].goal[1]);put('y',Courses[#Courses].goal[2]);frame()
assert(get('state')=='win' and store.saved.completed[#Courses])
frame({a=true});assert(get('ending'));frame({a=true});assert(get('title') and not get('ending'))
select(1);put('lesson',false);put('state','dead');frame({a=true});assert(get('state')=='play')
print('PASS: calibration, neutral drift, proportional tilt, jump debounce, dock re-entry, bridge, cannon landing, 17 courses, map, retry, save and campaign ending')
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
frame({up=true});frame({a=true});assert(not get('title'))
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
Guide.seen={};local select=get('selectLevel');select(1)
assert(get('lesson') and Guide.key()=='arrival')
local xx,yy,tt=get('x'),get('y'),get('elapsed')
for i=1,40 do frame() end
assert(get('x')==xx and get('y')==yy and get('elapsed')==tt)
frame({b=true});assert(Guide.time==0 and not Guide.seen.arrival)
frame({a=true});assert(Guide.key()=='roll' and store.saved.guides.arrival)
frame({a=true});assert(not get('lesson') and Guide.seen.roll)
select(1);assert(not get('lesson'))
select(5);assert(Guide.key()=='jump');frame({a=true});assert(not get('lesson') and store.saved.guides.jump)
select(6);assert(not get('lesson'))
select(8);assert(Guide.key()=='gate');frame({a=true});select(13)
assert(Guide.key()=='ferry');frame({a=true});assert(not get('lesson'))
select(15);assert(Guide.key()=='control');frame({a=true});select(16);assert(Guide.key()=='cannon');frame({a=true})
select(17);assert(not get('lesson'),'mixed levels must not repeat known tutorials')
local memory=store.saved.guides;Guide.seen=memory;select(16);assert(not get('lesson'))
Guide.seen={};select(14)
local keys={};while Guide.key() do keys[Guide.key()]=true;Guide.advance() end
assert(keys.arrival and keys.roll and keys.jump and keys.rotor and keys.sweeper and keys.trap and keys.gate)
for _,kind in ipairs({'arrival','roll','jump','control','cannon','gate','trap','ferry','rotor','sweeper'}) do
 for _,t in ipairs({0,.5,1,1.6,2.4,3.4,4.5}) do UI.lesson(kind,t) end
end
print('PASS: first encounters, persisted acknowledgements, no repeated jump tutorial, replay, paused world, mixed-route queue and every animation phase')
""")

# The SDK defines flat screen-up as (0,0,1), upright as (0,1,0).
lua.execute("""
local function settle(a,n) accel=a;for i=1,n or 90 do Tilt.update(1/30) end end
for _,bad in ipairs({{0,1,0},{1,0,0},{0,0,-1},{.3,.2,.93}}) do
 Tilt.startCalibration();settle(bad);assert(Tilt.calibrating and not Tilt.ready and Tilt.time==0)
 assert(Tilt.power==0 and Tilt.nx==0 and Tilt.ny==0 and Tilt.nz==1)
end
settle({0,0,1});assert(Tilt.ready and not Tilt.calibrating and Tilt.power==0)
local directions={{{.3,0,.954},1,0},{{-.3,0,.954},-1,0},{{0,-.3,.954},0,-1},{{0,.3,.954},0,1}}
for _,case in ipairs(directions) do
 settle(case[1]);local px=(Tilt.dx-Tilt.dy)*.9;local py=(Tilt.dx+Tilt.dy)*.45
 assert(Tilt.power>.5)
 if case[2]~=0 then assert(px*case[2]>0 and math.abs(py)<.0001) else assert(py*case[3]>0 and math.abs(px)<.0001) end
end
settle({0,1,0});assert(Tilt.power>.9,'upright must never be neutral')
settle({0,0,1});assert(Tilt.power==0 and Tilt.dx==0 and Tilt.dy==0)
settle({-.35,0,.937});local vx,vy=0,0
for i=1,30 do vx,vy=Physics.step(vx,vy,Tilt.dx,Tilt.dy,Tilt.power,0,0,1/30) end
local before=(vx-vy)*.9;assert(before<0)
settle({.35,0,.937});vx,vy=Physics.step(vx,vy,Tilt.dx,Tilt.dy,Tilt.power,0,0,1/30)
assert((vx-vy)*.9>before and (vx-vy)*.9<0,'opposite tilt brakes through force, without snapping velocity')
for i=1,90 do vx,vy=Physics.step(vx,vy,Tilt.dx,Tilt.dy,Tilt.power,0,0,1/30) end
assert((vx-vy)*.9>0,'sustained counter-tilt eventually reverses travel')
Tilt.startCalibration();settle({.06,-.06,.996});assert(Tilt.ready and math.abs(Tilt.nx)<=.025 and math.abs(Tilt.ny)<=.025)
settle({0,0,1});assert(Tilt.power==0,'limited trim must leave exact flat inside the deadzone')
print('PASS: upright/sideways/inverted calibration rejected, flat zero, four screen directions, bounded trim and inertial counter-steering')
""")
