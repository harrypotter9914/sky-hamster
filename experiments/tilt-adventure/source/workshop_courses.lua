local function route(id,name,len)
 local c=Courses.create(name,'',{{0,0},{6000,0}},{48,112},{len*32-16,112})
 c.id=id;c.shortName=name;c.jump=true;c.mechanisms={};c.pads={};c.checkpoints={}
 c:rect(0,len,1,5);return c
end
local function field(c,kind,x,y,w,h,angle)
 local m={kind=kind,x=x,y=y,w=w,h=h,angle=angle or 0,period=5,phase=0};c.mechanisms[#c.mechanisms+1]=m;return m
end
local function extend(c,x,y,width,px,py)
 local m={kind='rotor',manual=true,retract=true,lesson='extend',anchor=x,x=x+8,y=y,w=16,h=64,maxWidth=width}
 c.mechanisms[#c.mechanisms+1]=m;c.pads[#c.pads+1]={kind='extend',x=px,y=py,target=m}
end
local function switch(c,x)
 local a={kind='gate',switchGate=true,lesson='switch',x=x,y=64,w=16,h=64,initialOpen=true,isOpen=true}
 local b={kind='gate',switchGate=true,lesson='switch',x=x,y=160,w=16,h=64,initialOpen=false,isOpen=false}
 a.partner=b;a.lane=1;b.lane=2;c.mechanisms[#c.mechanisms+1]=a;c.mechanisms[#c.mechanisms+1]=b
 c.pads[#c.pads+1]={kind='switch',x=x-96,y=112,target=a,initialAngle=.5}
end
local c=route('belt-school','Moving stones',18)
field(c,'conveyor',304,112,256,128,math.pi/2);c.note={'The belt moves you only while grounded.','Counter-tilt or jump clear of its pull.'}
c=route('belt-bends','Belt bends',35);c.tiles={};c.lookup={};c:rect(0,12,1,5);c:rect(11,13,6,10);c:rect(14,35,8,10);c.goal={1104,304}
field(c,'conveyor',272,112,224,96,0);field(c,'conveyor',752,304,256,64,math.pi);c.checkpoints={{400,304}};c.note={'One belt speeds you toward a bend.','The next runs against your approach.'}
c=route('jet-school','Steam windows',20);field(c,'jet',304,112,192,128,math.pi/2);c.note={'Nozzles pulse in a regular rhythm.','Wait for the quiet window, then cross.'}
c=route('jet-relay','Pressure alley',40)
for i=0,2 do local m=field(c,'jet',304+i*288,112,160,128,i%2==0 and math.pi/2 or -math.pi/2);m.phase=i*1.7 end
c.checkpoints={{624,112}};c.note={'Read each nozzle bank independently.','Rest on the clear stone between banks.'}
c=route('extend-school','Unfold the road',19);c.tiles={};c.lookup={};c:rect(0,5,1,5);c:rect(12,19,1,5);extend(c,192,112,192,144,112)
c.note={'Dock at the dial and crank the bridge out.','Extend to the far road, then B releases.'}
c=route('extend-relay','Twin drawbridges',38);c.tiles={};c.lookup={};c:rect(0,5,1,5);c:rect(12,20,1,5);c:rect(27,38,1,5)
extend(c,192,112,192,144,112);extend(c,672,112,192,624,112);field(c,'conveyor',1040,112,192,96,math.pi/2);c.checkpoints={{464,112}}
c.note={'Extend two bridges across separate voids.','Keep control when the far belt catches you.'}
c=route('switch-school','Choose a lane',22);c.tiles={};c.lookup={};c:rect(0,7,1,5);c:rect(8,14,1,2);c:rect(8,14,4,5);c:rect(15,22,1,5);switch(c,336)
c.note={'Crank the dial to open one of two lanes.','The other gate closes. Choose your route.'}
c=route('switch-risk','Fork in the wind',36);c.tiles={};c.lookup={};c:rect(0,7,1,5);c:rect(8,25,1,2);c:rect(8,25,4,5);c:rect(26,36,1,5);switch(c,336)
field(c,'conveyor',592,64,288,64,0);field(c,'jet',656,160,160,64,math.pi);c.checkpoints={{912,112}}
c.note={'Choose the fast belt or timed steam lane.','Both routes meet at the checkpoint.'}
c=route('magnet-school','Magnetic island',22);field(c,'magnet',336,48,32,32,0);c.note={'The magnet pulls toward the road edge.','Keep distance and counter its attraction.'}
c=route('magnet-relay','Polar crossing',40)
for i=0,2 do field(c,'magnet',304+i*288,i%2==0 and 48 or 176,32,32,0) end
field(c,'conveyor',720,112,192,96,0);c.checkpoints={{624,112}};c.note={'Attraction alternates between road edges.','Do not let the belt rush your correction.'}
-- Preserve the established finale, then build a separate extended expedition.
local function copy(v,seen)
 if type(v)~='table' then return v end;seen=seen or {};if seen[v] then return seen[v] end
 local r={};seen[v]=r;for k,x in pairs(v) do r[k]=copy(x,seen) end;return r
end
c=copy(Courses[33]);c.id='grand-expedition';c.shortName='Grand expedition';c.goal={5264,240};c.note={'Every machine, one connected expedition.','Seven checkpoints protect your progress.'}
c:rect(133,139,6,8);c:rect(146,166,5,9);extend(c,4480,240,192,4432,240)
field(c,'conveyor',4320,240,192,64,0);field(c,'jet',4832,240,160,128,math.pi/2);field(c,'magnet',5056,176,32,32,0)
-- A two-lane gate station before the new bridge gives a safe routing choice.
local a={kind='gate',switchGate=true,lesson='switch',x=4320,y=208,w=16,h=32,initialOpen=true,isOpen=true}
local b={kind='gate',switchGate=true,lesson='switch',x=4320,y=272,w=16,h=32,initialOpen=false,isOpen=false};a.partner=b;a.lane=1;b.lane=2
c.mechanisms[#c.mechanisms+1]=a;c.mechanisms[#c.mechanisms+1]=b;c.pads[#c.pads+1]={kind='switch',x=4240,y=240,target=a,initialAngle=.5}
c.mechanisms[#c.mechanisms+1]={kind='gate',x=4320,y=240,w=16,h=32,period=1,openFor=0,hideLabel=true}
c.checkpoints[#c.checkpoints+1]={4208,240};c.checkpoints[#c.checkpoints+1]={4752,240};Courses[#Courses+1]=c
for i=34,#Courses do
 local r=Courses[i];r.name=string.format('%02d / %s',i,string.upper(r.shortName));r.checkpoint=r.checkpoints[1];Courses.indexById[r.id]=i
 table.sort(r.tiles,function(a,b)return a.x+a.y<b.x+b.y end)
end
