"""USB status, rather than charging current, controls the game's auto-lock policy."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

lua = LuaRuntime()
lua.execute('''
clock=0;power={USB=true,charging=false};calls={};reads=0
playdate={getCurrentTimeMilliseconds=function()return clock end,
 getPowerStatus=function()reads=reads+1;return power end,
 setAutoLockDisabled=function(v)calls[#calls+1]=v end}
''')
lua.execute((Path(__file__).resolve().parents[1] / 'source/awake.lua').read_text(encoding='utf-8'))
lua.execute('''
assert(#calls==1 and calls[1], 'full battery on USB must stay awake')
for i=1,300 do clock=i*1000/30;Awake.update() end
assert(#calls==1 and reads<=11,'unchanged USB must not reset the lock timer each frame')
clock=11000;power={USB=false,charging=false};Awake.update()
assert(#calls==2 and calls[2]==false,'unplug must restore automatic locking')
for i=1,300 do clock=11000+i*1000/30;Awake.update() end
assert(#calls==2,'battery-only polling must not continually reset the three-minute timer')
power={USB=true,charging=true};Awake.update(true)
assert(#calls==3 and calls[3], 'resume must immediately pick up USB')
power=nil;Awake.update(true);assert(#calls==3)
playdate.getPowerStatus=nil;Awake.update(true)
print('PASS: full battery on USB, unplug, stable timer, throttled polling, resume and unavailable API')
''')
