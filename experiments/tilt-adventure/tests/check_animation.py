from check_workshop import lua
lua.execute('''
local c=Courses[19];Dock.reset(c);MachineArt.time=0
Dock.update(c,224,80,0,0,false,90,false,false)
assert(Dock.active.spin==90 and c.mechanisms[1].spin==90 and c.mechanisms[1].elevation==22.5)
Dock.update(c,224,80,0,0,false,0,false,false);assert(c.mechanisms[1].spin==90)
Dock.update(c,224,80,0,0,false,-45,false,false);assert(c.mechanisms[1].spin==45 and c.mechanisms[1].elevation==11.25)
c=Courses[14];Dock.reset(c);Mechanisms.collide(c,218,112,100,0,0,2,.01);assert(c.mechanisms[1].hitAt==2)
c=Courses[40];Dock.reset(c);MachineArt.time=0
Dock.update(c,240,112,0,0,false,-90,false,false)
local a,b=c.mechanisms[1],c.mechanisms[2]
assert(Mechanisms.wallHeight(a,0)==0 and Mechanisms.wallHeight(b,0)==80)
assert(math.abs(Mechanisms.wallHeight(a,.12)-40)<.001 and math.abs(Mechanisms.wallHeight(b,.12)-40)<.001)
assert(Mechanisms.wallHeight(a,.3)==80 and Mechanisms.wallHeight(b,.3)==0)
local x,y,v=Mechanisms.collide(c,330,64,100,0,45,.12,.01);assert(x==330 and v==100,'clearance follows animated height')
x,y,v=Mechanisms.collide(c,330,64,100,0,30,.12,.01);assert(x<330 and v<=0,'lower contact hits moving shutter')
print('PASS: crank angle synchronization, stop/reverse, lift travel, impact-triggered spring, smooth shutters and matching collision height')
''')
