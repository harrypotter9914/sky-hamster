from pathlib import Path
import json

f=Path(__file__).with_name('check_tilt.py')
s=f.read_text(encoding='utf-8');env={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0],str(f),'exec'),env)
env['load']('main')
lua=env['lua']
lua.execute('drainLoading()')
lua.execute('function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute('''
assert(get('title') and not get('settings'))
frame({a=true});assert(get('level')==1 and get('lesson'))
for i=1,40 do frame() end
assert(Tilt.ready and Guide.key()=='arrival')
local function readLessons()
 while get('lesson') do frame({a=true}) end
end
assert(Tilt.mode=='road')
frame({a=true});assert(get('steeringMenu') and get('steeringChoice')==2)
frame({a=true});assert(get('steeringNotice') and store.saved.steeringChosen)
frame({a=true});assert(not get('steeringNotice') and Guide.key()=='roll')
readLessons();assert(Guide.seen.arrival and Guide.seen.roll)
-- In-game map/help/route notes all return to the current run.
local x,y,t=get('x'),get('y'),get('elapsed')
frame({up=true});assert(get('overview'));frame({b=true})
assert(not get('overview') and get('x')==x and get('elapsed')==t)
frame({left=true});assert(get('lesson') and Guide.manual);frame({b=true})
assert(not get('lesson') and get('x')==x)
frame({right=true});assert(get('briefing'));frame({right=true});frame({b=true})
assert(not get('briefing') and get('level')==1)
local oldLevel=get('level');menu['Level select']();frame({right=true});frame({b=true})
assert(get('level')==oldLevel and not get('choosing'))
-- Clear a real trigger, not a direct write to the campaign table.
local function finish()
 local c=get('course');put('x',c.goal[1]);put('y',c.goal[2]);put('vx',0);put('vy',0)
 put('airborne',false);put('ballHeight',c:height(c.goal[1],c.goal[2]));frame()
 assert(get('state')=='win' and store.saved.completed[get('level')])
 assert(store.saved.best[tostring(get('level'))]>=0)
end
finish();assert(store.saved.level==1);local record=store.saved.best['1']
frame({b=true});assert(get('state')=='play' and get('elapsed')==0 and get('level')==1)
for i=1,20 do frame() end
finish();assert(store.saved.best['1']<=record)
frame({a=true});assert(get('level')==2 and not get('title'))
for i=1,40 do frame() end;readLessons()
-- A real off-road loss, death panel, retry and retained time/death count.
put('x',-200);put('y',-200);put('vx',0);put('vy',0);frame()
assert(get('state')=='fall' and get('falls')==1)
for i=1,30 do frame() end
assert(get('state')=='dead')
local t=get('elapsed');frame({a=true})
assert(get('state')=='play' and get('falls')==1 and get('elapsed')==t)
assert(get('x')==get('course').start[1])
-- Checkpoint loss returns to the saved platform within the same run.
selectReady(Courses.indexById['legacy-4']);readLessons()
local c=get('course');local p=c.checkpoints[1]
assert(p);put('x',p[1]);put('y',p[2]);put('ballHeight',c:height(p[1],p[2]));frame()
assert(get('checkpoint')==1)
put('x',-200);put('y',-200);put('vx',0);put('vy',0);frame()
for i=1,30 do frame() end;assert(get('state')=='dead');frame({a=true})
assert(get('x')==p[1] and get('y')==p[2] and get('checkpoint')==1)
-- Campaign ending and routes/title navigation.
selectReady(#Courses);readLessons();finish();frame({a=true})
assert(get('ending'));frame({b=true});assert(get('choosing'))
frame({b=true});assert(not get('choosing') and get('state')=='win')
frame({a=true});assert(get('ending'));frame({a=true});assert(get('title'))
-- Pause persists options and campaign state for a genuine fresh boot.
playdate.gameWillPause()
assert(store.saved.level==#Courses and store.saved.completed[#Courses])
''')
def plain(v):
 return {k:plain(x) for k,x in v.items()} if hasattr(v,'items') else v
data=plain(lua.globals().store.saved)
env2={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0],str(f),'exec'),env2)
lua2=env2['lua'];lua2.globals().store.saved=lua2.table_from(data,recursive=True)
env2['load']('main');lua2.execute('drainLoading()')
lua2.execute('function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua2.execute('''
assert(get('title') and get('level')==#Courses and get('completed')[#Courses])
frame({a=true});assert(get('startMenu'));frame({a=true});assert(get('level')==#Courses and not get('title'))
''')
print('PASS: real main startup, first tutorials, map/help/goal/cancel, win/next/retry, actual falling/death, checkpoint retry, ending routes/title, pause-save and fresh boot continuation')
