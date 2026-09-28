from check_campaign import lua
lua.execute('''
local c=Courses[34]
local vx,vy=Mechanisms.wind(c,304,112,0,0,0,.1,0);assert(vy>0 and math.abs(vx)<.001)
vx,vy=Mechanisms.wind(c,304,112,0,0,10,.1,0);assert(vx==0 and vy==0,'belt must not carry airborne ball')
c=Courses[36];vx,vy=Mechanisms.wind(c,304,112,0,0,0,.1,0);assert(vy>10)
vx,vy=Mechanisms.wind(c,304,112,0,0,0,.1,3);assert(vx==0 and vy==0,'quiet steam must not push')
c=Courses[38];Dock.reset(c);assert(not Mechanisms.support(c,280,112,0))
Dock.update(c,144,112,0,0,false,400,false,false);assert(c.mechanisms[1].w==192)
assert(Mechanisms.support(c,280,112,0) and Mechanisms.support(c,384,112,0))
Dock.update(c,144,112,0,0,false,-1000,false,false);assert(c.mechanisms[1].w==16)
c=Courses[40];Dock.reset(c);local a,b=c.mechanisms[1],c.mechanisms[2]
assert(Mechanisms.open(a,0) and not Mechanisms.open(b,0))
MachineArt.time=0;Dock.update(c,240,112,0,0,false,-90,false,false)
assert(not Mechanisms.open(a,.3) and Mechanisms.open(b,.3),'switch must swap lanes after travel')
local x,y,v; x,y,v=Mechanisms.collide(c,330,64,100,0,0,.3,.01);assert(x<330 and v<=0,'closed selected gate blocks')
x,y,v=Mechanisms.collide(c,330,160,100,0,0,.3,.01);assert(x==330 and v==100,'other lane must open')
c=Courses[42];vx,vy=Mechanisms.wind(c,300,100,0,0,0,.1,0);assert(vx>0 and vy<0)
vx,vy=Mechanisms.wind(c,48,112,0,0,0,.1,0);assert(vx==0 and vy==0,'outside magnet field')
assert(#Courses[44].checkpoints==7)
for n=34,44 do selectReady(n);put('lesson',false);for i=1,5 do frame() end end
Guide.seen={arrival=true,roll=true,jump=true};Guide.enter(Courses[44]);local seen={};for _,k in ipairs(Guide.queue) do seen[k]=true end
for _,k in ipairs({'extend','switch','jet','conveyor','magnet'}) do assert(seen[k],'finale missing teaching '..k) end
print('PASS: grounded-only conveyor, timed jet, bridge endpoints/support, paired gates/collision, distance-limited attraction, '..#Courses..'-course runtime, seven checkpoints and new tutorials')
''')
