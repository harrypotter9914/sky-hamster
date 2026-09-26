Tilt={ready=false,cooldown=0,armed=false,quiet=0,fx=0,fy=0,fz=1,nx=0,ny=0,nz=1,power=0,jump=false}
local T=Tilt
function T.startCalibration()
 T.calibrating=true;T.samples=0;T.time=0;T.sx=0;T.sy=0;T.sz=0;T.jump=false;T.ready=false
end
function T.init()
 if playdate.startAccelerometer then playdate.startAccelerometer() end
 T.startCalibration()
end
function T.update(dt)
 local x,y,z=0,0,1
 if playdate.readAccelerometer then x,y,z=playdate.readAccelerometer() end
 if not x or not y or not z then T.jump=false;return end
 T.cooldown=math.max(0,T.cooldown-dt);T.jump=false
 local alpha=1-math.exp(-dt*9)
 local impulse=(x-T.fx)*T.nx+(y-T.fy)*T.ny+(z-T.fz)*T.nz
 T.fx=T.fx+(x-T.fx)*alpha;T.fy=T.fy+(y-T.fy)*alpha;T.fz=T.fz+(z-T.fz)*alpha
 if T.calibrating then
  local mag=math.sqrt(x*x+y*y+z*z)
  if mag<.8 or mag>1.2 or math.abs(impulse)>.25 then T.samples=0;T.time=0;T.sx=0;T.sy=0;T.sz=0;return end
  T.time=T.time+dt;T.samples=T.samples+1;T.sx=T.sx+x;T.sy=T.sy+y;T.sz=T.sz+z
  if T.time>=.8 then
   local n=math.sqrt(T.sx*T.sx+T.sy*T.sy+T.sz*T.sz)
   T.nx,T.ny,T.nz=T.sx/n,T.sy/n,T.sz/n;T.calibrating=false;T.ready=true;T.cooldown=.5;T.armed=false;T.quiet=0
  end
  return
 end
 if math.abs(impulse)<.18 then T.quiet=T.quiet+dt;if T.quiet>.18 then T.armed=true end else T.quiet=0 end
 if T.ready and T.armed and impulse>.65 and T.cooldown==0 then T.jump=true;T.armed=false;T.cooldown=.75 end
 local mag=math.sqrt(T.fx*T.fx+T.fy*T.fy+T.fz*T.fz)
 local sx,sy=T.fx/math.max(mag,.01)-T.nx,T.fy/math.max(mag,.01)-T.ny
 local n=math.sqrt(sx*sx+sy*sy)
 T.power=math.min(1,math.max(0,(n-.045)/.40))
 if n>.045 then
  -- Screen-relative tilt, inverse of the isometric track projection.
  local dx,dy=sx/1.8+sy/.9,-sx/1.8+sy/.9
  local len=math.sqrt(dx*dx+dy*dy);T.dx,T.dy=dx/len,dy/len
 else T.dx,T.dy=0,0 end
end
function T.consumeJump() local j=T.jump;T.jump=false;return j end
Tilt.init()
