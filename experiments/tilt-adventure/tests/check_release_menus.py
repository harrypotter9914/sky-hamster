"""Exercise real player menu events, locked courses and isolated workshop access."""
from pathlib import Path

fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
env={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0],str(fixture),'exec'),env)
lua=env['lua'];env['load']('engine')
lua.execute('function get(name)'+source.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute('''
function settingsPage()
 if not get('title') then menu['Title / settings']() end;frame({down=true});frame({a=true});assert(get('settings'))
end
function hiddenChord()
 frame({a=true,b=true},{a=true,b=true})
 for i=1,85 do frame(nil,{a=true,b=true}) end
end
-- This test starts with no save. The campaign has only its first route open.
assert(CampaignAccess.frontier==1 and not CampaignAccess.developer)
assert(CampaignAccess.allowed(1,{}) and not CampaignAccess.allowed(2,{}))
settingsPage();for i=1,4 do frame({down=true}) end
assert(get('settingsChoice')==5)
frame({right=true});assert(not get('steeringMenu') and Tilt.mode=='road')
frame({a=true});assert(get('steeringMenu') and get('steeringChoice')==2)
frame({left=true});assert(get('steeringChoice')==1 and Tilt.mode=='road')
for i=1,90 do frame() end
assert(get('elapsed')==0 and get('x')==Courses[1].start[1])
frame({b=true});assert(not get('steeringMenu') and get('settings') and Tilt.mode=='road')
frame({a=true});frame({right=true});frame({a=true})
assert(not get('steeringMenu') and Tilt.mode=='road' and store.saved.options.steering=='road')
frame({a=true});frame({left=true});frame({b=true});assert(Tilt.mode=='road')
frame({b=true});frame({up=true});frame({a=true})
assert(not get('startMenu') and not get('title'),'fresh Start enters course 1 directly')
drainLoading();put('lesson',false);Tilt.calibrating=false
-- A real finish trigger unlocks exactly the next route, retaining replay access.
put('x',Courses[1].goal[1]);put('y',Courses[1].goal[2]);frame()
assert(get('state')=='win' and CampaignAccess.frontier==2)
assert(store.saved.completed[1] and store.saved.unlockedThrough==2)
menu['Level select']();frame({right=true});assert(get('selected')==4)
local beforeLevel=get('level');local beforeTime=get('elapsed')
frame({a=true});assert(get('choosing') and get('level')==beforeLevel and get('elapsed')==beforeTime)
frame({left=true});frame({down=true});assert(get('selected')==2)
frame({a=true});assert(get('level')==2 and not get('choosing'))
-- Existing players can discover the new-game action from the home Start entry.
menu['Title / settings']();frame({a=true});assert(get('startMenu') and get('startChoice')==1)
frame({b=true});assert(get('title') and not get('startMenu'))
frame({a=true});frame({down=true});frame({a=true})
assert(get('newGameConfirm') and get('newGameChoice')==1)
local save=store.saved
frame({b=true});assert(get('startMenu') and not get('newGameConfirm') and store.saved==save)
frame({a=true});frame({down=true});frame({a=true})
assert(get('level')==1 and CampaignAccess.frontier==1 and next(get('completed'))==nil)
assert(Tilt.mode=='road' and store.saved.level==1 and store.saved.progressRevision==1)
assert(not get('steeringChosen') and not store.saved.steeringChosen)
drainLoading();for i=1,40 do frame() end
assert(Guide.key()=='arrival' and not get('steeringMenu'))
frame({a=true});assert(get('steeringMenu') and get('steeringChoice')==2)
assert(get('steeringReturn')=='game' and Guide.key()=='roll')
local x,y,elapsed=get('x'),get('y'),get('elapsed')
frame({left=true});frame({b=true})
assert(Guide.key()=='arrival' and not get('steeringMenu') and not get('steeringChosen'))
frame({a=true});assert(get('steeringChoice')==2,'reopened onboarding defaults to Road')
frame({left=true});frame({a=true})
assert(Tilt.mode=='screen' and store.saved.options.steering=='screen' and store.saved.steeringChosen)
assert(get('steeringNotice') and get('lesson') and Guide.key()=='roll')
for i=1,30 do frame() end
assert(get('x')==x and get('y')==y and get('elapsed')==elapsed,'setup must not move the ball')
frame({a=true});assert(not get('steeringNotice') and Guide.key()=='roll')
frame({a=true});assert(Guide.key()=='map' and not get('steeringMenu'))
for _,key in ipairs({'map','help','goal','recenter'}) do assert(Guide.key()==key);frame({a=true}) end
assert(not get('lesson') and not get('steeringMenu'))
frame({left=true});assert(Guide.manual and get('lesson'))
frame({b=true});assert(not get('steeringMenu'),'manual help does not restart onboarding')
-- The hidden settings chord is one-shot while held, and never triggers an item.
settingsPage();local effects=Audio.effects;local normalGuides=Guide.seen
hiddenChord();assert(CampaignAccess.developer and Audio.effects==effects and get('settings'))
for i=1,100 do frame(nil,{a=true,b=true}) end
assert(CampaignAccess.developer,'held chord must not toggle repeatedly')
frame();frame({b=true});frame({up=true});frame({a=true})
if get('startMenu') then frame({a=true}) end
menu['Level select']();put('selected',53);frame({a=true});assert(get('level')==53)
put('lesson',false);Tilt.calibrating=false
Guide.seen.cannon=true;put('x',Courses[53].goal[1]);put('y',Courses[53].goal[2]);frame()
assert(get('state')=='win' and not get('completed')[53] and not get('best')['53'])
assert(store.saved.level==1 and store.saved.unlockedThrough==1 and not store.saved.guides.cannon)
settingsPage();hiddenChord();assert(not CampaignAccess.developer and get('level')==1 and Guide.seen==normalGuides)
frame();assert(not CampaignAccess.allowed(53,get('completed')))
-- Old free-selection saves retain their current point and old completed routes.
CampaignAccess.init({level=12},53);assert(CampaignAccess.frontier==12)
assert(CampaignAccess.allowed(12,{}) and not CampaignAccess.allowed(13,{}))
CampaignAccess.init({progressRevision=1,level=53,unlockedThrough=2},53)
assert(CampaignAccess.frontier==2 and not CampaignAccess.developer)
assert(CampaignAccess.allowed(9,{[8]=true}) and not CampaignAccess.allowed(10,{[8]=true}))
print('PASS: paired steering commit/cancel, home continue/new-game confirmation, next-route unlock, locked launch rejection, save migration, one-shot hidden chord and isolated developer progress/tutorials')
''')
