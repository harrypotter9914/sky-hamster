"""Real update paths: try each shortcut, return safely, migrate/reload lesson progress."""
from pathlib import Path

fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
prefix=source.split("load('engine')")[0]
helpers='function get(name)'+source.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0]

def boot(saved=None):
    env={'__file__':str(fixture)}
    exec(compile(prefix,str(fixture),'exec'),env)
    if saved is not None: env['lua'].globals().store.saved=env['lua'].table_from(saved,recursive=True)
    env['load']('main');env['lua'].execute('drainLoading()');env['lua'].execute(helpers)
    return env['lua']

def plain(value):
    return {k:plain(v) for k,v in value.items()} if hasattr(value,'items') else value

lua=boot()
lua.execute('''
frame({a=true});for i=1,60 do frame() end
assert(Guide.key()=='arrival');frame({a=true});assert(get('steeringMenu'))
frame({a=true});frame({a=true});assert(Guide.key()=='roll')
frame({a=true});assert(Guide.key()=='map')
local x,y,t,w=get('x'),get('y'),get('elapsed'),get('worldTime')
local function frozen() assert(get('x')==x and get('y')==y and get('elapsed')==t and get('worldTime')==w) end
frame({right=true});assert(Guide.key()=='map' and not get('briefing'),'wrong key stays in lesson')
frame({up=true});assert(get('overview') and Guide.trying=='map')
for i=1,60 do frame() end;frozen()
frame({left=true});frame({b=true})
assert(not get('overview') and Guide.key()=='map' and Guide.done.map and get('lesson'));frozen()
frame({a=true});assert(Guide.seen.map and Guide.key()=='help')
frame({left=true});assert(Guide.manual and Guide.trying=='help' and Guide.key()=='roll')
frame({a=true});assert(Guide.key()=='map')
frame({up=true});assert(not get('overview'),'nested shortcut practice must not overwrite return state')
frame({b=true});assert(not Guide.manual and Guide.key()=='help' and Guide.done.help);frozen()
-- Finishing the replay instead of cancelling also returns to its practice card.
frame({left=true});while Guide.manual do frame({a=true}) end
assert(Guide.key()=='help' and Guide.done.help and get('lesson'));frozen()
frame({a=true});assert(Guide.key()=='goal')
frame({right=true});assert(get('briefing') and Guide.trying=='goal')
frame({a=true});assert(get('infoPage')==2);frame({left=true});assert(get('infoPage')==1)
frame({b=true});assert(not get('briefing') and Guide.key()=='goal' and Guide.done.goal);frozen()
frame({a=true});assert(Guide.key()=='recenter')
accel={.2,.3,math.sqrt(.87)};frame({down=true});assert(Tilt.calibrating)
for i=1,90 do frame() end
assert(Tilt.ready and not Tilt.calibrating and Guide.done.recenter and Guide.key()=='recenter');frozen()
assert(math.abs(Tilt.nx-.2)<.01 and math.abs(Tilt.ny-.3)<.01)
frame({a=true});assert(not get('lesson') and store.saved.shortcutGuideRevision==1)
for key in pairs(Guide.tools) do assert(Guide.seen[key] and store.saved.guides[key]) end
-- Help is always replayable after first read, without marking more seen flags.
frame({left=true});assert(Guide.manual);frame({b=true});assert(not get('lesson'))
-- B cancels a practice even if its control page is the last manual page.
Guide.enter(get('course'),true);put('lesson',true);Guide.index=#Guide.queue
assert(Guide.key()=='recenter');frame({down=true});for i=1,90 do frame() end
frame({b=true});assert(not get('lesson') and not Guide.trying)
-- Leaving for home while inside a practice cleans up temporary return state.
Guide.enter(get('course'),true);put('lesson',true);Guide.index=3
assert(Guide.key()=='help');frame({left=true});menu['Title / settings']()
assert(get('title') and not Guide.trying and Guide.manual and Guide.key()=='help')
''')
saved=plain(lua.globals().store.saved)
fresh=boot(saved)
fresh.execute('''
for key in pairs(Guide.tools) do assert(Guide.seen[key]) end
Guide.enter(Courses[1]);assert(Guide.key()==nil,'read shortcuts should not repeat on every course')
''')
old=boot({'campaignRevision':5,'guideRevision':3,'jumpGuideRevision':1,'controlRevision':1,
          'level':12,'completed':{'1':True},'best':{'1':27},
          'guides':{'arrival':True,'roll':True,'jump':True},'options':{'steering':'screen'}})
old.execute('''
assert(get('level')==12 and get('completed')[1] and get('best')['1']==27 and Tilt.mode=='screen')
assert(not Guide.seen.jump,'updated A-fallback lesson should appear once')
Guide.enter({jump=true,mechanisms={},pads={}})
assert(Guide.key()=='map');for _,key in ipairs({'map','help','goal','recenter','jump'}) do assert(Guide.key()==key);Guide.advance() end
assert(Guide.key()==nil)
''')
print('PASS: four real shortcut practices, paused world, wrong-key rejection, nested-help protection, both replay returns, comfortable-grip recenter, seen persistence, home cleanup and legacy progress preservation')
