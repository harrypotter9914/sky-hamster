Courses={}
local function create(name,hint,profile,start,goal)
 local c={name=name,hint=hint,profile=profile,start=start,goal=goal,tiles={},lookup={}}
 function c:add(x,y)
  local k=x..","..y
  if not self.lookup[k] then self.lookup[k]=true;self.tiles[#self.tiles+1]={x=x,y=y} end
 end
 function c:rect(x1,x2,y1,y2) for x=x1,x2 do for y=y1,y2 do self:add(x,y) end end end
 function c:height(x,y)
  local bounds=self.upperLipBounds
  if bounds and x>=bounds[1] and x<bounds[2] and y>=bounds[3] and y<bounds[4] then
   for _,lip in ipairs(self.upperLips) do
    if x>=lip[1] and x<lip[2] and y>=lip[3] and y<lip[4] then return lip[5],0,0 end
   end
  end
  for i=1,#self.profile-1 do
   local a,b=self.profile[i],self.profile[i+1]
   if x<b[1] then
    local slope=(b[2]-a[2])/(b[1]-a[1])
    return a[2]+math.max(0,x-a[1])*slope,slope,0
   end
  end
  return self.profile[#self.profile][2],0,0
 end
 Courses[#Courses+1]=c;return c
end
local c=create('01 / CORNER SCHOOL','Build speed, then counter-steer to brake.',{{0,0},{700,0}},{48,48},{512,64})
c:rect(0,3,0,2);c:rect(4,8,1,1);c:rect(8,8,2,5);c:rect(9,12,5,5);c:rect(12,12,2,4);c:rect(13,16,1,3)
c.checkpoint={272,176}
c=create('02 / ZERO-THROTTLE DROP','Leave POWER at 0: gravity rolls you downhill.',{{0,110},{64,110},{256,14},{448,14}},{80,80},{400,80})
c:rect(0,13,1,3)
c=create('03 / MOMENTUM VALLEY','Use the descent to climb the opposite ramp.',{{0,110},{64,110},{224,6},{256,6},{448,92},{544,92}},{80,80},{496,80})
c:rect(0,16,1,3)
c=create('04 / BRAKE AT THE BEND','Gain speed downhill. Brake before the narrow turn.',{{0,100},{64,100},{224,12},{640,12}},{80,80},{560,208})
c:rect(0,6,1,3);c:rect(7,10,2,2);c:rect(10,10,3,6);c:rect(11,14,6,6);c:rect(15,18,5,7)
c.checkpoint={336,80}
c=create('05 / FIRST HOP','Reverse crank charges. A jumps. Keep momentum.',{{0,0},{800,0}},{48,80},{368,80})
c:rect(0,4,1,3);c:rect(6,12,1,3)
c=create('06 / PRECISION LANDING','Choose speed AND jump charge for the landing.',{{0,0},{800,0}},{48,80},{448,80})
c:rect(0,4,1,3);c:rect(7,9,2,2);c:rect(11,15,1,3)
c.checkpoint={272,80}
c=create('07 / JUMP CHAIN','Land, rebuild charge, and jump again.',{{0,0},{1200,0}},{48,80},{720,80})
c:rect(0,4,1,3);c:rect(6,10,1,3);c:rect(13,17,1,3);c:rect(19,24,1,3);c.checkpoint={464,80}
c=create('08 / TIMED GATE','Wait for GO. Coast into the opening.',{{0,0},{800,0}},{48,80},{528,80})
c:rect(0,17,1,3);c.mechanisms={{kind='gate',x=240,y=80,w=16,h=104,period=6,openFor=0.45,phase=3}}
c.lesson='gate'
c=create('09 / VANISHING FLOOR','CROSS is solid. HOLE means empty space.',{{0,0},{800,0}},{48,80},{560,80})
c:rect(0,4,1,3);c:rect(7,11,1,3);c:rect(14,18,1,3);c.checkpoint={304,80}
c.mechanisms={{kind='trap',x=192,y=80,w=64,h=96,period=6,phase=3},{kind='trap',x=416,y=80,w=64,h=96,period=7,phase=4}}
c.lesson='trap'
c=create('10 / SHUTTLE','Board at the dock. Coast while you ride.',{{0,0},{900,0}},{48,80},{592,80})
c:rect(0,4,1,3);c:rect(15,19,1,3)
c.mechanisms={{kind='ferry',x=184,y=80,toX=456,toY=80,w=80,h=80,period=12}}
c.lesson='ferry'
c=create('11 / TURN TABLE','Ride the outer end to the other dock.',{{0,0},{800,0}},{48,176},{496,176})
c:rect(0,4,4,6);c:rect(11,16,4,6)
c.mechanisms={{kind='rotor',x=256,y=176,w=224,h=64,period=14}}
c.lesson='rotor'
c=create('12 / SIDE SWEEP','Watch the panels, then take the clear lane.',{{0,0},{900,0}},{48,112},{656,112})
c:rect(0,6,1,5);c:rect(7,11,2,4);c:rect(12,21,1,5);c.checkpoint={464,112}
c.mechanisms={{kind='sweeper',x=240,y=112,w=18,h=70,range=74,period=5},{kind='sweeper',x=448,y=112,w=18,h=78,range=80,period=6,phase=2}}
c.lesson='sweeper'
c=create('13 / VALLEY RELAY','Slope, gate, jump, then ride to the finish.',{{0,96},{64,96},{224,0},{1400,0}},{80,80},{1168,80})
c:rect(0,13,1,3);c:rect(16,22,1,3);c:rect(33,37,1,3);c.checkpoint={592,80}
c.mechanisms={{kind='gate',x=336,y=80,w=16,h=104,period=6,phase=3},{kind='ferry',x=760,y=80,toX=1032,toY=80,w=80,h=80,period=12}}
c=create('14 / SKY CIRCUIT','Jump, turn, rotate, dodge, and time the floor.',{{0,72},{64,72},{192,0},{2000,0}},{48,176},{1488,80})
c:rect(0,7,4,6);c:rect(10,15,4,6);c:rect(22,27,4,6);c:rect(26,28,2,4);c:rect(29,35,1,3);c:rect(38,47,1,3)
c.checkpoint={784,176}
c.mechanisms={{kind='rotor',x=608,y=176,w=256,h=64,period=14},{kind='sweeper',x=976,y=80,w=18,h=60,range=64,period=5},{kind='trap',x=1184,y=80,w=64,h=96,period=7,phase=4},{kind='gate',x=1376,y=80,w=16,h=104,period=6,phase=3}}
local names={'Corner school','Downhill','Momentum valley','Brake bend','First hop','Precision','Jump chain','Timed gate','Vanishing floor','Shuttle','Turn table','Side sweep','Valley relay','Sky circuit'}
for i,course in ipairs(Courses) do
 course.shortName=names[i];course.jump=i>=5
 table.sort(course.tiles,function(a,b) return a.x+a.y<b.x+b.y end)
end

local c=create('15 / CRANK CROSSING','Dock, rotate the bridge, then cross.',{{0,0},{800,0}},{48,80},{464,80})
c:rect(0,4,1,3);c:rect(10,15,1,3)
local bridge={kind='rotor',manual=true,angle=math.pi/2,x=240,y=80,w=224,h=64}
c.mechanisms={bridge};c.pads={{kind='bridge',x=112,y=80,target=bridge,initialAngle=math.pi/2}}
c.shortName='Crank crossing';c.lesson='control';c.jump=false
c=create('16 / CANNON CLOUDS','Aim at the landing pad, then fire.',{{0,0},{800,0}},{48,80},{432,80})
c:rect(0,4,1,3);c:rect(9,14,0,5);c.pads={{kind='cannon',x=112,y=80,initialAngle=0}}
c.shortName='Cannon clouds';c.lesson='cannon';c.jump=true
c=create('17 / FINAL FLIGHT','Fire, jump, time the gate, reach home.',{{0,0},{1200,0}},{48,80},{944,80})
c:rect(0,4,1,3);c:rect(9,16,0,5);c:rect(19,30,1,3)
c.pads={{kind='cannon',x=112,y=80,initialAngle=0}};c.checkpoint={432,80}
c.mechanisms={{kind='gate',x=784,y=80,w=16,h=96,period=7,phase=2}}
c.shortName='Final flight';c.lesson='relay';c.jump=true
Courses.create=create
