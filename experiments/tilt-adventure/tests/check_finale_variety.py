"""Distinct rooms, genuine angled landings, both route choices and tilt-only bends."""
from pathlib import Path
fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
scope={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0]+"load('engine')",str(fixture),'exec'),scope)
lua=scope['lua']
helpers='function get(name)'+source.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0]
lua.execute(helpers)
lua.execute('''
local cannons=0
for n=50,53 do
 local c=Courses[n];Curriculum.ensure(c)
 local seen={};local count=0
 for _,s in ipairs(c.sections) do
  local tiles={}
  for _,t in ipairs(c.tiles) do if t.x*32>=s.x and t.x*32<s.x+s.width then tiles[#tiles+1]=(t.x-s.x/32)..','..t.y end end
  table.sort(tiles);local signature=s.kind..':'..table.concat(tiles,';')
  assert(not seen[signature],'exact repeated room silhouette '..n..':'..s.kind);seen[signature]=true
  for _,p in ipairs(s.turns or {}) do
   local _,sx,sy=c:height(p[1],p[2]);assert(sx==0 and sy==0,'turn is on a slope')
   for dx=-12,12,12 do for dy=-12,12,12 do
    assert(c.lookup[math.floor((p[1]+dx)/32)..','..math.floor((p[2]+dy)/32)],'turn clearance below ball diameter')
   end end
  end
  for _,step in ipairs(s.route or {}) do if step.kind=='fire' then
   count=count+1;cannons=cannons+1
   assert(math.abs(step.angle)>.4 and math.abs(step.angle)<math.pi/3,'shot does not require reachable lateral aiming')
   local p=step.pad
   -- At the old default angle the same-height landing must be over void.
   local tx,ty=p.x+210,p.y
   assert(not c.lookup[math.floor(tx/32)..','..math.floor(ty/32)],'default straight shot skips aiming')
  end end
 end
 if n>=51 then assert(count==({6,6,10})[n-50],'wrong cannon count') end
end
print('PASS: no repeated room silhouettes within finales; '..cannons..' angled shots; level turns with ball-width clearance')
-- Replay each shot at centre and +/- 3 degrees using actual airborne updates.
local shots=0
for n=51,53 do
 selectReady(n);put('lesson',false);put('title',false);Tilt.calibrating=false
 local c=Courses[n]
 for _,s in ipairs(c.sections) do for _,action in ipairs(s.route or {}) do if action.kind=='fire' then
  for _,offset in ipairs({-3,0,3}) do
   local p=action.pad
   put('state','play');put('x',p.x);put('y',p.y);put('vx',0);put('vy',0)
   put('airborne',false);put('ballHeight',c:height(p.x,p.y));put('jumpZ',c:height(p.x,p.y))
   Dock.active=p;Dock.blocked=nil;p.angle=action.angle+math.rad(offset)
   Tilt.startCalibration();accel={0,0,1};for i=1,40 do frame() end
   frame({a=true});assert(get('airborne'),'failed launch')
   for i=1,90 do if not get('airborne') then break end;frame() end
   assert(get('state')=='play' and not get('airborne'),'missed reachable island '..n..':'..offset)
   assert((get('x')-action.landing[1])^2+(get('y')-action.landing[2])^2<48^2,'wrong island')
   local stopped=false
   for i=1,120 do
    local vx,vy=get('vx'),get('vy');local speed=math.sqrt(vx*vx+vy*vy)
    if speed<18 then stopped=true;break end
    accel=sensorForForce(-vx,-vy,.9);frame()
    assert(get('state')=='play' and not get('airborne'),'receiving terrace too short for real braking '..n)
   end
   assert(stopped,'cannot brake after landing')
   shots=shots+1
  end
 end end end
end
print('PASS: '..shots..' physical ballistic landings, +/-3 degree tolerance, real tilt braking on receiving terraces')
local lanes=0
for n=51,53 do
 selectReady(n);put('lesson',false);put('title',false);Tilt.calibrating=false;accel={0,0,1}
 local c=Courses[n]
 for _,s in ipairs(c.sections) do if s.alternative then
  for lane=1,2 do
   local p=c.pads[s.firstPad]
   put('state','play');put('x',p.x);put('y',p.y);put('vx',0);put('vy',0);put('airborne',false);put('ballHeight',c:height(p.x,p.y))
   Dock.active=p;Dock.blocked=nil;p.angle=.5;frame(nil,nil,lane==1 and 0 or -90);frame({b=true})
   assert(p.target.isOpen==(lane==1) and p.target.partner.isOpen==(lane==2),'route selection did not alternate gates')
   local points={}
   if lane==1 then for _,a in ipairs(s.route) do if a.kind=='walk' then points[#points+1]={a.x,a.y} end end
   else points=s.alternative end
   for _,target in ipairs(points) do
    local reached=false
    for i=1,1000 do
     local dx,dy=target[1]-get('x'),target[2]-get('y');local d=math.sqrt(dx*dx+dy*dy)
     if d<2 then reached=true;break end
     local speed=math.min(75,d*6);put('vx',dx/d*speed);put('vy',dy/d*speed);frame()
     assert(get('state')=='play','fork lane is not connected')
    end
    assert(reached,'fork lane blocked')
   end
   lanes=lanes+1
  end
 end end
end
print('PASS: '..lanes..' fork choices reach the reunion terrace through real gate/support checks')
-- Closed-loop tilt controls use only accelerometer input, never overwrite velocity.
local bends=0
for n=50,53 do
 selectReady(n);put('lesson',false);put('title',false)
 local c=Courses[n]
 for _,s in ipairs(c.sections) do if s.turns then
  put('state','play');put('x',s.start[1]);put('y',s.start[2]);put('vx',0);put('vy',0)
  put('airborne',false);put('ballHeight',c:height(s.start[1],s.start[2]));put('jumpZ',c:height(s.start[1],s.start[2]))
  Dock.active=nil;Dock.blocked=nil;Tilt.startCalibration();accel={0,0,1}
  for i=1,40 do frame() end
  assert(Tilt.ready)
  local targets={};for _,p in ipairs(s.route) do targets[#targets+1]={p.x,p.y} end
  targets[#targets+1]=s.finish
  for _,target in ipairs(targets) do
   local reached=false
   for i=1,1800 do
    if get('state')=='win' then reached=true;break end
    local x,y,vx,vy=get('x'),get('y'),get('vx'),get('vy')
    local dx,dy=target[1]-x,target[2]-y;local dist=math.sqrt(dx*dx+dy*dy)
    if dist<3 and vx*vx+vy*vy<64 then reached=true;break end
    local speed=math.min(52,dist*1.8)
    local _,sx,sy=c:height(x,y)
    local ax=(dx/math.max(dist,.01)*speed-vx)*5+sx*Physics.tuning.gravity
    local ay=(dy/math.max(dist,.01)*speed-vy)*5+sy*Physics.tuning.gravity
    local force=math.sqrt(ax*ax+ay*ay);local power=math.min(.92,force/Physics.tuning.drive)
    accel=sensorForForce(ax,ay,power)
    frame()
    assert((get('state')=='play' or get('state')=='win') and not get('airborne'),'tilt-only bend fell or required jumping '..n..':'..x..','..y)
   end
   assert(reached,'tilt controller cannot stop at turn '..n)
  end
  bends=bends+1
 end end
end
print('PASS: '..bends..' complete raised doglegs navigated with accelerometer input, no jumps or velocity overrides')
''')
