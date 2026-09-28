-- Stable identities preserve progress when teaching order changes.
local old={};for i,c in ipairs(Courses) do old[i]=c;c.id='legacy-'..i;c.legacyIndex=i end
local create=Courses.create
local function route(id,name,start,goal,profile,note,jump)
 local c=create(name,'',profile or {{0,0},{5000,0}},start,goal)
 c.id=id;c.shortName=name;c.note=note;c.jump=jump~=false;c.mechanisms={};c.pads={};return c
end
local function bumper(c,x,y) local r=BumperModel.radius;c.mechanisms[#c.mechanisms+1]={kind='bumper',x=x,y=y,w=r*2,h=r*2,radius=r,sideHeight=BumperModel.height} end
local function lift(c,x,y,low,high)
 local m={kind='lift',x=x,y=y,w=64,h=64,minHeight=low,maxHeight=high,elevation=low}
 c.mechanisms[#c.mechanisms+1]=m;c.pads[#c.pads+1]={kind='lift',x=x,y=y,target=m};return m
end
local function slider(c,x,y,tx,ty)
 local m={kind='ferry',manual=true,lesson='slider',x=x,y=y,toX=tx,toY=ty,w=80,h=80,progress=0}
 c.mechanisms[#c.mechanisms+1]=m;c.pads[#c.pads+1]={kind='slider',x=x,y=y,target=m};return m
end
local function fan(c,x,y,rx,ry,rw,rh,controlled)
 local m={kind='fan',x=x,y=y,w=40,h=40,angle=math.pi/2,initialAngle=math.pi/2,force=55,region={rx,ry,rw,rh}}
 c.mechanisms[#c.mechanisms+1]=m
 if controlled then c.pads[#c.pads+1]={kind='fan',x=x-48,y=y+32,target=m,initialAngle=math.pi/2} end
 return m
end
local jump=route('hop-bends','Hop and turn',{48,80},{816,240},nil,{'Land before steering around the bend.','Set up each jump on the next straight.'})
jump:rect(0,5,1,3);jump:rect(8,12,1,3);jump:rect(11,13,4,7);jump:rect(14,18,6,8);jump:rect(21,26,6,8);jump.checkpoint={400,240}
local bumps=route('bumpers','Spring garden',{48,112},{560,112},nil,{'Rubber rings rebound on side contact.','Steer around them or jump over them.'})
bumps:rect(0,18,1,5);bumper(bumps,240,112);bumper(bumps,368,64);bumper(bumps,432,144)
local slalom=route('bumper-slalom','Bumper slalom',{48,112},{944,240},{{0,64},{128,64},{352,0},{1200,0}},{'Brake down the slope before the bumpers.','Take the wide side of each bumper.'})
slalom:rect(0,20,1,5);slalom:rect(19,21,6,8);slalom:rect(22,30,6,8)
for i=0,3 do bumper(slalom,272+i*112,80+(i%2)*64) end;bumper(slalom,816,240);slalom.checkpoint={656,240}
local gust=route('crosswind','Crosswind',{48,112},{656,112},nil,{'The gust pushes while you cross.','Counter-tilt to hold the middle lane.'})
gust:rect(0,6,1,5);gust:rect(7,15,2,4);gust:rect(16,21,1,5);fan(gust,208,48,368,112,304,128,false)
local bridge=route('bridge-workshop','Bridge workshop',{48,80},{1008,272},nil,{'Align each bridge before leaving its dock.','B releases. Cross slowly after turning.'})
bridge:rect(0,4,1,3);bridge:rect(10,17,1,3);bridge:rect(16,18,4,8);bridge:rect(19,21,7,9);bridge:rect(27,32,7,9)
for _,p in ipairs({{240,80,112,80},{784,272,656,272}}) do local m={kind='rotor',manual=true,angle=math.pi/2,x=p[1],y=p[2],w=224,h=64};bridge.mechanisms[#bridge.mechanisms+1]=m;bridge.pads[#bridge.pads+1]={kind='bridge',x=p[3],y=p[4],target=m,initialAngle=math.pi/2} end
bridge.checkpoint={560,272}
local elevator=route('lift-school','Going up',{48,80},{464,80},{{0,0},{256,0},{256,96},{800,96}},{'Dock in the middle of the lift.','Crank to the top; B releases you.'},false)
elevator:rect(0,5,1,3);elevator:rect(8,15,1,3);lift(elevator,224,80,0,96)
local towers=route('lift-towers','Two towers',{48,80},{1008,80},{{0,0},{256,0},{256,80},{608,80},{608,176},{800,176},{960,96},{1100,96}},{'Raise each lift until it meets the road.','Crank backward to lower it if needed.'})
towers:rect(0,5,1,3);towers:rect(8,16,1,3);towers:rect(19,32,1,3);lift(towers,224,80,0,80);lift(towers,576,80,80,176);towers.checkpoint={464,80}
local descent=route('switchback','Cloud switchback',{48,48},{400,176},{{0,160},{128,160},{384,80},{640,0},{1000,0}},{'Follow the winding road around the void.','Brake before every narrow hairpin.'})
descent:rect(0,16,0,2);descent:rect(15,17,3,10);descent:rect(4,14,9,11);descent:rect(3,5,5,8);descent:rect(6,12,4,6);descent.checkpoint={144,304}
local shuttle=route('crank-ferry','Crank ferry',{48,80},{624,80},nil,{'Dock on the deck, then crank across.','At the far bank press B and roll off.'},false)
shuttle:rect(0,4,1,3);shuttle:rect(16,20,1,3);slider(shuttle,184,80,488,80)
local zig=route('ferry-zigzag','Ferry zigzag',{48,80},{1136,272},nil,{'Ride both crank ferries to their end stops.','Leave each deck before docking again.'})
zig:rect(0,4,1,3);zig:rect(14,19,6,10);zig:rect(31,36,7,9);slider(zig,184,80,424,272);slider(zig,664,272,968,272);zig.checkpoint={560,272}
local wind=route('wind-dial','Wind workshop',{48,112},{720,112},nil,{'Dock at the fan dial and aim the gust.','Point it along the road, then release.'})
wind:rect(0,7,1,5);wind:rect(8,16,2,4);wind:rect(17,23,1,5);fan(wind,192,80,400,112,384,160,true)
local windrelay=route('wind-relay','Wind and springs',{48,112},{1168,112},nil,{'Aim each gust before entering its lane.','Leave room to avoid the rubber bumpers.'})
windrelay:rect(0,37,1,5);fan(windrelay,192,80,400,112,352,160,true);fan(windrelay,704,80,912,112,352,160,true);bumper(windrelay,432,80);bumper(windrelay,880,144);windrelay.checkpoint={624,112}
local cannons=route('cannon-relay','Cannon relay',{48,80},{1040,240},nil,{'Aim each cannon at the broad landing road.','A fires; B lets you change your plan.'})
cannons:rect(0,4,1,3);cannons:rect(9,19,0,5);cannons:rect(23,33,5,9)
cannons.pads={{kind='cannon',x=112,y=80,initialAngle=0},{kind='cannon',x=560,y=144,initialAngle=.45}};cannons.checkpoint={432,112}
local high=route('high-flight','High flight',{48,80},{1168,80},{{0,0},{256,0},{256,128},{576,128},{960,32},{1400,32}},{'Ride up before aiming the high cannon.','The lower landing is farther away.'})
high:rect(0,5,1,3);high:rect(8,15,1,3);high:rect(21,37,0,5);lift(high,224,80,0,128);high.pads[#high.pads+1]={kind='cannon',x=432,y=80,initialAngle=0};high.checkpoint={944,80}
local gauntlet=route('storm-run','Storm run',{48,112},{1680,112},{{0,96},{128,96},{320,0},{2000,0}},{'Use safe islands between each challenge.','Save progress before the moving decks.'})
gauntlet:rect(0,16,1,5);gauntlet:rect(19,25,1,5);gauntlet:rect(35,41,1,5);gauntlet:rect(44,53,1,5)
bumper(gauntlet,368,112);fan(gauntlet,640,48,736,112,192,128,false)
gauntlet.mechanisms[#gauntlet.mechanisms+1]={kind='gate',x=464,y=112,w=16,h=160,period=6,phase=3}
gauntlet.mechanisms[#gauntlet.mechanisms+1]={kind='ferry',x=848,y=112,toX=1096,toY=112,w=80,h=80,period=12}
gauntlet.mechanisms[#gauntlet.mechanisms+1]={kind='trap',x=1376,y=112,w=64,h=160,period=7,phase=4};gauntlet.checkpoints={{688,112},{1232,112}}
local finale=route('sky-odyssey','Sky odyssey',{48,80},{4208,240},{{0,0},{256,0},{256,96},{704,96},{960,0},{5000,0}},{'A journey through every skill you learned.','Five safe checkpoints divide the voyage.'})
finale:rect(0,5,1,3);finale:rect(8,17,1,3);lift(finale,224,80,0,96)
finale.pads[#finale.pads+1]={kind='cannon',x=496,y=80,initialAngle=0}
finale:rect(22,33,0,4);finale:rect(36,40,1,3);finale:rect(46,53,1,3)
local b={kind='rotor',manual=true,angle=math.pi/2,x=1392,y=80,w=224,h=64};finale.mechanisms[#finale.mechanisms+1]=b;finale.pads[#finale.pads+1]={kind='bridge',x=1264,y=80,target=b,initialAngle=math.pi/2}
finale:rect(63,70,1,5);slider(finale,1752,80,1992,112)
fan(finale,2080,64,2240,112,224,160,true);bumper(finale,2208,144)
finale:rect(73,80,1,5);finale.mechanisms[#finale.mechanisms+1]={kind='trap',x=2304,y=112,w=64,h=160,period=7,phase=4}
finale.mechanisms[#finale.mechanisms+1]={kind='gate',x=2480,y=112,w=16,h=160,period=6,phase=3}
finale:rect(90,96,1,5);finale.mechanisms[#finale.mechanisms+1]={kind='ferry',x=2616,y=112,toX=2856,toY=112,w=80,h=80,period=12}
finale:rect(103,110,1,5);finale.mechanisms[#finale.mechanisms+1]={kind='rotor',x=3200,y=112,w=256,h=64,period=14}
finale:rect(109,111,6,8);finale:rect(112,117,6,8);finale:rect(120,132,6,8)
finale.mechanisms[#finale.mechanisms+1]={kind='sweeper',x=4016,y=240,w=18,h=70,range=74,period=6}
finale.checkpoints={{912,80},{1568,80},{2128,112},{2960,112},{3536,240}}
local order={old[1],old[2],old[3],old[4],old[5],old[6],old[7],jump,old[8],old[9],old[10],old[11],old[12],bumps,slalom,gust,old[15],bridge,elevator,towers,descent,shuttle,zig,wind,windrelay,old[16],cannons,high,old[13],old[14],old[17],gauntlet,finale}
Courses=order;Courses.legacy=old;Courses.indexById={};Courses.legacyIndex={}
Courses.create=create
for i,c in ipairs(Courses) do
 c.name=string.format('%02d / %s',i,string.upper(c.shortName));Courses.indexById[c.id]=i
 if c.legacyIndex then Courses.legacyIndex[c.legacyIndex]=i end
 if c.checkpoints then c.checkpoint=c.checkpoints[1] elseif c.checkpoint then c.checkpoints={c.checkpoint} else c.checkpoints={} end
 table.sort(c.tiles,function(a,b)return a.x+a.y<b.x+b.y end)
end
function Courses.migrate(saved)
 if saved.campaignRevision==2 then return saved end
 local completed,best={},{}
 for k,v in pairs(saved.completed or {}) do local i=Courses.legacyIndex[tonumber(k)];if i then completed[i]=v end end
 for k,v in pairs(saved.best or {}) do local i=Courses.legacyIndex[tonumber(k)];if i then best[tostring(i)]=v end end
 saved.completed=completed;saved.best=best;saved.level=Courses.legacyIndex[tonumber(saved.level)] or 1;saved.campaignRevision=2
 return saved
end
