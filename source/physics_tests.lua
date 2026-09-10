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
check(run(100,-1,0,0,0.25)<run(100,0,0,0,0.25)-30,'opposite input brakes')
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
print('PASS: reconstructed v0.2 slopes and braking tests')
