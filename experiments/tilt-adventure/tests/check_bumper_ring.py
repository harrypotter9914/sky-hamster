"""Ground footprint, side-only contacts and one sound/animation event per impact."""
from check_spring_occlusion import lua
lua.execute('''
local m={kind='bumper',x=0,y=0,w=28,h=28,radius=BumperModel.radius,sideHeight=BumperModel.height}
local c={mechanisms={m},pads={},height=function()return 0,0,0 end}
local count=0
for angle=0,359 do
 local a=math.rad(angle);local nx,ny=math.cos(a),math.sin(a)
 for _,z in ipairs({0,3,8,9.9}) do
  local r=BumperModel.contactRadius(m,z)
  m.hitAt=nil
  local _,_,vx,vy,hit=Mechanisms.collide(c,nx*(r+.01),ny*(r+.01),-nx*60,-ny*60,z,1,.001)
  assert(not hit and not m.hitAt,'invisible outer collision '..angle)
  local x,y,ox,oy,contact=Mechanisms.collide(c,nx*(r-.01),ny*(r-.01),-nx*60,-ny*60,z,2,.001)
  assert(contact and m.hitAt==2 and ox*nx+oy*ny>=89.999,'missing true side contact '..angle)
  count=count+2
 end
 -- Old 27-unit trigger must not seal the newly clear passing lane.
 m.hitAt=nil
 local _,_,vx,vy,hit=Mechanisms.collide(c,nx*25,ny*25,-ny*100,nx*100,0,3,.001)
 assert(not hit and not m.hitAt and vx==-ny*100 and vy==nx*100,'clear lane rebounds')
 for _,z in ipairs({10,20,28,35}) do
  local _,_,vx,vy,hit=Mechanisms.collide(c,nx*20,ny*20,-nx*90,-ny*90,z,4,.001)
  assert(not hit and vx==-nx*90 and vy==-ny*90,'air above ring triggered')
 end
 local _,_,vx,vy,hit=Mechanisms.collide(c,nx*5,ny*5,10,20,4,5,.001)
 assert(not hit and vx==10 and vy==20,'top entry created side thrust')
end
Audio.enabled=true;Audio.effects=true
local S=MechanismAudio
m.hitAt=nil;S.reset(c);S.update(c,-30,0,0,1/30,true,false,0)
local before=S.shots.spring.player.plays
Mechanisms.collide(c,-25,0,90,0,0,.03,.001)
S.update(c,-25,0,.04,1/30,true,false,0)
assert(S.shots.spring.player.plays==before and not m.hitAt,'near miss plays sound or pulses')
local x,y,vx,vy=Mechanisms.collide(c,-22.99,0,90,0,0,.06,.001)
assert(m.hitAt==.06,'animation was not started by contact')
S.update(c,x,y,.07,1/30,true,false,0)
assert(S.shots.spring.player.plays==before+1,'contact has no sound')
Mechanisms.collide(c,x,y,vx,vy,0,.08,.001)
S.update(c,x,y,.09,1/30,true,false,0)
assert(S.shots.spring.player.plays==before+1 and m.hitAt==.06,'departing ball replays event')
local make=playdate.graphics.image.new
playdate.graphics.image.new=function()error('ring animation allocates during play')end
for i=0,60 do MachineArt.bumper(m,.06+i/120,100,100) end
playdate.graphics.image.new=make
print('PASS: '..count..' exact footprint boundary checks, 360 passing lanes, 1440 clear-air passes, top-entry exclusion, one synchronized impact sound/pulse and no animation image allocation')
''')
