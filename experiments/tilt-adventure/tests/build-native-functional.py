"""Build an isolated hardware assertion runner from production menu regressions.

Runs real SDK drawing/audio/datastore, with scripted input and explicit placements.
Does not substitute for physical gesture feel or a human campaign playthrough.
"""
from pathlib import Path
import ast, hashlib, json, re, shutil, subprocess, sys

here = Path(__file__).resolve().parent
source = here.parent / 'source'
repo = here.parents[2]
conditions_only = '--conditions-only' in sys.argv
smoke = '--stations-only' in sys.argv or conditions_only
package_name='native-functional-smoke' if smoke else 'native-functional'
qa = repo / ('builds/'+package_name+'-source')
qa.mkdir(parents=True, exist_ok=True)
shutil.copytree(source, qa, dirs_exist_ok=True)

def chunks(name):
    tree = ast.parse((here/name).read_text(encoding='utf-8'))
    return [node.args[0].value for node in ast.walk(tree)
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
            and node.func.attr == 'execute' and node.args
            and isinstance(node.args[0], ast.Constant) and isinstance(node.args[0].value, str)]

menus = chunks('check_release_menus.py')[-1]
loop = chunks('check_player_loop.py')[1]
# The reset preceding this suite has written a native save. The real home menu
# therefore offers Continue; acknowledge it before asserting the arrival page.
loop = loop.replace("frame({a=true});assert(get('level')==1 and get('lesson'))", "frame({a=true});if get('startMenu') then frame({a=true}) end;assert(get('level')==1 and get('lesson'))")
loop = loop.replace("assert(get('ending'));frame({b=true})", "assert(get('ending'));frame();capture('ending');frame({b=true})")
lessons = chunks('check_lesson_controls.py')[-1]
wind = chunks('check_fields.py')[-1]
ring = chunks('check_bumper_ring.py')[-1].split('Audio.enabled=true',1)[0]
# Yield between small angle batches to respect the physical-device watchdog.
ring = ring.replace("for angle=0,359 do", "for angle=0,359 do\n if angle%12==0 then frame() end")
sensor_source = (here/'check_tilt.py').read_text(encoding='utf-8')
sensor = 'function sensorForForce'+sensor_source.split('function sensorForForce',1)[1].split('for i=1,40 do frame() end',1)[0]
tests = menus + '\n' + loop + lessons + wind
names = sorted(set(re.findall(r"(?:get|put)\('([^']+)'", tests)) | {'selectLevel', 'startNewGame','titleChoice','gesture','jumpZ','rollAngle'})
engine = (source/'engine.lua').read_text(encoding='utf-8')
getters = '\n'.join(f" if name=='{name}' then return {name} end" for name in names)
setters = '\n'.join(f" if name=='{name}' then {name}=value;return end" for name in names if name not in {'selectLevel','startNewGame'})
(qa/'engine.lua').write_text(engine + '\nfunction get(name)\n' + getters + "\n error('missing '..name)\nend\nfunction put(name,value)\n" + setters + "\n error('missing '..name)\nend\n", encoding='utf-8')
shutil.copyfile(source/'main.lua', qa/'productionmain.lua')
reset = '''
frame();CampaignAccess.developer=false;Guide.seen={};
get('startNewGame')();drainLoading();put('title',true);put('titleChoice',1);put('lesson',true)
put('steeringMenu',false);put('steeringNotice',false);put('startMenu',false)
'''
toggles = '''
settingsPage()
for row=1,4 do
 put('settingsChoice',row)
 -- Explicit values avoid boolean-and/or fallthrough when the value is false.
 local function flag()
  if row==1 then return Audio.effects elseif row==2 then return Audio.musicEnabled elseif row==3 then return UI.motion else return get('gesture') end
 end
 local before=flag();frame({a=true});assert(flag()==not before,'setting did not toggle '..row)
 capture('setting-'..row)
 frame({a=true});assert(flag()==before,'setting did not restore '..row)
 if row==2 then assert(Audio.players.music:isPlaying()==Audio.musicEnabled,'music player state disagrees') end
end
frame({b=true})
local stored=nativeRead('native-functional-progress')
assert(stored.options.effects==Audio.effects and stored.options.music==Audio.musicEnabled and stored.options.motion==UI.motion and stored.options.gesture==get('gesture'))
mark('four-settings-toggle-roundtrips-native-save-and-music-state')
'''
stations = '''
for _,spec in ipairs({{'legacy-15','bridge'},{'onboard-turn','bridge'},{'lift-school','lift'},{'crank-ferry','slider'},{'wind-dial','fan'},{'legacy-16','cannon'},{'extend-school','extend'},{'switch-school','switch'}}) do
 selectReady(Courses.indexById[spec[1]]);put('lesson',false);put('title',false)
 local c=get('course');local p
 for _,candidate in ipairs(c.pads) do if candidate.kind==spec[2] then p=candidate;break end end
 assert(p,'station missing '..spec[1])
 local function place()
  put('x',p.x);put('y',p.y);put('vx',0);put('vy',0);put('airborne',false)
  local height=Mechanisms.floor(c,p.x,p.y,0);put('ballHeight',height);put('jumpZ',height)
  Tilt.power=0;Tilt.dx,Tilt.dy=0,0
 end
 place();frame();assert(Dock.active==p and Dock.status()=='LOCKED','cannot acquire '..spec[1])
 local angle=p.angle;frame(nil,nil,p.kind=='switch' and 220 or 60)
 assert(p.angle~=angle,'crank ignored '..spec[1]);capture('station-'..spec[1])
 local stopped=p.angle;frame();assert(p.angle==stopped,'crank moves while stopped '..spec[1])
 frame(nil,nil,p.kind=='switch' and -220 or -60)
 local expected=p.kind=='cannon' and math.max(-math.pi/3,stopped-math.pi/3) or angle
 assert(math.abs(p.angle-expected)<.001,'reverse crank mismatch '..spec[1])
 frame({b=true});assert(not Dock.active and Dock.blocked==p and Dock.status()=='UNLOCKED','B did not release '..spec[1])
 place();frame();assert(not Dock.active,'release immediately redocks '..spec[1])
 -- Explicitly visit outside the exclusion radius, then return. The production
 -- Dock method controls re-entry; placements are labelled as scripted fixtures.
 Dock.update(c,p.x+40,p.y,0,0,false,0,false,false);assert(not Dock.blocked)
 place();frame();assert(Dock.active==p,'return did not redock '..spec[1]);frame({b=true})
 mark('station-forward-stop-reverse-B-exclusion-reentry/'..spec[1])
 if p.kind=='lift' or p.kind=='slider' or p.kind=='extend' then
  place();Dock.blocked=nil;frame();frame(nil,nil,10000)
  local m=p.target
  if p.kind=='lift' then assert(m.elevation==m.maxHeight and get('ballHeight')==m.maxHeight)
  elseif p.kind=='slider' then assert(m.progress==1 and p.x==m.toX and p.y==m.toY)
  else assert(m.w==m.maxWidth) end
  frame(nil,nil,-20000)
  if p.kind=='lift' then assert(m.elevation==m.minHeight and get('ballHeight')==m.minHeight)
  elseif p.kind=='slider' then assert(m.progress==0)
  else assert(m.w==16) end
  frame({b=true});mark('station-endpoint-clamps/'..spec[1])
 end
end
'''
conditions='''
-- The actual production loop carries a resting ball without false rolling.
for _,id in ipairs({'legacy-10','legacy-11'}) do
 selectReady(Courses.indexById[id]);put('lesson',false);put('title',false)
 local c=get('course');local m=c.mechanisms[1]
 local t=(m.period or 10)*.28-(m.phase or 0);local cx,cy,a=Mechanisms.pose(m,t)
 local px,py=cx+8*math.cos(a),cy+8*math.sin(a)
 put('worldTime',t);put('x',px);put('y',py);put('vx',0);put('vy',0)
 put('ballHeight',Mechanisms.floor(c,px,py,t));put('airborne',false);put('rollAngle',1)
 Dock.active=nil;Dock.blocked=nil;accel={0,0,1}
 for i=1,8 do frame() end
 assert(get('state')=='play' and not get('airborne'))
 assert(math.abs(get('x')-px)+math.abs(get('y')-py)>1,'platform stationary')
 assert(math.abs(get('rollAngle')-1)<.000001,'carried ball falsely rolls '..id)
 put('vx',25);frame();assert(math.abs(get('rollAngle')-1)>.01)
 mark('automatic-platform-relative-roll/'..id)
end
-- Native collision/force contracts with labelled synthetic mechanism fixtures.
local c={lookup={['0,0']=true},mechanisms={},height=function()return 0 end}
assert(Footing.query(c,40.99,16,0) and not Footing.query(c,41.01,16,0))
assert(Footing.query(c,38,38,0) and not Footing.query(c,39,39,0))
for _,gap in ipairs({1,8,16,18,19,24}) do
 c.mechanisms={{kind='ferry',manual=true,x=32+gap+16,y=16,toX=32+gap+16,toY=16,w=32,h=32}}
 local complete=true
 for step=0,100 do if not Footing.query(c,32+gap*step/100,16,0) then complete=false end end
 assert(complete==(gap<=18),'diameter seam threshold '..gap);frame()
end
local gate={kind='gate',x=0,y=0,w=16,h=64,period=4,openFor=.4,wallHeight=45}
c.mechanisms={gate}
local x,y,vx,vy,hit=Mechanisms.collide(c,-10,0,100,0,0,2,.01)
assert(hit and x<=-17 and vx<=0)
x,y,vx,vy,hit=Mechanisms.collide(c,-10,0,100,0,0,.5,.01);assert(not hit and vx==100)
x,y,vx,vy,hit=Mechanisms.collide(c,-10,0,100,0,80,2,.01);assert(not hit)
assert(Passage.state(gate,.5) and not Passage.state(gate,2))
local trap={kind='trap',period=4,openFor=.4}
assert(not Passage.state(trap,.5) and Passage.state(trap,2) and not Passage.state(trap,3.8))
local belt={kind='conveyor',x=0,y=0,w=128,h=64,angle=math.pi/2}
c.mechanisms={belt};vx,vy=Mechanisms.wind(c,0,0,0,0,0,.1,0);assert(vy>0 and math.abs(vx)<.001)
vx,vy=Mechanisms.wind(c,0,0,0,0,10,.1,0);assert(vx==0 and vy==0)
local jet={kind='jet',x=0,y=0,w=128,h=64,angle=math.pi/2,period=4}
-- Force indexing assumes course mechanisms are immutable. Use a fresh course
-- fixture instead of replacing an already-indexed belt with a jet.
c={mechanisms={jet},height=function()return 0 end};vx,vy=Mechanisms.wind(c,0,0,0,0,0,.1,0);assert(vy>10)
vx,vy=Mechanisms.wind(c,0,0,0,0,0,.1,3);assert(vx==0 and vy==0)
assert(not Passage.state(jet,0) and Passage.state(jet,2))
local r={0,0,16,32}
assert(WindContact.fraction(r,-20,0,400,0,.1)>0 and WindContact.fraction(r,-20,50,400,0,.1)==0)
local magnet={x=0,y=0,radius=140}
vx,vy=WindContact.magnet(magnet,-220,30,900,0,.5);assert(vx~=900 or vy~=0)
vx,vy=WindContact.magnet(magnet,210,0,0,0,.01);assert(vx==0 and vy==0)
vx,vy=WindContact.magnet(magnet,183,0,0,0,1/120);assert(vx<-.2 and math.abs(vx)<=121/120)
mark('seam-diameter-gate-air-clearance-trap-conveyor-steam-fast-wind-magnet-boundaries')
-- Both input paths invoke the actual jump update. No artificial launch state.
for _,mode in ipairs({'screen','road'}) do for _,method in ipairs({'lift','button'}) do
 selectReady(Courses.indexById['legacy-5']);put('lesson',false);put('title',false)
 Tilt.mode=mode;put('gesture',true);accel={0,0,1}
 Tilt.startCalibration();for i=1,65 do frame() end
 local px,py=get('x'),get('y')
 if method=='lift' then accel={0,0,1.55};frame() else frame({a=true}) end
 assert(get('airborne'),'jump input failed '..mode..'/'..method)
 accel={0,0,1};for i=1,90 do if not get('airborne') then break end;frame() end
 assert(get('state')=='play' and not get('airborne') and math.abs(get('x')-px)<.01 and math.abs(get('y')-py)<.01)
 mark('real-update-jump-land/'..mode..'/'..method)
end end
'''
prefix = '''
-- Isolated production-input tests on real hardware; never writes user progress.
local nativeRead,nativeWrite=playdate.datastore.read,playdate.datastore.write
local priorReport=nativeRead('native-functional-report')
store={saved=priorReport and priorReport.awaitingRestart and nativeRead('native-functional-progress') or nil}
playdate.datastore.read=function(name,...) if name=='tilt-progress' then return store.saved end;return nativeRead(name,...) end
playdate.datastore.write=function(value,name,...)
 if name=='tilt-progress' then store.saved=value;return nativeWrite(value,'native-functional-progress',...) end
 return nativeWrite(value,name,...)
end
local realMenu=playdate.getSystemMenu()
menu={}
playdate.getSystemMenu=function() return {
 addMenuItem=function(_,name,fn) menu[name]=fn;return realMenu:addMenuItem(name,fn) end,
 removeAllMenuItems=function() menu={};realMenu:removeAllMenuItems() end
} end
accel={0,0,1};local pressed,held={},{}
playdate.readAccelerometer=function() return table.unpack(accel) end
playdate.buttonJustPressed=function(k) return pressed[k] or false end
playdate.buttonIsPressed=function(k) return held[k] or false end
local crank=0
playdate.getCrankChange=function() local result=crank;crank=0;return result end
local bootStart=playdate.getCurrentTimeMilliseconds()
import 'productionmain'
local nativeUpdate=playdate.update
local report={version='0.12.9',scope='TEST_SCOPE',device=playdate.getStats()~=nil,checks={},complete=false,scriptedInputs=true}
local runner
local preview
local keys={a=playdate.kButtonA,b=playdate.kButtonB,left=playdate.kButtonLeft,right=playdate.kButtonRight,up=playdate.kButtonUp,down=playdate.kButtonDown}
function drainLoading() while Loading.busy do coroutine.yield() end end
function frame(p,h,c)
 pressed={};held={};for key,value in pairs(p or {}) do pressed[keys[key]]=value end
 for key,value in pairs(h or {}) do held[keys[key]]=value end
 crank=c or 0;coroutine.yield();pressed={};drainLoading()
end
function selectReady(n)
 get('selectLevel')(n);drainLoading();accel={0,0,1};for i=1,60 do frame() end
end
SENSOR_HELPER
local function mark(name)
 report.checks[#report.checks+1]=name;nativeWrite(report,'native-functional-report');print('FUNCTION PASS '..name)
end
local function capture(name)
 -- getDisplayImage is the previous displayed frame. WorkingImage captures
 -- the scene just rendered, keeping each tutorial pose labelled correctly.
 local image=playdate.graphics.getWorkingImage()
 nativeWrite(report,'native-functional-report')
 playdate.datastore.writeImage(image,'native-functional-'..name..'.gif')
end
local co=coroutine.create(function()
 drainLoading();report.coldBootMS=playdate.getCurrentTimeMilliseconds()-bootStart
 report.bootCourse=get('level');for i=1,40 do frame() end
 if priorReport and priorReport.awaitingRestart then
  assert(get('title') and get('level')==#Courses and get('completed')[#Courses])
  frame({a=true});assert(get('startMenu'))
  local continueStart=playdate.getCurrentTimeMilliseconds()
  frame({a=true});drainLoading()
  report.continueLoadMS=playdate.getCurrentTimeMilliseconds()-continueStart
  assert(get('level')==#Courses and not get('title'))
  report.initialBootMS=priorReport.coldBootMS
  report.checks=priorReport.checks;mark('native-datastore-fresh-process-continuation')
  report.complete=true;nativeWrite(report,'native-functional-report');print('FUNCTION COMPLETE')
  return
 end
 capture('title')
 local tutorials={'arrival','roll','jump','control','cannon','gate','trap','ferry','rotor','sweeper','lift','slider','fan','windcontrol','bumper','conveyor','jet','extend','switch','magnet','onboard'}
 for _,key in ipairs(tutorials) do
  for _,phase in ipairs({.35,1.35,2.35,3.35}) do
   preview={key=key,time=phase};frame();capture('guide-'..key..'-'..phase)
  end
 end
 preview=nil;mark('84-native-tutorial-animation-frames')
'''
suffix = '''
mark('startup-onboarding-map-help-selector-win-retry-fall-checkpoint-ending')
local saved=nativeRead('native-functional-progress')
assert(saved and saved.level==#Courses and saved.completed[#Courses] and saved.options.steering==Tilt.mode)
mark('native-datastore-write-readback')
-- Test sensor processing at multiple neutral grips and sampling rates. Values
-- are injected; this verifies native math, not physical gesture sensitivity.
for _,hz in ipairs({20,30,50}) do
 local dt=1/hz
 for _,grip in ipairs({{0,0,1},{0,0,-1},{0,1,0},{0,-1,0},{1,0,0},{-1,0,0},{.3,.4,math.sqrt(.75)}}) do
  Tilt.startCalibration();accel=grip
  for i=1,math.ceil(2/dt) do Tilt.update(dt) end
  assert(Tilt.ready and Tilt.armed)
  accel={grip[1],grip[2],grip[3]+.55};Tilt.update(dt)
  assert(Tilt.consumeJump(),'native lift missed at '..hz)
  for i=1,math.ceil(.2/dt) do Tilt.update(dt);assert(not Tilt.consumeJump(),'duplicate lift') end
  accel=grip;for i=1,math.ceil(2/dt) do Tilt.update(dt) end
  accel={grip[1]+1,grip[2],grip[3]+.55};Tilt.update(dt)
  assert(not Tilt.consumeJump(),'sideways shake accepted')
 end
 frame()
end
mark('21-grip-rate-lift-debounce-lateral-rejection-combinations')
report.awaitingRestart=true;nativeWrite(report,'native-functional-report');print('FUNCTION RESTART READY')
end)
runner=function()
 local ok,err=pcall(function()
  if preview then playdate.graphics.clear(playdate.graphics.kColorWhite);UI.lesson(preview.key,preview.time)
  else nativeUpdate() end
 end)
 if playdate.update~=runner then nativeUpdate=playdate.update;playdate.update=runner end
 if not ok then report.error=tostring(err);nativeWrite(report,'native-functional-report');print('FUNCTION ERROR '..tostring(err));playdate.update=function() end;return end
 if coroutine.status(co)=='dead' then return end
 local passed,result=coroutine.resume(co)
 if not passed then
  report.error=tostring(result);nativeWrite(report,'native-functional-report');print('FUNCTION ERROR '..tostring(result));playdate.update=function() end
 end
end
playdate.update=runner
'''
body=menus+"\nmark('paired-steering-save-cancel-new-game-unlocks-developer-isolation')\n"+toggles+reset+lessons+"\nmark('eight-tilt-driven-teaching-runs-in-both-steering-modes')\n"+wind+"\nmark('tilt-crank-release-wind-assist-climb')\n"+stations+conditions+reset+loop+ring+"\nmark('5760-ring-boundaries-360-clear-lanes-1440-air-passes')\n"+suffix
if smoke:
    # Retain the same production-update scheduling wrapper, not the full suite.
    body=(conditions if conditions_only else stations)+"\nreport.complete=true;nativeWrite(report,'native-functional-report');print('FUNCTION COMPLETE')\nend)\nrunner=function()"+suffix.split('runner=function()',1)[1]
(qa/'main.lua').write_text(prefix.replace('SENSOR_HELPER',sensor).replace('TEST_SCOPE','conditions-smoke' if conditions_only else 'station-smoke' if smoke else 'full')+body,encoding='utf-8')
out = repo/('builds/'+package_name+'/sky-hamster-tilt.pdx')
out.parent.mkdir(parents=True,exist_ok=True)
sdk=Path('C:/Users/12063/Documents/PlaydateSDK')
subprocess.run([str(sdk/'bin/pdc.exe'),'-sdkpath',str(sdk),str(qa),str(out)],check=True)
manifest={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in source.glob('*.lua')}
if not smoke:
    (here/'native-functional-provenance-v0.12.9.json').write_text(json.dumps({'version':'0.12.9','productionLua':manifest,'injected':['button queries','accelerometer','crank','explicit ball placements','isolated progress path'],'package':str(out)},indent=2)+'\n')
print('Built native production-input assertion runner:',out)
