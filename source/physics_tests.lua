-- Behavioral regressions, executed once at startup in the actual Lua runtime.
import "physics"
import "courses"
local function check(ok,message) assert(ok,'Physics regression: '..message) end
local function run(v,dx,p,s,seconds)
 for _=1,math.floor(seconds*120) do v=Physics.step(v,0,dx,0,p,s,0,1/120) end
 return v
end
check(run(0,0,0,-0.5,1)>80,'zero throttle must roll downhill')
check(run(0,0,0,0,1)==0,'flat zero-throttle ball must stay still')
check(run(100,0,0,0,0.1)>90,'releasing controls must preserve momentum')
check(math.abs(run(100,-1,0,0,0.25)-run(100,0,0,0,0.25))<0.01,'no extra reverse brake')
check(run(0,1,1,0,1)>100,'full throttle should accelerate promptly')
check(run(50,1,0,0,0.1)>40,'zero throttle with forward input must not auto-brake')
check(run(20,0,0,0.5,0.5)<0,'ball must roll back when it cannot climb')
local function valley(initial)
 local x,v=240,initial
 for _=1,600 do local _,s=Courses[3]:height(x,80);v=Physics.step(v,0,0,0,0,s,0,1/120);x=x+v/120;if x>=448 then return true end;if v<0 then return false end end
 return false
end
check(not valley(25),'low momentum should fail the climb')
check(valley(250),'high momentum should clear the climb')
for _,c in ipairs(Courses) do
 check(c.lookup[math.floor(c.start[1]/32)..','..math.floor(c.start[2]/32)],'start must be on track')
 check(c.lookup[math.floor(c.goal[1]/32)..','..math.floor(c.goal[2]/32)],'goal must be on track')
 for i=2,#c.profile-1 do local at=c.profile[i][1];local a=c:height(at-0.001,0);local b=c:height(at+0.001,0);check(math.abs(a-b)<0.01,'ramps must be continuous') end
end
local c=Physics.newControls()
Physics.controls(c,270,1,0,0.1)
check(c.power==0.75,'power accumulates by angle')
Physics.controls(c,0,-1,0,0.01)
check(c.power==0 and c.lastX==-1,'high power reversal clears power and accepts direction')
c.power=0.4
Physics.controls(c,0,1,0,0.01)
check(c.power==0.4,'low power reversal keeps power')
c.power=0.9;c.lastX=1;c.lastY=0
Physics.controls(c,0,1,1,0.01)
check(c.power==0.9,'gentle turn keeps high power')
c=Physics.newControls();Physics.controls(c,-135,1,0,0.1)
check(c.charge==0.5 and c.power==0,'reverse crank charges only jump')
Physics.controls(c,180,1,0,0.1)
check(c.charge==0.5 and c.power==0.5,'forward crank does not spend jump charge')
Physics.controls(c,0,1,0,0.1)
check(c.power==0.5,'power decay waits for idle delay')
Physics.controls(c,0,1,0,1)
check(c.power==0 and c.charge>0,'power decays faster than jump')
local z,vz=0,Physics.launch(1)
local high=0
for i=1,140 do z,vz=Physics.air(z,vz,1/120);high=math.max(high,z) end
check(high>45 and z<0,'charged jump rises and returns to surface')
-- Ballistic gap traversal using actual course support and flight physics.
local function gap(charge,speed)
 local x,z,vz=150,0,Physics.launch(charge)
 for i=1,240 do
  local old=z;z,vz=Physics.air(z,vz,1/120);x=x+speed/120
  if old>=0 and z<=0 and vz<0 then return Courses[5].lookup[math.floor(x/32)..',2']==true end
 end
 return false
end
check(gap(0.5,100),'medium charge and momentum land beyond first gap')
check(not gap(0.05,50),'insufficient jump falls in gap')
print('PASS: slopes, equal reverse force, meters, latch, and ballistic gap tests')

