"""Production context menus: usable actions, developer entry and exact returns."""
from pathlib import Path
fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8');env={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0],str(fixture),'exec'),env)
lua=env['lua'];env['load']('engine')
lua.execute('function get(name)'+source.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute('''
if not capture then capture=function() end end
function expectMenu(...)
 local expected={};for _,key in ipairs({...}) do expected[key]=true end
 local count=0;for key in pairs(menu) do assert(expected[key],'unexpected menu '..key);count=count+1 end
 for key in pairs(expected) do assert(menu[key],'missing menu '..key) end
 assert(count<=3)
end
function hiddenChord()
 frame({a=true,b=true},{a=true,b=true});for i=1,85 do frame(nil,{a=true,b=true}) end
 frame()
end
frame();expectMenu();capture('title-ordinary')
local unchanged=menu;for i=1,30 do frame() end;assert(menu==unchanged,'stable context must reuse menu items')
frame({down=true});frame({a=true});assert(get('settings'));expectMenu('Title / settings')
for i=1,8 do frame({down=true}) end
assert(get('settingsChoice')==5 and not get('newGameConfirm'));capture('settings-ordinary')
local initialGuides=Guide.seen;hiddenChord()
assert(CampaignAccess.developer);expectMenu('Level select','Title / settings');capture('settings-developer')
frame({down=true});assert(get('settingsChoice')==5,'developer entry remains hidden')
menu['Level select']();frame();assert(get('choosing') and not get('settings'));expectMenu('Title / settings');capture('developer-selector')
put('selected',53);frame({b=true})
assert(get('settings') and get('settingsChoice')==5 and not get('choosing'))
expectMenu('Level select','Title / settings')
frame({b=true});assert(get('title'));expectMenu('Level select')
menu['Level select']();frame({b=true});assert(get('title') and not get('choosing'));expectMenu('Level select')
-- Launching from developer settings closes the parent modal, allowing gameplay.
frame({a=true});assert(get('settings'))
menu['Level select']();put('selected',53);frame({a=true});drainLoading()
assert(get('level')==53 and not get('settings') and not get('title') and not get('choosing'))
put('lesson',false);Tilt.calibrating=false;frame()
expectMenu('Level select','Map / pause','Title / settings');capture('playing')
local staleSelect=menu['Level select'];local staleMap=menu['Map / pause']
local x,y,time=get('x'),get('y'),get('elapsed')
menu['Map / pause']();frame();expectMenu('Level select','Resume game','Title / settings');capture('map')
assert(get('overview') and get('x')==x and get('y')==y and get('elapsed')==time)
menu['Resume game']();assert(not get('overview'))
expectMenu('Level select','Map / pause','Title / settings')
frame({left=true});assert(Guide.manual and get('lesson'));expectMenu('Title / settings')
staleSelect();assert(not get('choosing'),'stale selector must reject help context')
frame({b=true});frame({right=true});assert(get('briefing'));expectMenu('Title / settings')
frame({b=true});put('state','dead');frame();expectMenu('Level select','Title / settings')
menu['Level select']();frame({b=true});assert(get('state')=='dead' and not get('choosing'))
put('state','win');frame();expectMenu('Level select','Title / settings')
put('ending',true);frame();expectMenu('Level select','Title / settings')
menu['Level select']();frame({b=true});assert(get('ending') and not get('choosing'))
menu['Title / settings']();expectMenu('Level select')
-- An old callback cannot open a map on the home screen.
staleMap();assert(not get('overview') and get('title'))
frame({down=true});frame({a=true});hiddenChord()
assert(not CampaignAccess.developer and get('level')==1 and Guide.seen==initialGuides)
assert(not CampaignAccess.allowed(53,get('completed')))
assert(store.saved==nil or store.saved.level==1)
expectMenu('Title / settings');assert(get('settingsChoice')<=5)
for i=1,8 do frame({down=true}) end;assert(get('settingsChoice')==5)
frame({b=true});frame({up=true});Guide.seen.roll=true;frame({a=true})
assert(get('startMenu'));expectMenu('Title / settings')
frame({down=true});frame({a=true});assert(get('newGameConfirm'));expectMenu('Title / settings')
frame({b=true});frame({b=true});expectMenu()
-- No actions appear while the cooperative loader owns the game.
Loading.begin(function() Loading.checkpoint(1,'READY') end,'MENU TEST')
get('syncSystemMenu')();expectMenu();staleSelect();staleMap()
assert(not get('choosing') and not get('overview'))
drainLoading();frame();expectMenu()
playdate.gameWillPause();expectMenu()
assert(store.saved.level==1 and store.saved.unlockedThrough==1 and not store.saved.completed[53])
print('PASS: context-specific menus, maximum three actions, stable-item reuse, hidden developer access, both selector returns, course 53 launch, map resume, loading/death/help/goal/ending states and protected normal progress')
''')
