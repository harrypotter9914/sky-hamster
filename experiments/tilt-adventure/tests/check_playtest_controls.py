"""Physical-angle sensitivity, braking, screen axes and saved settings after the playtest."""
from pathlib import Path
f=Path(__file__).with_name('check_tilt.py');s=f.read_text(encoding='utf-8');env={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0]+"load('engine')",str(f),'exec'),env)
lua=env['lua'];lua.execute('function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute('''
assert(Tilt.mode=='road','new players default to road axes')
local function settle(a) accel=a;for i=1,90 do Tilt.update(1/30) end end
for _,grip in ipairs({{0,0,1},{0,1,0},{1,0,0},{0,0,-1},{.3,.4,.866}}) do
 Tilt.startCalibration();settle(grip);assert(Tilt.ready and Tilt.power==0)
 for _,mode in ipairs({'screen','road'}) do
  Tilt.mode=mode
  for i=0,15 do
   local a=i*math.pi/8;local ix,iy=math.cos(a),math.sin(a)
   settle({Tilt.nx*.954+.3*(ix*Tilt.rx+iy*Tilt.ux),Tilt.ny*.954+.3*(ix*Tilt.ry+iy*Tilt.uy),Tilt.nz*.954+.3*(ix*Tilt.rz+iy*Tilt.uz)})
   local x,y=Tilt.dx,Tilt.dy
   if mode=='screen' then x,y=(x-y)*.9,(x+y)*.45;local n=math.sqrt(x*x+y*y);x,y=x/n,y/n end
   assert(math.abs(x-ix)<.0001 and math.abs(y-iy)<.0001,'direction disagrees with selected axes')
  end
 end
end
local function stopping(v,p,old,dt)
 local t,x=0,0
 for i=1,100000 do
  local nextV=(old and Physics.step or Physics.steer)(v,0,-1,0,p,0,0,dt)
  if nextV<=.01 then return t+dt,x+(v+math.max(0,nextV))*.5*dt end
  x=x+(v+nextV)*.5*dt;t=t+dt;v=nextV
 end
 error('failed to settle')
end
for _,angle in ipairs({5,10,15,20,30}) do
 local n=math.sin(math.rad(angle));local old=math.min(1,math.max(0,(n-.045)/.4));local new=Tilt.response(n)
 if angle<=20 then assert(new<old and new>old*.88,'response should be only slightly softer than 0.12.4') end
 local ot,od=stopping(120,old,true,1/1200);local nt,nd=stopping(120,new,false,1/1200)
 assert(nd<od*.8 and nt<ot*.85,'counter-tilt did not improve at the same physical angle')
 print(string.format('LEAN %d oldPower=%.3f newPower=%.3f stopTime=%.3f->%.3f stopDistance=%.2f->%.2f',angle,old,new,ot,nt,od,nd))
end
assert(Tilt.response(math.sin(math.rad(27)))==1,'full power requires excessive screen tilt')
for _,angle in ipairs({10,15,20}) do
 local n=math.sin(math.rad(angle));local oldPower=math.min(1,(n-.045)/.4);local p=Tilt.response(n)
 local before,after=0,0
 for i=1,120 do before=Physics.step(before,0,1,0,oldPower,0,0,1/120);after=Physics.steer(after,0,1,0,p,0,0,1/120) end
 assert(after>before*.92 and after<before,'forward acceleration should stay close to original')
 print(string.format('ACCEL %d speedAfter1s=%.2f->%.2f',angle,before,after))
end
local ot,od=stopping(120,0,true,1/1200);local nt,nd=stopping(120,0,false,1/1200)
assert(nd<od*.6 and nt<ot*.6,'neutral coasting remains too long')
print(string.format('NEUTRAL stopTime=%.3f->%.3f stopDistance=%.2f->%.2f',ot,nt,od,nd))
for _,dt in ipairs({1/30,1/60,1/120}) do
 local t,d=stopping(120,.4,false,dt);local rt,rd=stopping(120,.4,false,1/1200)
 assert(math.abs(d-rd)<rd*.08,'frame-rate dependent braking')
end
assert(Physics.steer(200,0,-1,0,1,0,0,1/30)>180,'single reverse input snaps momentum')
local v=0
for i=1,1200 do v=Physics.steer(v,0,1,0,1,0,0,1/120) end
assert(v>140 and v<220,'flat full tilt speed runs away or is too limited')
local down=0;for i=1,120 do down=Physics.steer(down,0,0,0,0,-.5,0,1/120) end
assert(down>90,'neutral assistance erased gravity')
local fast=Physics.steer(300,0,1,0,1,-.5,0,1/120)
assert(fast>300,'soft propulsion limit clamped downhill energy')
-- Real menu events: graphical subpage, mode round-trip and persisted choice.
put('title',false);put('settings',true);put('settingsChoice',1);Tilt.mode='screen'
for i=1,4 do frame({down=true}) end
assert(get('settingsChoice')==5);frame({a=true})
assert(get('steeringMenu') and Tilt.mode=='screen')
frame({right=true});frame({a=true})
assert(Tilt.mode=='road' and store.saved.options.steering=='road')
frame({a=true});frame({left=true});frame({a=true});assert(Tilt.mode=='screen' and store.saved.options.steering=='screen')
frame({b=true});assert(not get('settings') and store.saved.controlRevision==1)
print('PASS: 160 grip/direction cases, same-angle braking, micro-control, continuous momentum, gravity, propulsion-only speed easing and saved steering choices')
''')
