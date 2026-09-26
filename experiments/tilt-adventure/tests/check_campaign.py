"""Run gameplay regression suite, then exercise the expanded campaign."""
from check_tilt import lua
lua.execute('''
assert(#Courses==44)
local migrated=Courses.migrate({level=16,completed={['15']=true,['16']=true},best={['16']=12.5}})
assert(migrated.level==26 and migrated.completed[17] and migrated.completed[26] and migrated.best['26']==12.5)
assert(Courses.migrate(migrated)==migrated)
for i,c in ipairs(Courses) do
 Dock.reset(c)
 assert(Mechanisms.support(c,c.start[1],c.start[2],0),'unsupported start '..i)
 assert(Mechanisms.support(c,c.goal[1],c.goal[2],0),'unsupported goal '..i)
 for _,p in ipairs(c.checkpoints) do assert(Mechanisms.support(c,p[1],p[2],0),'unsupported checkpoint '..i) end
 Guide.enter(c,true);for _,k in ipairs(Guide.queue) do for _,t in ipairs({0,1,2.8,5.5}) do UI.lesson(k,t) end end
end
local c=Courses[19];local m=c.mechanisms[1];Dock.reset(c)
local d=Dock.update(c,224,80,0,0,false,0,false,false);assert(d.locked)
Dock.update(c,224,80,0,0,false,10000,false,false);assert(m.elevation==96 and Mechanisms.floor(c,224,80,0)==96)
Dock.update(c,224,80,0,0,false,-10000,false,false);assert(m.elevation==0)
-- Raised bank cannot be reached by rolling through the low lift.
selectReady(19);put('lesson',false);put('x',250);put('y',80);put('vx',180);put('ballHeight',0);frame()
assert(get('x')<256 and get('ballHeight')==0,'low lift must not teleport onto high bank')
-- Lift carries player vertically; released player can cross onto the upper road.
selectReady(19);put('lesson',false);put('x',224);put('y',80);frame();frame(nil,nil,384)
assert(get('ballHeight')==96 and Dock.active)
frame({b=true});put('vx',80);for i=1,20 do frame() end
assert(get('state')=='play' and get('x')>256 and get('ballHeight')==96)
c=Courses[22];m=c.mechanisms[1];Dock.reset(c)
d=Dock.update(c,184,80,0,0,false,540,false,false)
assert(d.locked and d.x==488 and c.pads[1].x==488)
assert(Mechanisms.support(c,488,80,0));Dock.update(c,488,80,0,0,false,0,false,true)
assert(not Dock.update(c,490,80,0,0,false,0,false,false))
c=Courses[24];Dock.reset(c);m=c.mechanisms[1]
local vx,vy=Mechanisms.wind(c,400,112,0,0,0,1);assert(vy>50)
Dock.update(c,144,112,0,0,false,-90,false,false)
vx,vy=Mechanisms.wind(c,400,112,0,0,0,1);assert(vx>50 and math.abs(vy)<.001)
Guide.seen={arrival=true,roll=true,jump=true,fan=true};Guide.enter(c);assert(Guide.key()=='windcontrol')
c=Courses[14];local x,y,vx,vy,hit=Mechanisms.collide(c,215,112,100,0,0,0,1/120)
assert(hit and vx<0);x,y,vx,vy,hit=Mechanisms.collide(c,215,112,100,0,35,0,1/120);assert(not hit and vx==100)
-- Fire every new cannon using actual physics, including raised launch decks.
for _,n in ipairs({26,27,28,33}) do
 for pi,p in ipairs(Courses[n].pads) do if p.kind=='cannon' then
  selectReady(n);put('lesson',false);put('x',p.x);put('y',p.y);put('ballHeight',Courses[n]:height(p.x,p.y))
  frame();assert(Dock.active,'cannon dock '..n);frame({a=true})
  for i=1,55 do frame();if not get('airborne') then break end end
  assert(get('state')=='play' and not get('airborne'),'cannon landing '..n..' pad '..pi)
 end end
end
-- Each final-route checkpoint advances and retries at the latest one.
selectReady(33);put('lesson',false)
for i,p in ipairs(Courses[33].checkpoints) do
 put('x',p[1]);put('y',p[2]);put('vx',0);put('vy',0);put('ballHeight',Courses[33]:height(p[1],p[2]));frame()
 assert(get('checkpoint')==i,'checkpoint '..i)
end
put('state','dead');frame({a=true});assert(get('x')==3536 and get('y')==240)
print('PASS: 44-course anchors, progress migration, all tutorials, lift stops and height collision, moving dock, wind control, bumper jump clearance, cannon routes, five checkpoints')
''')
