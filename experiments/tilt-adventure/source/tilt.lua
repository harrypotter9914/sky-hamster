-- Screen-up flat is the only neutral pose. Never learn an upright grip as zero.
Tilt={ready=false,cooldown=0,armed=false,quiet=0,fx=0,fy=0,fz=1,nx=0,ny=0,nz=1,power=0,jump=false,seeded=false}
local T=Tilt
function T.startCalibration()
 T.calibrating=true;T.samples=0;T.time=0;T.sx=0;T.sy=0;T.sz=0;T.jump=false;T.ready=false
 T.nx,T.ny,T.nz=0,0,1;T.power=0;T.dx,T.dy=0,0;T.seeded=false;T.flatReady=false
end
function T.init()
 if playdate.startAccelerometer then playdate.startAccelerometer() end
 T.startCalibration()
end
function T.update(dt)
 local x,y,z=0,0,1
 if playdate.readAccelerometer then x,y,z=playdate.readAccelerometer() end
 if not x or not y or not z then T.jump=false;return end
 T.rawX,T.rawY,T.rawZ=x,y,z
 T.cooldown=math.max(0,T.cooldown-dt);T.jump=false
 if not T.seeded then T.fx,T.fy,T.fz=x,y,z;T.seeded=true end
 local alpha=1-math.exp(-dt*9)
 local impulse=z-T.fz
 T.fx=T.fx+(x-T.fx)*alpha;T.fy=T.fy+(y-T.fy)*alpha;T.fz=T.fz+(z-T.fz)*alpha
 if T.calibrating then
  local mag=math.sqrt(x*x+y*y+z*z)
  T.flatReady=math.abs(x)<.075 and math.abs(y)<.075 and z>.94 and mag<1.08
  if not T.flatReady or math.abs(impulse)>.12 then T.samples=0;T.time=0;T.sx=0;T.sy=0;T.sz=0;return end
  T.time=T.time+dt;T.samples=T.samples+1;T.sx=T.sx+x;T.sy=T.sy+y
  if T.time>=.8 then
   -- Tiny sensor trim only. The maximum combined trim stays inside the deadzone.
   local function trim(v) return math.max(-.025,math.min(.025,v)) end
   T.nx,T.ny,T.nz=trim(T.sx/T.samples),trim(T.sy/T.samples),1
   T.calibrating=false;T.ready=true;T.cooldown=.5;T.armed=false;T.quiet=0
  end
  return
 end
 if math.abs(impulse)<.18 then T.quiet=T.quiet+dt;if T.quiet>.18 then T.armed=true end else T.quiet=0 end
 -- A level, whole-device upward lift produces a positive screen-normal pulse.
 -- Reject upright shaking and large sideways impulses rather than treating them as jumps.
 local level=T.fz>.82 and T.fx*T.fx+T.fy*T.fy<.12
 local lateral=(x-T.fx)^2+(y-T.fy)^2
 if T.ready and T.armed and level and lateral<.16 and impulse>.65 and T.cooldown==0 then T.jump=true;T.armed=false;T.cooldown=.75 end
 local mag=math.sqrt(T.fx*T.fx+T.fy*T.fy+T.fz*T.fz)
 local sx,sy=T.fx/math.max(mag,.01)-T.nx,T.fy/math.max(mag,.01)-T.ny
 local n=math.sqrt(sx*sx+sy*sy)
 T.power=math.min(1,math.max(0,(n-.045)/.40))
 if n>.045 then
  -- SDK +X is screen-right, +Y is screen-down, +Z is through the screen.
  -- Undo only the track's isometric projection; keep sensor directions intact.
  local dx,dy=sx/1.8+sy/.9,-sx/1.8+sy/.9
  local len=math.sqrt(dx*dx+dy*dy);T.dx,T.dy=dx/len,dy/len
 else T.dx,T.dy=0,0 end
end
function T.consumeJump() local j=T.jump;T.jump=false;return j end
Tilt.init()
