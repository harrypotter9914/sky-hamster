Physics={}
Physics.tuning={drive=150,gravity=280,friction=7,drag=0.16,latch=0.60,reverseDot=-0.7,powerDelay=0.18,powerDecay=1.4,jumpDelay=0.5,jumpDecay=0.16,jumpGravity=300}
function Physics.step(vx,vy,dx,dy,p,sx,sy,dt)
 local n=math.sqrt(dx*dx+dy*dy)
 if n>0 then dx,dy=dx/n,dy/n end
 local opposing=n>0 and vx*dx+vy*dy<0 and p>0
 vx,vy=vx+(dx*p*150-sx*280)*dt,vy+(dy*p*150-sy*280)*dt
 local speed=math.sqrt(vx*vx+vy*vy)
 if speed>0 then local s=math.max(0,speed-(7+0.16*speed)*dt);vx,vy=vx*s/speed,vy*s/speed end
 return vx,vy,opposing
end
function Physics.newControls() return {power=0,charge=0,powerIdle=0,jumpIdle=0,lastX=0,lastY=0,flash=0} end
function Physics.controls(c,crank,dx,dy,dt)
 local n=math.sqrt(dx*dx+dy*dy)
 c.flash=math.max(0,c.flash-dt)
 if n>0 then
  dx,dy=dx/n,dy/n
  if c.lastX*dx+c.lastY*dy<Physics.tuning.reverseDot and c.power>Physics.tuning.latch then c.power=0;c.flash=0.65 end
  c.lastX,c.lastY=dx,dy
 end
 -- Angle accumulation, with decay starting only after that direction stops.
 if crank>0 then c.power=math.min(1,c.power+crank/360);c.powerIdle=0
 else local before=c.powerIdle;c.powerIdle=before+dt;c.power=math.max(0,c.power-Physics.tuning.powerDecay*math.max(0,c.powerIdle-math.max(before,Physics.tuning.powerDelay))) end
 if crank<0 then c.charge=math.min(1,c.charge-crank/270);c.jumpIdle=0
 else local before=c.jumpIdle;c.jumpIdle=before+dt;c.charge=math.max(0,c.charge-Physics.tuning.jumpDecay*math.max(0,c.jumpIdle-math.max(before,Physics.tuning.jumpDelay))) end
 return dx,dy
end
function Physics.launch(charge) if charge<0.05 then return 0 end return 75+100*charge end
function Physics.air(z,vz,dt) return z+vz*dt-0.5*Physics.tuning.jumpGravity*dt*dt,vz-Physics.tuning.jumpGravity*dt end
