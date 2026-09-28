"""Footprint seams, live passage signals, onboard control and swept crosswinds."""
from check_bumper_ring import lua
lua.execute('''
local c={lookup={['0,0']=true},mechanisms={},height=function()return 0 end}
assert(Footing.query(c,40.99,16,0),'half-width edge support missing')
assert(not Footing.query(c,41.01,16,0),'overhang beyond radius still supported')
assert(Footing.query(c,38,38,0),'rounded corner support missing')
assert(not Footing.query(c,39,39,0),'corner uses a square instead of circle')
for _,gap in ipairs({1,8,16,18,19,24}) do
 c.mechanisms={{kind='ferry',manual=true,x=32+gap+16,y=16,toX=32+gap+16,toY=16,w=32,h=32}}
 local complete=true
 for step=0,100 do if not Footing.query(c,32+gap*step/100,16,0) then complete=false end end
 assert(complete==(gap<=18),'wrong diameter gap threshold '..gap)
end
local nsignals=0
for n,course in ipairs(Courses) do
 Dock.reset(course)
 for _,m in ipairs(course.mechanisms or {}) do
  for _,p in ipairs(Passage.ports(m)) do
   if m.kind=='lift' then m.elevation=p.z
   elseif m.kind=='ferry' then m.progress=p.dx<0 and 0 or 1
   elseif m.retract then m.w=m.maxWidth
   else m.angle=math.atan(p.dy,p.dx) end
   local t=m.kind=='ferry' and not m.manual and (p.dx<0 and 0 or (m.period or 10)*.5) or 0
   assert(Passage.ready(course,m,p,t),'flush landing not GO '..n..' '..m.kind)
   nsignals=nsignals+1
  end
 end
end
for _,n in ipairs({45,46,47,48}) do
 local course=Courses[n];Dock.reset(course)
 for _,p in ipairs(course.pads) do if p.onboard then
  local m=p.target;m.angle=0;Mechanisms.pose(m,0)
  assert(Passage.ready(course,m,m.ports[1],0) and not Passage.ready(course,m,m.ports[2],0))
  Dock.active=nil;Dock.blocked=nil
  local r=Dock.update(course,p.x,p.y,0,0,false,0,false,false)
  assert(r and r.locked and Dock.active==p,'cannot board dial '..n)
  Dock.update(course,p.x,p.y,0,0,false,-87,false,false)
  assert(math.abs(m.angle-math.rad(-87))<1e-9,'rotation snapped')
  assert(Passage.ready(course,m,m.ports[2],0),'small angular gap should be passable')
  Dock.update(course,p.x,p.y,0,0,false,25,false,false)
  assert(not Passage.ready(course,m,m.ports[2],0),'large unconnected exit says GO')
  Dock.update(course,p.x,p.y,0,0,false,1000,false,false)
  assert(math.abs(m.angle-math.rad(938))<1e-9,'continuous rotation capped')
  Dock.update(course,p.x,p.y,0,0,false,0,false,true)
  assert(not Dock.update(course,p.x,p.y,0,0,false,0,false,false),'release instantly relocks')
  Dock.update(course,p.x+40,p.y,0,0,false,0,false,false)
  assert(Dock.update(course,p.x,p.y,0,0,false,0,false,false).locked,'re-entry does not lock')
 end end
end
local m={kind='gate',period=4,openFor=.4,wallHeight=45}
-- Cross a slightly imperfect joint through the real grounded update, not only
-- through geometry helpers. The sphere must remain on the road without jumping.
selectReady(45);put('lesson',false);put('title',false)
local p=Courses[45].pads[1];Dock.active=p;p.angle=math.rad(-87);p.target.angle=p.angle
put('x',p.x);put('y',p.y);frame({b=true})
for i=1,75 do
 if get('y')<=110 then break end
 put('vx',0);put('vy',-65);frame()
 assert(get('state')=='play' and not get('airborne'),'misaligned exit causes a fall')
end
assert(get('y')<=110,'near-aligned landing cannot be reached')
local sweep=Courses[13].mechanisms[1];local lanes=Passage.lanes(Courses[13],sweep)
assert(#lanes==2,'sweeper lane signals missing')
for _,y in ipairs(lanes) do for _,t in ipairs({0,1,2,3,4}) do
 local _,cy=Mechanisms.pose(sweep,t)
 if Passage.laneReady(Courses[13],sweep,y,t) then assert(math.abs(y-cy)>=sweep.h/2+10,'GO overlaps moving panel') end
end end
assert(Passage.state(m,.5) and not Passage.state(m,2))
m={kind='trap',period=4,openFor=.4}
assert(not Passage.state(m,.5) and Passage.state(m,2) and not Passage.state(m,3.8))
m={kind='jet',period=4};assert(not Passage.state(m,0) and Passage.state(m,2))
local region={0,0,16,32}
assert(WindContact.fraction(region,-20,0,400,0,.1)>0,'fast crossing missed')
assert(WindContact.fraction(region,-20,50,400,0,.1)==0,'wind outside zone')
local fan={kind='fan',x=0,y=0,w=32,h=32,angle=math.pi/2,region=region,force=100}
c={mechanisms={fan},height=function()return 0 end}
local vx,vy=Mechanisms.wind(c,0,0,0,0,0,.01,0)
assert(math.abs(vy-1.08)<1e-9,'wind gain is not exactly 8 percent')
print('PASS: circular edge support, diameter gap boundary, '..nsignals..' real landing signals, four onboard routes, no snap, release/re-entry, gates/traps/jets, fast wind crossing and +8% force')
''')

# Scripted planar velocities exercise the real support/collision/dock/checkpoint
# and win transitions. This verifies route connectivity, not human tilt difficulty.
lua.execute('''
local function walk(tx,ty,dock)
 for i=1,700 do
  local dx,dy=tx-get('x'),ty-get('y');local d=math.sqrt(dx*dx+dy*dy)
  if dock and Dock.active then return end
  if not dock and d<3 then return end
  if get('state')=='win' then return end
  assert(get('state')=='play','route fell while heading to '..tx..','..ty)
  local v=math.min(75,d*5);if dock and d<32 then v=25 end
  put('vx',dx/d*v);put('vy',dy/d*v);frame()
 end
 error('stuck on route toward '..tx..','..ty)
end
local function board(p,angle)
 walk(p.x,p.y,true);assert(Dock.active==p)
 frame(nil,nil,angle-math.deg(p.angle));frame({b=true})
end
for _,n in ipairs({45,46,47,48}) do
 selectReady(n);put('lesson',false);put('title',false)
 local c=Courses[n];local pads=c.pads
 if n==47 then board(pads[1],0);board(pads[2],-87);walk(320,48,false)
 elseif n==45 then board(pads[1],-87);walk(320,48,false)
 elseif n==46 then board(pads[1],-87);walk(320,176,false);board(pads[2],90);walk(512,416,false)
 else
  board(pads[1],-87);walk(320,176,false);walk(400,136,false);walk(560,136,false)
  board(pads[2],90);walk(704,400,false);board(pads[5],540);walk(1248,416,false)
  board(pads[3],0);board(pads[4],-87);walk(1440,160,false)
 end
 assert(get('state')=='win' and get('falls')==0,'route did not complete without falling '..n)
 print('PASS: scripted route '..n..' reaches win through real dock, collision, support and checkpoint logic')
end
''')
