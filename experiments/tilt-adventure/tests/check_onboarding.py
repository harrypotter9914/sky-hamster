"""Persisted onboarding boundaries, preference saves and legacy compatibility."""
from pathlib import Path

f=Path(__file__).with_name('check_tilt.py')
s=f.read_text(encoding='utf-8')
prefix=s.split("load('engine')")[0]
helpers='function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0]
def boot(saved=None):
    env={'__file__':str(f)}
    exec(compile(prefix,str(f),'exec'),env)
    lua=env['lua']
    if saved is not None: lua.globals().store.saved=lua.table_from(saved,recursive=True)
    env['load']('main');lua.execute('drainLoading()');lua.execute(helpers)
    return lua
def plain(v):
    return {k:plain(x) for k,x in v.items()} if hasattr(v,'items') else v

lua=boot()
lua.execute('''
assert(Tilt.mode=='road' and not get('steeringChosen'))
-- Choosing in settings before ever starting does not skip the introduction.
frame({down=true});frame({a=true});for i=1,4 do frame({down=true}) end
frame({a=true});frame({left=true});frame({a=true})
assert(Tilt.mode=='screen' and not store.saved.steeringChosen)
frame({b=true});frame({up=true});frame({a=true})
for i=1,40 do frame() end
assert(Guide.key()=='arrival' and not get('steeringMenu'))
frame({a=true});assert(get('steeringMenu') and get('steeringChoice')==2)
assert(store.saved.guides.arrival and not store.saved.steeringChosen)
''')
interrupted=plain(lua.globals().store.saved)
lua=boot(interrupted)
lua.execute('''
frame({a=true});assert(get('startMenu'));frame({a=true})
for i=1,40 do frame() end
assert(get('steeringMenu') and get('steeringChoice')==2,'interrupted setup must resume')
frame({a=true});assert(get('steeringNotice') and store.saved.steeringChosen)
assert(store.saved.options.steering=='road')
''')
committed=plain(lua.globals().store.saved)
lua=boot(committed)
lua.execute('''
assert(Tilt.mode=='road' and get('steeringChosen'))
frame({a=true});frame({a=true});for i=1,40 do frame() end
assert(Guide.key()=='roll' and not get('steeringMenu'),'committed choice must survive boot')
''')
lua=boot({'campaignRevision':5,'guideRevision':3,'jumpGuideRevision':1,'controlRevision':1,
          'guides':{'arrival':True,'roll':True},'options':{'steering':'screen'},'level':1})
lua.execute("assert(Tilt.mode=='screen' and get('steeringChosen'),'existing deliberate choice must be preserved')")
print('PASS: fresh Road default, settings-before-start, goal-before-choice, interrupted setup resume, committed choice reload and legacy preference preservation')
