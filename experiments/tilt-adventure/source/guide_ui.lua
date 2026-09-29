-- A fixed storyboard grid keeps labels, hardware and demonstrations apart.
local g=playdate.graphics
local function ink() g.setColor(g.kColorBlack);g.setImageDrawMode(g.kDrawModeCopy) end
local function white() g.setColor(g.kColorWhite) end
local function center(s,x,y) ink();g.drawTextAligned(s,x,y,kTextAlignment.center) end
local function image(w,h,draw)
 local im=g.image.new(w,h,g.kColorClear);g.pushContext(im);draw();g.popContext();return im
end
local flatDevice=g.image.new('ui-device-flat')
local liftDevice=image(100,90,function() flatDevice:drawRotated(50,45,-18) end)
local marble=g.image.new('ui-mascot-small')
local poses={}
for _,dir in ipairs({'right','left','up','down'}) do
 poses[dir]={};for i=0,6 do poses[dir][i]=g.image.new('tutorial-turns/'..dir..'-'..i) end
end
local function ball(x,y) marble:draw(math.floor(x-13),math.floor(y-13)) end
local function slab(x,y,w,h)
 white();g.fillRect(x,y,w,h);ink();g.drawRect(x,y,w,h);g.fillRect(x,y+h,w,4)
 g.drawLine(x+2,y+3,x+w-3,y+3)
 for a=x+13,x+w-5,20 do g.drawLine(a,y+4,a,y+h-2) end
end
local function arrow(x,y,dx,dy)
 local n=math.sqrt(dx*dx+dy*dy);if n<1 then return end
 local ux,uy=dx/n,dy/n;ink();g.setLineWidth(2);g.drawLine(x,y,x+dx,y+dy);g.setLineWidth(1)
 g.fillTriangle(x+dx,y+dy,x+dx-ux*6-uy*4,y+dy-uy*6+ux*4,x+dx-ux*6+uy*4,y+dy-uy*6-ux*4)
end
local function flag(x,y)
 ink();g.drawLine(x,y,x,y-28);white();g.fillRect(x+1,y-28,17,12);ink();g.drawRect(x+1,y-28,17,12)
 for a=0,3 do for b=0,2 do if (a+b)%2==0 then g.fillRect(x+2+a*4,y-27+b*4,3,3) end end end
end
local function ease(v) v=math.max(0,math.min(1,v));return v*v*(3-2*v) end
local function crankDevice(x,y,angle)
 -- The arm turns about the shaft on the device; no separate orbit symbol.
 local a=math.rad(angle);local shaftX,shaftY=x+71,y+39
 local tipX,tipY=shaftX+7+math.cos(a)*9,shaftY+math.sin(a)*17
 local function arm()
  ink();g.setLineWidth(5);g.drawLine(shaftX,shaftY,tipX,tipY)
  white();g.setLineWidth(2);g.drawLine(shaftX,shaftY,tipX,tipY);g.setLineWidth(1)
  ink();g.fillRoundRect(tipX-3,tipY-5,7,10,2)
  white();g.fillRoundRect(tipX-1,tipY-3,3,6,1)
 end
 if math.cos(a)<0 then arm() end
 g.setClipRect(x,y,72,90);poses.right[0]:draw(x,y);g.clearClipRect()
 if math.cos(a)>=0 then arm() end
 ink();g.fillCircleAtPoint(shaftX,shaftY,3);white();g.fillCircleAtPoint(shaftX,shaftY,1)
end
local info={
 arrival={'FOLLOW THE SKY ROAD','Roll along the road to reach the flag.'},
 roll={'TIP TO ROLL','Tip from your grip. Follow the road arrow.'},
 jump={'LIFT AND LEAP','Push out from the screen, at its current angle.'},
 control={'CRANK THE BRIDGE','Dock first. Turn the crank. B releases.'},
 cannon={'READY, AIM, ROLL!','Dock. Aim with the crank. A fires; B exits.'},
 gate={'WAIT FOR THE OPENING','Wait behind the barrier, then cross.'},
 trap={'WATCH THE FLOOR','Cross while solid. Wait when it disappears.'},
 ferry={'CATCH A RIDE','Board at the dock. Ride across. Roll off.'},
 rotor={'ROUND THE CORNER','Ride the rotating deck to the next road.'},
 sweeper={'MIND THE SWEEPER','Stay clear until the moving panel passes.'},
 lift={'CRANK UP TO THE CLOUDS','Dock on the lift. Crank up; B releases.'},
 slider={'YOUR OWN SKY FERRY','Dock on the deck. Crank across; B releases.'},
 fan={'READ THE WIND','Counter-tilt. At a dial, crank to aim.'},
 windcontrol={'TURN THE WIND','Aim uphill until GO. B releases.'},
 conveyor={'BELT: ALWAYS MOVING','Rollers carry you. Counter-tilt or jump clear.'},
 jet={'STEAM: TIMED BURSTS','These are air nozzles. Cross when they stop.'},
 magnet={'MAGNET: PULLS IN','The field reaches both edges. Counter-tilt.'},
 extend={'BUILD YOUR CROSSING','Dock. Crank to extend the road. B releases.'},
 switch={'CHOOSE YOUR ROUTE','Crank the dial. One lane opens, one closes.'},
 onboard={'RIDE AND TURN','Board. Crank until the exit says GO. B releases.'},
 bumper={'WATCH THE RUBBER RING','Touch its side to rebound. Jump over its top.'}}
local machineArt={}
for _,name in ipairs({'fan'}) do
 local source=g.image.new('machine-'..name)
 machineArt[name]=image(86,64,function() source:drawScaled(0,0,name=='slider' and .59 or name=='lift' and .72 or 1) end)
end
local cannons={}
local function smallCannon(x,y,n)
 if not cannons[n] then
  local full=image(144,132,function() Dock.drawCannon(-math.pi/3+(n-1)*math.pi/90,70,110) end)
  cannons[n]=image(72,66,function() full:drawScaled(0,0,.5) end)
 end
 cannons[n]:draw(x,y)
end
function UI.lesson(kind,time)
 kind=info[kind] and kind or 'roll';local data=info[kind];local t=(time or 0)%6
 if kind=='windcontrol' then kind='fan' end
 UI.panel(8,8,384,224);center(data[1],200,20)
 ink();g.drawLine(23,43,377,43)
 center(data[2],200,49)
 -- Demonstration lives only inside y=76..169; captions occupy their own rows.
 local left,right='YOUR PLAYDATE','ON THE ROAD'
 if kind=='arrival' then
  local frame=math.floor(t/2)
  center(({'START ON THE ROAD','FOLLOW THE PATH','REACH THE FINISH'})[frame+1],200,78)
  slab(49,145,299,15);flag(327,145)
  -- Three deliberate stills on ONE continuous road: no unexplained drifting.
  ball(({76,192,299})[frame+1],132)
  if frame<2 then arrow(frame==0 and 105 or 221,127,57,0) end
  center('Stay on the stones. Avoid the edge.',200,174)
  for i=0,2 do ink();if frame==i then g.fillCircleAtPoint(186+i*14,197,3) else g.drawCircleAtPoint(186+i*14,197,3) end end
 else
  ink();g.drawLine(179,79,179,190)
  local phase=t/6
  local pose,lift,dir=0,0,'right'
  if kind=='roll' then
   local direction=math.floor(t/1.5);local q=t%1.5
   local lean=math.sin(math.min(1,q/.9)*math.pi/2)
   dir=({'right','left','up','down'})[direction+1];pose=math.floor(lean*6+.5)
   left=({'RIGHT EDGE DOWN','LEFT EDGE DOWN','TOP EDGE DOWN','BOTTOM EDGE DOWN'})[direction+1]
   white();g.fillPolygon(211,129,286,93,366,129,286,169)
   ink();g.drawPolygon(211,129,286,93,366,129,286,169)
   g.drawLine(211,129,211,133);g.drawLine(211,133,286,173);g.drawLine(286,173,366,133);g.drawLine(366,133,366,129)
   g.drawLine(248,111,326,150);g.drawLine(249,149,326,111)
   local v=ease(q/1.1);local wx,wy=-15,15
   if direction==0 then wx=-15+v*30 elseif direction==1 then wx=15-v*30 elseif direction==2 then wy=15-v*30 else wy=-15+v*30 end
   local bx,by=286+(wx-wy)*.9,129+(wx+wy)*.45
   ball(bx,by)
   local dx,dy=({1,-1,0,0})[direction+1],({0,0,-1,1})[direction+1]
   arrow(346,89,(dx-dy)*15,(dx+dy)*7.5)
   right=({'RIGHT / DOWN','LEFT / UP','RIGHT / UP','LEFT / DOWN'})[direction+1]
  elseif kind=='jump' then
   local f=ease((t-1.6)/1.4)
   if t>=1.6 and t<1.85 then lift=-18*ease((t-1.6)/.25) elseif t>=1.85 and t<3 then lift=-18 elseif t>=3 then lift=-18*(1-ease((t-3)/1.2)) end
   slab(207,151,53,13);slab(315,151,57,13)
   ball(235+105*f,138-42*math.sin(f*math.pi))
   arrow(146,141,-10,-31)
   left=t<1.6 and 'KEEP YOUR GRIP' or t<3 and 'LIFT SCREENWARD' or 'RETURN GENTLY'
   right=t<1.6 and 'READY AT THE GAP' or t<3 and 'CLEAR THE GAP' or 'LAND SAFELY'
  elseif kind=='onboard' then
   local u=ease((t-1.5)/2)
   local bx,by,map=Structures.demo(kind,281,133,t,u)
   local px,py=map(t<1.5 and -65*(1-ease(t/1.2)) or 0,t>=4 and -65*ease((t-4)/1.2) or 0,0)
   ball(px,py-13)
   left=t<1.5 and 'BOARD AND DOCK' or t<4 and 'TURN THE CRANK' or 'B: RELEASE'
   right=t<4 and 'LINE UP THE EXIT' or 'GO: ROLL OFF'
  elseif kind=='control' or kind=='rotor' then
   local u=ease((t-1)/2)
   local bx,by,map=Structures.demo(kind,289,133,t,u)
   if kind=='control' then
    local px,py=map(-65,0,0);ball(px,py-13);left='DOCK, THEN CRANK';right=t<3 and 'ALIGN THE BRIDGE' or 'B: RELEASE'
   else
    local px,py=map(ease((t-4)/1)*65,0,0);ball(px,py-13);left='KEEP BALANCED';right=t<4 and 'RIDE THE DECK' or 'ROLL OFF NOW'
   end
  elseif kind=='cannon' then
   local angle=-math.pi/3+ease((t-1)/2)*math.pi/3
   local p={x=0,y=0,angle=angle};local c={height=function()return 0 end}
   local function project(x,y,z) local sx,sy=CannonModel.project(x,y,z);return 232+sx*.5,104+sy*.5 end
   local function island(x0,x1,y0,y1)
    local p={};for _,v in ipairs({{x0,y0},{x1,y0},{x1,y1},{x0,y1}}) do local x,y=project(v[1],v[2],0);p[#p+1]=x;p[#p+1]=y end
    ink();g.fillPolygon(p[3],p[4],p[5],p[6],p[5],p[6]+4,p[3],p[4]+4)
    g.fillPolygon(p[5],p[6],p[7],p[8],p[7],p[8]+4,p[5],p[6]+4)
    white();g.fillPolygon(table.unpack(p));ink();g.drawPolygon(table.unpack(p))
   end
   island(-30,45,-28,28);island(180,250,-25,25)
   smallCannon(197,49,Dock.cannonFrame(angle))
   local function tinyBall(x,y) marble:drawScaled(x-6.5,y-6.5,.5) end
   if t<1 then local x,y=project(-28+ease(t)*28,0,CannonModel.ballCenter);tinyBall(x,y)
   elseif t<3 then
    for i=0,12 do local x,y=project(Dock.trajectory(c,p,i*.07));ink();g.fillCircleAtPoint(x,y,1) end
   else
    local flight=math.min(1,(t-3)/1.4)*(1-CannonModel.exitTime)
    local x,y=project(Dock.trajectory(c,p,flight));tinyBall(x,y)
   end
   left=t<1 and 'DOCK SLOWLY' or t<3 and 'TURN TO AIM' or 'PRESS A TO FIRE'
   right=t<1 and 'ENTER THE CANNON' or t<3 and 'CHECK THE ARC' or 'FLY TO THE ROAD'
  elseif kind=='extend' then
   slab(207,151,38,13);slab(336,151,37,13)
   slab(245,151,math.max(5,ease((t-1)/2)*91),13);ball(227,138)
   MachineArt.sprite('winch',268,133);MachineArt.handle(266,110,math.min(2,math.max(0,t-1))*180)
   left=t<3 and 'CRANK TO EXTEND' or 'B: RELEASE';right=t<3 and 'BUILD THE CROSSING' or 'ROLL ACROSS'
  elseif kind=='switch' then
   slab(207,112,166,14);slab(207,150,166,14)
   local swap=ease((t-2.7)/.5);ink();g.fillRect(294,125+25*swap,10,25*(1-swap));g.fillRect(294,112-25*swap,10,25*swap)
   MachineArt.sprite('switch',351,137);MachineArt.handle(350,107,t*60)
   ball(239,t<3 and 99 or 137);left='TURN THE DIAL';right=t<3 and 'UPPER LANE OPEN' or 'LOWER LANE OPEN'
  elseif kind=='conveyor' then
   slab(207,149,47,13);slab(321,149,52,13)
   Structures.demo('conveyor',288,143,t)
   ball(230+ease(t/5)*108,130);left='COUNTER-TILT';right='BELT CARRIES THE BALL'
  elseif kind=='jet' then
   slab(207,142,166,22);local on=t<2.4
   for i=0,3 do local px=225+i*43;MachineArt.sprite('nozzle',px,155);if on then ink();for j=1,2 do local d=(t*35+j*13)%28;g.drawArc(px+6,121-d,3+j,220,340) end end end
   ball(on and 228 or 228+ease((t-2.4)/2.8)*120,129);left=on and 'WAIT FOR QUIET' or 'TILT TO CROSS';right=on and 'STEAM IS ACTIVE' or 'NOZZLES ARE QUIET'
  elseif kind=='magnet' then
   slab(207,142,166,24);MachineArt.sprite('magnet',342,145);ink();for i=1,2 do g.drawArc(341,122,18+(t*12+i*14)%24,220,320) end
   ball(250+math.sin(t)*12,130);arrow(278,125,25,-8);left='COUNTER THE PULL';right='KEEP YOUR DISTANCE'
  elseif kind=='lift' then
   local u=ease((t-1)/2);local sy=148-u*37
   local bx,by=Structures.demo('lift',287,138,t,u);ball(bx,by-13)
   arrow(347,154,0,-24)
   left=t<1 and 'DOCK IN THE CENTER' or t<3 and 'CRANK TO RAISE' or 'B: RELEASE'
   right=t<3 and 'MATCH THE LEDGE' or 'ROLL TO REAR LEDGE'
  elseif kind=='slider' then
   local px=221+ease((t-1)/2.5)*48
   local bx,by=Structures.demo('slider',288,124,t,ease((t-1)/2.5));ball(bx,by-13)
   left=t<1 and 'DOCK ON THE DECK' or t<3.5 and 'CRANK TO TRAVEL' or 'B: RELEASE'
   right=t<3.5 and 'MOVE TO THE FAR BANK' or 'ROLL OFF AT THE DOCK'
  elseif kind=='fan' then
   local controlled=data==info.windcontrol
   if controlled then
    ink();g.setColor(g.kColorWhite);g.fillPolygon(260,147,315,102,366,116,309,161)
    ink();g.drawPolygon(260,147,315,102,366,116,309,161);g.drawLine(309,161,309,171);g.drawLine(309,171,366,126);g.drawLine(366,126,366,116)
   else slab(207,142,166,23) end
   local angle=controlled and (math.pi/2*(1-ease(t/2))) or math.pi/2
   MachineArt.fan({angle=angle},t,236,131)
   if controlled then local u=ease((t-2)/2.5);ball(277+u*61,137-u*35) else ball(327,130) end;left=controlled and (t<2 and 'CRANK AT THE DIAL' or 'B: RELEASE') or 'COUNTER THE GUST';right=controlled and 'RIDE THE TAILWIND' or 'STAY ON THE ROAD'
  elseif kind=='bumper' then
   slab(207,135,166,29);MachineArt.bumper({hitAt=t-t%3+1.5},t,303,142)
   local q=t%3;local reach=303-(BumperModel.radius+9)*math.sqrt(2)*.9
   local bx=240+(reach-240)*(q<1.5 and q/1.5 or 1-(q-1.5)/1.5)
   ball(bx,130);left='TOUCH THE SIDE';right='THE RING PUSHES BACK'
  elseif kind=='ferry' then
   local travel=ease((t-1.2)/2.6)
   local bx,by,map=Structures.demo('ferry',288,124,1.2+travel*1.8)
   if t<1.2 then bx,by=map(-55+ease(t/1.2)*31,0,0)
   elseif t>=4 then bx,by=map(24+ease((t-4)/1.1)*31,0,0) end
   ball(bx,by-13);left='TILT GENTLY';right=t<1.2 and 'BOARD' or t<4 and 'RIDE' or 'ROLL OFF'
  elseif kind=='trap' then
   slab(205,137,51,13);slab(315,137,57,13)
   local open=t<2
   Structures.demo('trap',286,135,open and 1 or 3)
   ball(open and 231 or 231+ease((t-2.5)/2.5)*114,124)
   left='WAIT ON THE ROAD';right=open and 'GAP: WAIT' or 'SOLID: CROSS'
  elseif kind=='gate' then
   slab(205,151,167,13);local open=t>=2.5
   Structures.demo('gate',296,146,open and .8 or 3)
   ball(open and 258+ease((t-2.7)/2)*85 or 258,138)
   left='WAIT, THEN TILT';right=open and 'OPEN: CROSS' or 'CLOSED: WAIT'
  else
   slab(205,128,167,35);local pos=315+math.sin(t*1.1)*28
   Structures.demo('sweeper',315,139,t)
   ball(233,141);left='KEEP CLEAR';right='WATCH THE PANEL'
  end
  local manual=kind=='onboard' or kind=='control' or kind=='cannon' or kind=='lift' or kind=='slider' or kind=='extend' or kind=='switch' or data==info.windcontrol
  local turn=t*120
  if data==info.windcontrol then turn=-ease(t/2)*90
  elseif kind=='lift' then turn=ease((t-1)/2)*176
  elseif kind=='slider' then turn=ease((t-1)/2.5)*540
  elseif kind=='onboard' then turn=-ease((t-1.5)/2)*90
  elseif kind=='control' then turn=-ease((t-1)/2)*90
  elseif kind=='cannon' then turn=ease((t-1)/2)*60 end
  if kind=='jump' then
   liftDevice:draw(48+lift*.31,85+lift*.95)
  elseif manual then crankDevice(48,85,turn)
  else poses[dir][pose]:draw(48,85) end
  if left=='PRESS A TO FIRE' then UI.key('A',58,175,'Fire') elseif left=='B: RELEASE' then UI.key('B',49,175,'Release') else center(left,96,177) end
  if right=='B: RELEASE' then UI.key('B',233,175,'Release') else center(right,281,177) end
  -- Progress dots stay clear of device and game examples.
  for i=0,2 do ink();if math.floor(t/2)==i then g.fillCircleAtPoint(186+i*14,197,2) else g.drawCircleAtPoint(186+i*14,197,2) end end
 end
 ink();g.drawLine(23,205,377,205)
 UI.key('A',25,210,Guide and Guide.queue and Guide.index==#Guide.queue and (Guide.manual and 'Resume' or 'Play') or 'Next')
 UI.key('B',282,210,Guide.manual and 'Back' or 'Replay')
end
