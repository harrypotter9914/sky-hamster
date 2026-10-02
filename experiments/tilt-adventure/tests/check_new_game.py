"""Production menu events: intentional campaign reset, cancellation, preferences and reload."""
from pathlib import Path

fixture = Path(__file__).with_name('check_tilt.py')
source = fixture.read_text(encoding='utf-8')
env = {'__file__': str(fixture)}
exec(compile(source.split("load('engine')")[0], str(fixture), 'exec'), env)
lua = env['lua']
lua.execute('''
store.saved={campaignRevision=5,controlRevision=1,guideRevision=3,jumpGuideRevision=1,
 level=12,completed={[1]=true,[4]=true},best={['1']=27},
 guides={arrival=true,roll=true,jump=true,control=true,cannon=true},
 options={effects=false,music=false,motion=false,gesture=false,steering='road'}}
''')
env['load']('engine')
lua.execute('function get(name)' + source.split('function get(name)', 1)[1].split('for i=1,40 do frame() end', 1)[0])
lua.execute('''
local original=store.saved
frame({down=true});frame({a=true})
assert(get('settings'))
for i=1,8 do frame({down=true}) end
assert(get('settingsChoice')==6)
frame({left=true});frame({right=true})
assert(not get('newGameConfirm') and store.saved==original and Tilt.mode=='road')
frame({a=true});assert(get('newGameConfirm') and get('newGameChoice')==1)
frame({a=true});assert(not get('newGameConfirm') and store.saved==original)
frame({a=true});frame({down=true});frame({b=true})
assert(not get('newGameConfirm') and get('settings') and store.saved==original)
frame({a=true});assert(get('newGameChoice')==1)
for i=1,20 do frame() end
assert(store.saved==original and get('level')==12 and get('elapsed')==0)
-- Only a deliberate selection followed by A commits the reset.
frame({down=true});frame({a=true})
assert(get('level')==1 and get('selected')==1 and get('lesson'))
assert(not get('settings') and not get('newGameConfirm') and not get('title'))
assert(get('elapsed')==0 and get('falls')==0 and not get('checkpoint'))
assert(get('vx')==0 and get('vy')==0 and not get('airborne'))
assert(next(get('completed'))==nil and next(get('best'))==nil)
assert(next(Guide.seen)==nil and Guide.key()=='arrival')
assert(store.saved.level==1 and next(store.saved.completed)==nil and next(store.saved.best)==nil)
assert(not Audio.effects and not Audio.musicEnabled and not UI.motion and not get('gesture'))
assert(Tilt.mode=='road' and store.saved.options.steering=='road')
assert(not store.saved.options.effects and not store.saved.options.gesture)
-- Later first encounters, including jump and mechanisms, are eligible again.
Guide.enter({jump=true,mechanisms={{kind='control'},{kind='cannon'}},pads={}})
local keys={};for _,k in ipairs(Guide.queue) do keys[k]=true end
assert(keys.arrival and keys.roll and keys.jump and keys.control and keys.cannon)
''')
# Simulate a fresh Lua/device boot from the serialized saved state.
saved = lua.globals().store.saved
def plain(value):
    if hasattr(value, 'items'):
        return {k: plain(v) for k, v in value.items()}
    return value
data = plain(saved)
fresh = {'__file__': str(fixture)}
exec(compile(source.split("load('engine')")[0], str(fixture), 'exec'), fresh)
fresh['lua'].globals().store.saved = fresh['lua'].table_from(data, recursive=True)
fresh['load']('engine')
fresh['lua'].execute('function get(name)' + source.split('function get(name)', 1)[1].split('for i=1,40 do frame() end', 1)[0])
fresh['lua'].execute('''
assert(get('level')==1 and next(get('completed'))==nil and next(get('best'))==nil)
assert(next(Guide.seen)==nil and Tilt.mode=='road' and not get('gesture'))
frame({a=true});assert(get('lesson') and Guide.key()=='arrival')
assert(not get('newGameConfirm'))
''')
print('PASS: six settings rows; A-only reset entry; default cancel; B cancel; no idle reset; explicit reset; preferences retained; first/later tutorials restored; fresh-boot persistence')
