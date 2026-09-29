"""Check the generated benchmark's cooperative loader with mocked device I/O.

Build with build-perf.ps1 -All -Routes 50,51,52,53 first. This verifies control
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
assert(#store.saved.stages==156,'a scene was omitted')
assert(loadingFrames>100,'long-course loading did not yield across frames')
for _,stage in ipairs(store.saved.stages) do
 assert(stage.frames==stage.scenario.frames-1,'loading contaminated measured frame count')
end
''')
assert sum(message.startswith('BENCH BEGIN ') for message in messages) == 156
assert sum(message.startswith('LOAD READY ') for message in messages) == 4
print('PASS: four course loads yield across frames; all 156 scenes complete; loading frames excluded from measurements (synthetic clock, not FPS evidence)')
