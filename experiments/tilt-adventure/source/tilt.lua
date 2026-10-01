-- Neutral follows a steady grip; players choose screen or road steering axes.
Tilt={mode='screen',ready=false,cooldown=0,armed=false,quiet=0,fx=0,fy=0,fz=1,nx=0,ny=0,nz=1,power=0,jump=false,seeded=false}
local T=Tilt
function T.response(n) return math.min(1,math.max(0,(n-.05)/.50))^1.5 end
function T.direction(x,y)
 if T.mode=='screen' then x,y=x+2*y,-x+2*y end
 local n=math.sqrt(x*x+y*y)
 if n>0 then return x/n,y/n end
 return 0,0
end
-- Residual acceleration in g, along the current screen normal, not the saved grip.
local liftThreshold,lateralLimit=.48,.25
local function norm(x,y,z) local m=math.sqrt(x*x+y*y+z*z);return x/m,y/m,z/m end
local function basis()
 -- Project screen-right onto the gravity tangent plane. Near side-on use screen-down.
 local a,b,c=1-T.nx*T.nx,-T.nx*T.ny,-T.nx*T.nz
 if a*a+b*b+c*c>.09 then
  T.rx,T.ry,T.rz=norm(a,b,c)
  T.ux,T.uy,T.uz=T.ny*T.rz-T.nz*T.ry,T.nz*T.rx-T.nx*T.rz,T.nx*T.ry-T.ny*T.rx
 else
  T.ux,T.uy,T.uz=norm(-T.ny*T.nx,1-T.ny*T.ny,-T.ny*T.nz)
  T.rx,T.ry,T.rz=T.uy*T.nz-T.uz*T.ny,T.uz*T.nx-T.ux*T.nz,T.ux*T.ny-T.uy*T.nx
 end
end
local function clearWindow() T.samples=0;T.time=0;T.sx=0;T.sy=0;T.sz=0;T.ax=nil end
function T.startCalibration()
 T.calibrating=true;clearWindow();T.jump=false;T.ready=false
 T.power=0;T.dx,T.dy=0,0;T.seeded=false;T.stillReady=false;T.inputHold=0
end
function T.init()
 if playdate.startAccelerometer then playdate.startAccelerometer() end
 T.startCalibration()
end
function T.update(dt)
 local x,y,z=0,0,1
 if playdate.readAccelerometer then x,y,z=playdate.readAccelerometer() end
 if not x or not y or not z then T.jump=false;return end
 T.rawX,T.rawY,T.rawZ=x,y,z;T.cooldown=math.max(0,T.cooldown-dt);T.jump=false
 if not T.seeded then T.fx,T.fy,T.fz=x,y,z;T.seeded=true end
 local ix,iy,iz=x-T.fx,y-T.fy,z-T.fz
 local alpha=1-math.exp(-dt*12)
 T.inputHold=math.max(0,(T.inputHold or 0)-dt)
 -- Sensor Z is attached to the device: it tracks the current screen normal automatically.
 local impulse,lateral=iz,ix*ix+iy*iy
 if not T.calibrating then
  if math.abs(impulse)<.18 then T.quiet=T.quiet+dt;if T.quiet>.18 then T.armed=true end else T.quiet=0 end
  if T.ready and T.armed and lateral<lateralLimit and lateral<impulse*impulse and impulse>liftThreshold and T.cooldown==0 then
   T.jump=true;T.armed=false;T.cooldown=.75;T.inputHold=.22
  end
 end
 -- Keep a short lift pulse out of the tilt estimate so it cannot become a braking input.
 if T.inputHold==0 or T.calibrating then T.fx=T.fx+ix*alpha;T.fy=T.fy+iy*alpha;T.fz=T.fz+iz*alpha end
 if T.calibrating then
  local mag=math.sqrt(x*x+y*y+z*z)
  local drift=T.ax and ((x-T.ax)^2+(y-T.ay)^2+(z-T.az)^2) or 0
  T.stillReady=mag>.85 and mag<1.15 and drift<.0016 and ix*ix+iy*iy+iz*iz<.0036
  if not T.stillReady then clearWindow();return end
  if not T.ax then T.ax,T.ay,T.az=x,y,z end
  T.time=T.time+dt;T.samples=T.samples+1;T.sx=T.sx+x;T.sy=T.sy+y;T.sz=T.sz+z
  if T.time>=.8 then
   T.nx,T.ny,T.nz=norm(T.sx,T.sy,T.sz);basis()
   T.calibrating=false;T.ready=true;T.cooldown=.5;T.armed=false;T.quiet=0
  end
  return
 end
 local mag=math.max(.01,math.sqrt(T.fx*T.fx+T.fy*T.fy+T.fz*T.fz))
 local sx=(T.fx*T.rx+T.fy*T.ry+T.fz*T.rz)/mag
 local sy=(T.fx*T.ux+T.fy*T.uy+T.fz*T.uz)/mag
 local n=math.sqrt(sx*sx+sy*sy)
 T.power=T.response(n)
 if n>.05 then T.dx,T.dy=T.direction(sx,sy) else T.dx,T.dy=0,0 end
end
function T.consumeJump() local j=T.jump;T.jump=false;return j end
Tilt.init()
