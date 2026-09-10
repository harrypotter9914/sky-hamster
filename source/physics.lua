Physics={}
Physics.tuning={drive=150,gravity=280,friction=7,drag=0.16,brake=240,crankPerDegree=1/540,latch=0.6}
function Physics.step(vx,vy,dx,dy,p,sx,sy,dt)
 local n=math.sqrt(dx*dx+dy*dy);local speed=math.sqrt(vx*vx+vy*vy);local braking=false
 if n>0 then dx,dy=dx/n,dy/n end
 if n>0 and speed>2 and (vx*dx+vy*dy)/speed < -0.35 then
  braking=true;local after=math.max(0,speed-240*dt);vx,vy=vx*after/speed,vy*after/speed
 elseif n>0 then vx,vy=vx+dx*p*150*dt,vy+dy*p*150*dt end
 vx,vy=vx-sx*280*dt,vy-sy*280*dt
 speed=math.sqrt(vx*vx+vy*vy)
 if speed>0 then local after=math.max(0,speed-(7+0.16*speed)*dt);vx,vy=vx*after/speed,vy*after/speed end
 return vx,vy,braking
end
-- Reconstruction adapter: no jump or decay is active in this version.
function Physics.newControls() return {power=0,charge=0,flash=0} end
function Physics.controls(c,crank,dx,dy,dt) c.power=math.max(0,math.min(1,c.power+crank/540));return dx,dy end
