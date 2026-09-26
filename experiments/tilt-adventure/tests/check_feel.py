"""Lift sensitivity and modest counter-steering, plus the complete regression suite."""
from check_render_optimization import lua

lua.execute('''
local grips={{0,0,1},{0,0,-1},{0,1,0},{0,-1,0},{1,0,0},{-1,0,0},{.3,.4,math.sqrt(.75)}}
local function settle(a,dt)
 accel=a
 for i=1,math.ceil(2/dt) do Tilt.update(dt) end
 assert(Tilt.ready and Tilt.armed and Tilt.cooldown==0)
end
local function reset(a,dt) Tilt.startCalibration();settle(a,dt) end
local count=0
for _,hz in ipairs({20,30,50}) do
 local dt=1/hz
 for _,g in ipairs(grips) do
  -- A lighter lift, including a small sideways component, at every neutral pose.
  for _,side in ipairs({0,.3,.45}) do
   reset(g,dt)
   local power,dx,dy=Tilt.power,Tilt.dx,Tilt.dy
   accel={g[1]+side,g[2],g[3]+.55};Tilt.update(dt)
   assert(Tilt.consumeJump(),'moderate lift missed at '..hz..' Hz')
   assert(Tilt.power==power and Tilt.dx==dx and Tilt.dy==dy,'lift altered steering')
   for i=1,math.ceil(.2/dt) do Tilt.update(dt);assert(not Tilt.consumeJump(),'duplicate jump') end
   accel=g
   for i=1,math.ceil(.25/dt) do Tilt.update(dt);assert(not Tilt.consumeJump()) end
   accel={g[1],g[2],g[3]+.55};Tilt.update(dt)
   assert(not Tilt.consumeJump(),'cooldown bypassed')
   settle(g,dt)
   accel={g[1],g[2],g[3]+.55};Tilt.update(dt);assert(Tilt.consumeJump(),'failed to rearm')
   count=count+1
  end
  -- Reject small bumps, negative pulses, and strong sideways shaking.
  for _,pulse in ipairs({{0,0,.3},{0,0,-.8},{.8,0,.6},{0,.8,.6},{.5,0,.49}}) do
   reset(g,dt);accel={g[1]+pulse[1],g[2]+pulse[2],g[3]+pulse[3]}
   for i=1,math.ceil(.15/dt) do Tilt.update(dt);assert(not Tilt.consumeJump(),'non-lift accepted') end
  end
  -- A short rising pulse instead of only an instantaneous step.
  reset(g,dt)
  local triggered=false
  for _,pulse in ipairs({.15,.4,.8,.4,0}) do
   accel={g[1],g[2],g[3]+pulse};Tilt.update(dt)
   triggered= Tilt.consumeJump() or triggered
  end
  assert(triggered,'rising lift pulse missed')
 end
 -- Ordinary gradual rolling of the device must not cause jumps.
 reset({0,0,1},dt)
 for i=1,hz*4 do
  local a=math.sin(i*dt*2)*.7
  accel={math.sin(a),0,math.cos(a)};Tilt.update(dt)
  assert(not Tilt.consumeJump(),'ordinary steering triggered a jump')
 end
 -- New grip after calibration still uses current device Z, with the lower pulse.
 reset({0,.6,.8},dt);settle({.5,0,math.sqrt(.75)},dt)
 accel={.5,0,math.sqrt(.75)+.55};Tilt.update(dt);assert(Tilt.consumeJump())
end
print('PASS: '..count..' moderate lift/grip/rate combinations; pulse shapes, sideways shake rejection, quiet rearm, cooldown, steering isolation')

-- Compare the actual integrator against the previous release's drive force.
local tuning=Physics.tuning
local drive=tuning.drive
local function stop(initial,power,old)
 tuning.drive=old and 150 or drive
 local v,x,t=initial,0,0
 for i=1,60000 do
  local nextV=Physics.step(v,0,-1,0,power,0,0,1/1200)
  if nextV<=0 then
   local fraction=v/(v-nextV)
   return t+fraction/1200,x+v*fraction/2400
  end
  x=x+(v+nextV)/2400;v=nextV;t=t+1/1200
 end
 error('did not stop')
end
for _,speed in ipairs({60,120,200}) do
 for _,power in ipairs({0,.5,1}) do
  local ot,od=stop(speed,power,true)
  local nt,nd=stop(speed,power,false)
  if power==0 then
   assert(nd==od and nt==ot,'unpowered momentum must be unchanged')
  else
   assert(nd<od and nd>od*.96,'stopping adjustment must remain small')
   assert(nt<ot and nt>ot*.96,'stopping time adjustment must remain small')
  end
  print(string.format('BRAKING speed=%d input=%.1f time=%.4f->%.4f distance=%.4f->%.4f reduction=%.2f%%',speed,power,ot,nt,od,nd,(1-nd/od)*100))
 end
end
tuning.drive=drive
local v=Physics.step(200,0,-1,0,1,0,0,1/30)
assert(v>190,'counter-tilt must not abruptly stop or reverse a fast ball')
local coast=Physics.step(120,0,0,0,0,0,0,1/30)
assert(coast>119,'release must retain almost all short-term momentum')
print('PASS: modest stopping-distance change, continuous inertia; existing four-direction landing/cannon/slope regressions also passed')
''')
