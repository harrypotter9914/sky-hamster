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
local gfx=setmetatable({getTextSize=function(s) return #s*8,16 end}, {__index=function() return noop end})
playdate={graphics=gfx,display={setRefreshRate=noop},kButtonA='a',kButtonB='b',kButtonLeft='left',kButtonRight='right',kButtonUp='up',kButtonDown='down',
 getCurrentTimeMilliseconds=function() return clock end,
 buttonJustPressed=function(k) return pressed[k] end,
 buttonIsPressed=function(k) return held[k] end,
 getCrankChange=function() local c=crank;crank=0;return c end,
 getSystemMenu=function() return {addMenuItem=function(self,k,f) menu[k]=f end} end}
function frame(keys,down,angle)
 clock=clock+1000/30;pressed=keys or {};held=down or {};crank=angle or 0;playdate.update();pressed={}
end
''')
load('main')
lua.execute('''
local function up(name)
 for i=1,100 do local n,v=debug.getupvalue(playdate.update,i);if n==name then return v end end
 error('missing state '..name)
end
local function set(name,value)
 for i=1,100 do local n=debug.getupvalue(playdate.update,i);if n==name then debug.setupvalue(playdate.update,i,value);return end end
 error('missing state '..name)
end
local selectLevel=up('selectLevel')
for n=1,#Courses do
 selectLevel(n)
 if up('lesson') then frame({a=true}) end
 frame()
 menu['Map / pause']();local before=up('worldTime');frame();assert(up('worldTime')==before,'map pauses mechanisms')
 frame({b=true})
 for i=1,30 do frame() end
 assert(up('state')=='play','safe idle start course '..n)
 menu['Level select']();frame();frame({b=true})
end
selectLevel(6);assert(not up('lesson'),'later jump course has no jump lesson')
selectLevel(14);menu['Level select']();frame();frame({right=true});assert(up('selected')==14,'selector upper bound')
frame({a=true});assert(up('level')==14,'last course selectable')
-- Ride an entire half-cycle using the actual game loop.
selectLevel(11);set('lesson',false);set('x',152);set('y',176)
for i=1,210 do frame() end
assert(up('state')=='play' and math.abs(up('x')-360)<0.05,'actual loop carries rotor rider')
set('vx',60)
for i=1,30 do frame() end
assert(up('state')=='play' and up('x')>400,'rotor rider can leave at far dock')
selectLevel(10);set('lesson',false);set('x',184);set('y',80)
for i=1,180 do frame() end
assert(up('state')=='play' and math.abs(up('x')-456)<0.05,'actual loop carries ferry rider')
set('vx',70)
for i=1,30 do frame() end
assert(up('state')=='play' and up('x')>510,'ferry rider can leave at far dock')
-- Carry velocity is inherited when jumping during transit.
selectLevel(10);set('lesson',false);set('worldTime',3.5)
local px,py=Mechanisms.pose(Courses[10].mechanisms[1],3.5)
set('x',px);set('y',py);up('controls').charge=0.5
frame({a=true});assert(up('airborne') and up('vx')>50,'jump inherits ferry motion')
-- Closed barriers stop high-speed motion without tunnelling.
selectLevel(8);set('lesson',false);set('x',215);set('y',80);set('vx',600)
frame();assert(up('x')<224 and up('vx')==0,'high-speed gate collision')
-- The trap opening must cause a fall, not invisible standing support.
selectLevel(9);set('lesson',false);set('x',192);set('y',80);set('worldTime',2.99)
frame();assert(up('state')=='fall','trap opening drops player')
selectLevel(14);set('x',Courses[14].goal[1]);set('y',Courses[14].goal[2]);frame()
assert(up('state')=='win','last course finish detection');frame({a=true});assert(up('choosing'),'final win opens selector')
print('PASS: all 14 live update paths, selector, tutorial gating, pause, riding and falling')
''')
