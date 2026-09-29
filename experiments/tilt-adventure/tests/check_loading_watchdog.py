"""Saved long-course startup and cooperative generation/occlusion regressions.

Mocked device I/O verifies scheduling, not hardware timing or memory usage.
"""
from pathlib import Path

fixture = Path(__file__).with_name('check_tilt.py')
source = fixture.read_text(encoding='utf-8')
scope = {'__file__': str(fixture)}
exec(compile(source.split("load('engine')")[0], str(fixture), 'exec'), scope)
lua = scope['lua']
lua.execute('store.saved={campaignRevision=3,level=53,completed={},best={}}')
scope['load']('main')
lua.execute('''
assert(not Courses[53].materialized,'saved expedition built during import')
for i=1,300 do clock=clock+1000/30;playdate.update();if not Loading.busy then break end end
assert(not Loading.busy and not Courses[53].materialized,'title boot generated the saved expedition')
pressed={a=true};playdate.update();pressed={}
assert(Loading.busy,'Start did not schedule loading')
local phases={};local frames=0
while Loading.busy and frames<3000 do
 clock=clock+1000/30;playdate.update();frames=frames+1
 phases[Loading.label]=(phases[Loading.label] or 0)+1
end
assert(not Loading.busy and Courses[53].materialized,'saved expedition did not finish loading')
assert((phases['PLANNING THE ROUTE'] or 0)>=28,'geometry did not yield by encounter')
assert((phases['FITTING THE LANDINGS'] or 0)>1,'landing scan did not yield')
assert((phases['PREPARING ROAD SHADOWS'] or 0)>1,'occlusion preparation did not yield')
assert(#Courses[53].occlusionCache==#Courses[53].tiles,'partial occlusion cache')
print('PASS: saved level 53 defers geometry until Start; route, landing and shadow preparation yield over '..frames..' loading frames; complete occlusion cache')
''')
