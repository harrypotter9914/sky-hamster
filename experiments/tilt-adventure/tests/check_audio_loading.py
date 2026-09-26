from check_feel import lua
from pathlib import Path
import hashlib, wave

audio=Path(__file__).resolve().parents[1]/'source/audio/machines'
hashes=set()
for path in audio.glob('*.wav'):
    with wave.open(str(path)) as wav:
        assert wav.getnchannels()==1 and wav.getframerate()==22050
        data=wav.readframes(wav.getnframes())
        digest=hashlib.sha256(data).hexdigest()
        assert digest not in hashes, f'duplicate sound: {path}'
        hashes.add(digest)
print(f'PASS: {len(hashes)} distinct mono machine/UI samples')

lua.execute('''
Audio.effects=true;Audio.enabled=true
local S=MechanismAudio
local function testCourse(m)
 return {mechanisms={m},pads={},height=function()return 0,0,0 end}
end
local function fixture(kind)
 return {kind=kind,x=0,y=0,w=48,h=48,period=4,phase=0,angle=0,toX=160,toY=0,range=70,
  minHeight=0,maxHeight=96,elevation=0,radius=120,region={0,0,100,100}}
end
local function loop(name)
 for _,v in ipairs(S.loops) do if v.name==name then return v end end
 error(name)
end
for _,kind in ipairs({'fan','conveyor','jet','magnet','ferry','rotor','sweeper'}) do
 local m=fixture(kind);local c=testCourse(m);S.reset(c)
 for i=0,40 do S.update(c,0,0,i/30,1/30,true,false,0) end
 local name=({conveyor='belt',jet='jet'})[kind] or kind
 if kind=='jet' then assert(loop(name).player.plays>0) else assert(loop(name).want>0,kind..' has no running sound') end
 S.update(c,10000,10000,1.4,1/30,true,false,0)
 for _,v in ipairs(S.loops) do assert(not v.player:isPlaying(),'remote machine audible') end
end
for _,kind in ipairs({'gate','trap','jet'}) do
 local m=fixture(kind);local c=testCourse(m);S.reset(c)
 local first=kind=='gate' and 'gate_open' or kind=='trap' and 'trap_open' or 'jet_on'
 local second=kind=='gate' and 'gate_close' or kind=='trap' and 'trap_close' or 'jet_off'
 local a,b=S.shots[first].player.plays,S.shots[second].player.plays
 for i=0,260 do S.update(c,0,0,i/30,1/30,true,false,0) end
 assert(S.shots[first].player.plays>a and S.shots[second].player.plays>b,kind..' misses transition')
end
-- A real spring collision stamps hitAt; proximity alone is silent.
local m=fixture('bumper');m.radius=18;local c=testCourse(m);S.reset(c)
S.update(c,-30,0,0,1/30,true,false,0)
local before=S.shots.spring.player.plays
S.update(c,-30,0,.033,1/30,true,false,0);assert(S.shots.spring.player.plays==before)
Mechanisms.collide(c,-25,0,100,0,0,.04,1/120)
S.update(c,-25,0,.05,1/30,true,false,0);assert(S.shots.spring.player.plays==before+1)
S.update(c,-25,0,.08,1/30,true,false,0);assert(S.shots.spring.player.plays==before+1)
-- Exercise every real control-pad type and verify its distinct mechanism family.
local tested={}
for _,course in ipairs(Courses) do for _,p in ipairs(course.pads or {}) do if not tested[p.kind] then
 tested[p.kind]=true;Dock.reset(course)
 local connects=S.shots.connect.player.plays
 Dock.update(course,p.x,p.y,0,0,false,0,false,false)
 assert(Dock.active==p and S.shots.connect.player.plays==connects+1,'missing connect '..p.kind)
 S.update(course,p.x,p.y,.033,1/30,true,false,0)
 Dock.update(course,p.x,p.y,0,0,false,30,false,false)
 if p.kind=='switch' then
  local n=S.shots.switch.player.plays
  Dock.update(course,p.x,p.y,0,0,false,220,false,false)
  assert(S.shots.switch.player.plays>n)
 else
  S.update(course,p.x,p.y,.066,1/30,true,false,0)
  local family=({lift='lift',slider='slider',bridge='bridge',extend='winch',cannon='cannon_aim',fan='fan_aim'})[p.kind]
  assert(family and loop(family).want>0,'missing crank family '..p.kind)
 end
 if p.kind=='cannon' then
  local fires=S.shots.cannon.player.plays
  Dock.update(course,p.x,p.y,0,0,false,0,true,false)
  assert(S.shots.cannon.player.plays==fires+1)
 else
  local releases=S.shots.release.player.plays
  Dock.update(course,p.x,p.y,0,0,false,0,false,true)
  assert(S.shots.release.player.plays==releases+1,'missing release '..p.kind)
 end
 S.update(course,p.x,p.y,.10,1/30,true,false,0)
 S.update(course,p.x,p.y,.25,.15,true,false,0)
 assert(not S.command or S.clock>=S.commandUntil or not Dock.active)
end end end
for _,name in ipairs({'bridge','cannon','lift','slider','fan','extend','switch'}) do assert(tested[name],name) end
-- Dense course: bounded voices; pause/settings/reset stop all machinery.
S.reset(Courses[44]);Dock.active=nil
for i=1,180 do
 S.update(Courses[44],2128,112,i/30,1/30,true,false,0)
 local count=0;for _,v in ipairs(S.loops) do if v.player:isPlaying() then count=count+1 end end
 assert(count<=3,'unbounded continuous mixer')
end
for name in pairs(S.shots) do S.play(name,.3,1) end
local count=0;for _,v in pairs(S.shots) do if v.untilAt>S.clock then count=count+1 end end
assert(count<=4,'unbounded event mixer')
Audio.pause()
for _,v in ipairs(S.loops) do assert(not v.player:isPlaying()) end
for _,v in pairs(S.shots) do assert(not v.player:isPlaying()) end
Audio.resume();Audio.toggleEffects();assert(not Audio.effects)
local before=S.shots.connect.player.plays;S.play('connect');assert(S.shots.connect.player.plays==before)
Audio.toggleEffects();S.reset(Courses[1]);S.play('connect');assert(S.shots.connect.player.plays==before+1,'new course kept old cooldown')
for _,action in ipairs({'move','confirm','back','toggle','unlock','ready'}) do
 local p=Audio.players['ui_'..action];local n=p.plays;Audio.ui(action);assert(p.plays==n+1)
end
print('PASS: every mechanism/control-pad sound, actual spring event, transition pairs, attenuation, voice limits, pause/effects/reset and six UI cues')

local work,done=0,false
Loading.begin(function() for i=1,12 do work=work+1;Loading.checkpoint(i/12,'TEST') end end,'TEST',function() done=true end)
local old=0;local frames=0
while Loading.busy do
 local before=work;Loading.step(1/30);frames=frames+1
 assert(work-before<=1,'loading blocks all work in a single frame')
 assert(Loading.shown>=old and Loading.shown<=1);old=Loading.shown
 assert(frames<100)
end
assert(done and work==12 and Loading.shown==1)
local select=get('selectLevel');select(44)
assert(Loading.busy,'course change must load asynchronously')
drainLoading();assert(get('level')==44 and Tilt.calibrating)
assert(not get('airborne') and get('elapsed')==0,'loading must not run gameplay')
print('PASS: cooperative loading frames, real monotonic progress, completion callback and frozen course entry')
''')
