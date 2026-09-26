"""Rule and real update-loop tests. Run with Python + lupa.lua54."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
# Reuse the existing device-I/O mock, not the full-edition test expectations.
bootstrap = (root / 'tests/run_checks.py').read_text().split("load('main')", 1)[0]
for rule in ('speed', 'throttle', 'brake', 'latch'):
    env = {'__file__': str(root / 'tests/run_checks.py')}
    exec(bootstrap, env)
    lua, load = env['lua'], env['load']
    load('build')
    lua.execute(f"Build.classroom=true;Build.variant='{rule}'")
    load('main')
    lua.execute('''
    assert(#Courses==2 and not Courses[1].jump and not Courses[2].jump)
    function state(name)
     for i=1,100 do local n,v=debug.getupvalue(playdate.update,i);if n==name then return v end end
     error(name)
    end
    frame({a=true})
    assert(not state('lesson'))
    frame({}, {right=true,a=true}, 90)
    assert(state('vx')^2+state('vy')^2>0,'real update receives variant input')
    frame({b=true})
    assert(state('falls')==0 and state('controls').power==0,'retry resets controls')
    menu['Level select']();frame({down=true});frame({a=true})
    assert(state('level')==2,'optional slope selectable')
    c=Physics.newControls()
    Physics.controls(c,270,1,0,1/30)
    assert(c.charge==0,'no jump charge')
    ''')
    if rule in ('speed', 'throttle'):
        lua.execute('''
        local p=c.power;Physics.controls(c,0,1,0,2);assert(c.power==p,'dial persists')
        Physics.controls(c,-135,1,0,1/30);assert(c.power<p,'counterclockwise reduces dial')
        ''')
    if rule == 'speed':
        lua.execute('''
        local v=0;for i=1,600 do v=Physics.step(v,0,1,0,0.5,0,0,1/120) end
        assert(math.abs(v-42.5)<0.01,'target speed settles')
        ''')
    elif rule == 'throttle':
        lua.execute('''
        local a=Physics.step(100,0,-1,0,0,0,0,0.1)
        local b=Physics.step(100,0,0,0,0,0,0,0.1)
        assert(a<b-20,'extra opposite brake')
        assert(Physics.step(0,0,0,0,0,-0.5,0,0.1)>0,'zero-thrust gravity')
        ''')
    elif rule == 'brake':
        lua.execute('''
        c.power=0.9;c.lastX=1;Physics.controls(c,0,-1,0,0.01)
        assert(c.power>0.8,'no reversal latch')
        Physics.controls(c,-30,1,0,0.1)
        local v=Physics.step(30,0,1,0,c.power,0,0,0.1)
        assert(v<15 and v>=0,'active brake slows without reversing')
        Physics.controls(c,0,1,0,0.1);assert(c.brake==0,'brake stops on release')
        ''')
    else:
        lua.execute('''
        c.power=0.9;c.lastX=1;c.lastY=0
        Physics.controls(c,0,-1,0,0.01);assert(c.power==0 and c.flash>0,'high power latch')
        c.power=0.4;Physics.controls(c,0,1,0,0.01);assert(c.power==0.4,'low power turn')
        Physics.controls(c,0,1,0,2);assert(c.power==0,'idle power decays')
        ''')
    print('PASS:', rule, 'rules, actual update, retry and slope selection')
