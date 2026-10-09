"""Export real Simulator frames from an isolated production-code capture build.

Inputs are scripted for repeatable previews. This does not certify human
playtesting or hardware performance. Never modify the shipping source/save.
"""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / 'experiments/tilt-adventure/source'
QA = ROOT / 'builds/release-gif-source'
QA.mkdir(parents=True, exist_ok=True)
shutil.copytree(SRC, QA, dirs_exist_ok=True)
engine = (SRC / 'engine.lua').read_text(encoding='utf-8')
engine += r'''

MovieCapture={
 begin=function(id) selectLevel(Courses.indexById[id]) end,
 setup=function(kind)
  title=false;settings=false;lesson=false;choosing=false;overview=false;briefing=false
  steeringMenu=false;steeringNotice=false;startMenu=false;newGameConfirm=false
  steeringChosen=true;state='play';elapsed=0;falls=0;airborne=false;rollAngle=0
  Dock.active=nil;Dock.blocked=nil;Tilt.ready=true;Tilt.calibrating=false
  Tilt.mode='road';Tilt.cooldown=0;Tilt.dx,Tilt.dy,Tilt.power=0,0,0
  worldTime=0;vx,vy=0,0
  if kind=='jump' then x,y=80,80;vx=75
  else
   for _,p in ipairs(course.pads) do
    if (kind=='turn' and p.onboard) or p.kind==kind then
     x,y=p.x,p.y;Dock.active=p
     if kind=='cannon' then p.angle=.7 end
     break
    end
   end
  end
  ballHeight=floorAt(x,y);jumpZ=ballHeight;jumpV=0
 end,
 state=function() return {x=x,y=y,vx=vx,vy=vy,state=state,airborne=airborne,z=jumpZ,locked=Dock.status()} end
}
'''
(QA / 'game.lua').write_text(engine, encoding='utf-8')
main = r'''
import 'CoreLibs/graphics'
local pd,g=playdate,playdate.graphics
local write=pd.datastore.write
pd.datastore.read=function() return nil end
pd.datastore.write=function() end
local realClock=pd.getCurrentTimeMilliseconds
local clock=realClock()
pd.getCurrentTimeMilliseconds=function() return clock end
import 'loading'
Loading.booting=true
import 'game'
Loading.booting=false
local gameUpdate=pd.update
local key,crank=nil,0
pd.buttonJustPressed=function(k) return k==key end
pd.buttonIsPressed=function() return false end
pd.getCrankChange=function() return crank end
Tilt.update=function(dt) Tilt.cooldown=math.max(0,Tilt.cooldown-dt) end
local plan={
 {id='legacy-5',kind='jump',frames=90},
 {id='legacy-16',kind='cannon',frames=110},
 {id='onboard-turn',kind='turn',frames=140},
 {id='lift-school',kind='lift',frames=135}
}
local i,n,started,posed=1,0,false,false
local report={complete=false,fps=30,scriptedInput=true,scenes={}}
function pd.update()
 local ok,err=pcall(function()
  if i>#plan then return end
  clock=clock+1000/30
  key=nil;crank=0
  local s=plan[i]
  if not started then MovieCapture.begin(s.id);started=true;return end
  if Loading.busy then gameUpdate();return end
  if not posed then MovieCapture.setup(s.kind);posed=true;n=0;s.samples={} end
  n=n+1
  Tilt.dx,Tilt.dy,Tilt.power=0,0,0
  if s.kind=='jump' then
   Tilt.dx=1;Tilt.power=.36
   if n==15 then key=pd.kButtonA end
   if n>48 then Tilt.dx=-1;Tilt.power=.55 end
   if n>65 then Tilt.dx=0;Tilt.power=0 end
  elseif s.kind=='cannon' then
   if n<=33 then crank=-math.deg(.7)/33 end
   if n==44 then key=pd.kButtonA end
   if n>74 then Tilt.dx=-1;Tilt.power=.6 end
   if n>96 then Tilt.dx=0;Tilt.power=0 end
  elseif s.kind=='turn' then
   if n<=60 then crank=-1.5 end
   if n==76 then key=pd.kButtonB end
   if n>80 then Tilt.dy=-1;Tilt.power=.48 end
   if n>115 then Tilt.dy=1;Tilt.power=.6 end
   if n>131 then Tilt.dy=0;Tilt.power=0 end
  else
   if n<=64 then crank=6 end
   if n==76 then key=pd.kButtonB end
   if n>80 then Tilt.dx=1;Tilt.power=.45 end
   if n>116 then Tilt.dx=-1;Tilt.power=.6 end
  end
  local im=g.image.new(400,240,g.kColorWhite)
  g.pushContext(im);g.setFont(UI.bodyFont);gameUpdate();g.popContext();im:draw(0,0)
  pd.datastore.writeImage(im,string.format('%s-%03d.gif',s.kind,n))
  if n%10==0 or n==1 then s.samples[#s.samples+1]=MovieCapture.state() end
  if n>=s.frames then
   report.scenes[#report.scenes+1]=s;i=i+1;started=false;posed=false
   if i>#plan then report.complete=true;write(report,'capture-report');print('MOVIE CAPTURE COMPLETE') end
  end
 end)
 if not ok then report.error=tostring(err);write(report,'capture-report');print('MOVIE CAPTURE ERROR '..tostring(err));i=#plan+1 end
end
'''
(QA / 'main.lua').write_text(main, encoding='utf-8')
info=(SRC / 'pdxinfo').read_text(encoding='utf-8').replace('com.wangyibo.skyhamster.tilt','com.wangyibo.skyhamster.releasegif')
(QA / 'pdxinfo').write_text(info, encoding='utf-8')
print(QA)
