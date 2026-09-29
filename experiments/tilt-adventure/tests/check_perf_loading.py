"""Check the generated benchmark's cooperative loader with mocked device I/O.

Build with build-perf.ps1 -All -Routes 50,51,52,53 or -Survey / -Fields first. This verifies control
flow and report completeness only; its synthetic clock cannot measure FPS.
"""
from pathlib import Path

fixture = Path(__file__).with_name('check_tilt.py')
source = fixture.read_text(encoding='utf-8')
scope = {'__file__': str(fixture)}
exec(compile(source.split("load('engine')")[0], str(fixture), 'exec'), scope)
scope['root'] = fixture.resolve().parents[3] / 'builds/tilt-perf-source'
lua = scope['lua']
messages = []
lua.globals()['print'] = lambda *args: messages.append(' '.join(map(str, args)))
lua.execute('playdate.getStats=function() return nil end')
scope['load']('main')
lua.execute('''
local loadingFrames=0
for i=1,40000 do
 clock=clock+1000/30
 playdate.update()
 if Loading.busy then loadingFrames=loadingFrames+1 end
 if store.saved and store.saved.error then error(store.saved.error) end
 if store.saved and store.saved.complete then break end
end
assert(store.saved and store.saved.complete,'benchmark never completed')
local expected=0;expectedLoads=0
for n,c in ipairs(Courses) do
 local included=not Bench.routes
 for _,route in ipairs(Bench.routes or {}) do if route==n then included=true end end
 if included then
  expectedLoads=expectedLoads+1;Curriculum.ensure(c)
  if Bench.fields then
   expected=expected+3
   for _,m in ipairs(c.mechanisms or {}) do if m.kind=='fan' or m.kind=='magnet' then expected=expected+2 end end
   for _,p in ipairs(c.pads or {}) do if p.kind=='fan' then expected=expected+1 end end
  elseif Bench.survey then expected=expected+3+((#(c.mechanisms or {})>0 or #(c.pads or {})>0) and 1 or 0)
  else expected=expected+4+#(c.mechanisms or {})+#(c.pads or {}) end
  Curriculum.release(c)
 end
end
assert(#store.saved.stages==expected,'a scene was omitted')
assert(loadingFrames>8,'long-course loading did not yield across frames')
for _,stage in ipairs(store.saved.stages) do
 assert(stage.frames==stage.scenario.frames-1,'loading contaminated measured frame count')
end
''')
assert sum(message.startswith('BENCH BEGIN ') for message in messages) == len(lua.globals().store.saved.stages)
assert sum(message.startswith('LOAD READY ') for message in messages) == lua.globals().expectedLoads
print(f'PASS: {lua.globals().expectedLoads} course loads yield across frames; all {len(lua.globals().store.saved.stages)} scenes complete; loading frames excluded from measurements (synthetic clock, not FPS evidence)')
