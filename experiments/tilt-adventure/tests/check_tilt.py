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
local gfx=setmetatable({image={new=function() return {setMaskImage=noop,getMaskImage=function() return {draw=noop} end,draw=noop,drawScaled=noop,sample=function() return 0 end} end},getTextSize=function(s) return #s*8,16 end}, {__index=function() return noop end})
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
