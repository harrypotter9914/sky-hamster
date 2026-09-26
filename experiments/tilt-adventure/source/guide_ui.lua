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
 windcontrol={'TURN THE WIND','Dock at the dial. Crank to aim; B releases.'},
 bumper={'GIVE SPRINGS SOME SPACE','Springs bounce you away. Steer around them.'}}
local machineArt={}
for _,name in ipairs({'lift','slider','fan','bumper'}) do
 local source=g.image.new('machine-'..name)
 machineArt[name]=image(86,64,function() source:drawScaled(0,0,name=='slider' and .59 or name=='lift' and .72 or 1) end)
end
local cannons={}
local function smallCannon(x,y,n)
 if not cannons[n] then
  local full=image(104,104,function() Dock.drawCannon(-.9+(n-1)*.3,51,96) end)
  cannons[n]=image(72,72,function() full:drawScaled(0,0,.68) end)
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
  elseif kind=='control' or kind=='rotor' then
   slab(209,147,31,14);slab(337,147,34,14)
   local a=kind=='control' and (1-ease((t-1)/2))*math.pi/2 or (1-ease((t-.8)/3))*math.pi/2
   local dx,dy=math.cos(a)*51,math.sin(a)*22
   local nx,ny=-math.sin(a)*6,math.cos(a)*6
   local ax,ay,bx,by=288-dx,145-dy,288+dx,145+dy
   ink();g.fillPolygon(ax+nx,ay+ny+4,bx+nx,by+ny+4,bx-nx,by-ny+4,ax-nx,ay-ny+4)
   white();g.fillPolygon(ax+nx,ay+ny,bx+nx,by+ny,bx-nx,by-ny,ax-nx,ay-ny)
   ink();g.drawPolygon(ax+nx,ay+ny,bx+nx,by+ny,bx-nx,by-ny,ax-nx,ay-ny)
   ink();g.drawCircleAtPoint(288,145,5)
   if kind=='control' then ball(224,134);left='DOCK, THEN CRANK';right=t<3 and 'ALIGN THE BRIDGE' or 'B: RELEASE'
   else local off=ease((t-4)/1);ball(288+off*66,132);left='KEEP BALANCED';right=t<4 and 'RIDE THE DECK' or 'ROLL OFF NOW' end
  elseif kind=='cannon' then
   slab(206,155,78,10);slab(333,155,39,10);smallCannon(208,85,t<1 and 1 or t<2 and 2 or 3)
   local q=ease((t-3)/1.4)
   if t<1 then ball(217+ease(t)*20,142)
   elseif t>=3 then ball(266+87*q,119-29*math.sin(q*math.pi)+23*q) end
   if t>=1 and t<3 then for i=1,6 do ink();g.fillCircleAtPoint(274+i*12,118-24*math.sin(i/6*math.pi)+23*i/6,1) end end
   left=t<1 and 'DOCK SLOWLY' or t<3 and 'TURN TO AIM' or 'PRESS A TO FIRE'
   right=t<1 and 'ENTER THE CANNON' or t<3 and 'CHECK THE ARC' or 'FLY TO THE ROAD'
  elseif kind=='lift' then
   local u=ease((t-1)/2);local sy=148-u*37
   slab(206,157,29,10);slab(335,115,38,10)
   machineArt.lift:draw(246,sy-28);ball(287,sy-18)
   arrow(347,154,0,-24)
   left=t<1 and 'DOCK IN THE CENTER' or t<3 and 'CRANK TO RAISE' or 'B: RELEASE'
   right=t<3 and 'MATCH THE ROAD' or 'ROLL ONTO THE ROAD'
  elseif kind=='slider' then
   slab(205,151,29,13);slab(342,151,30,13)
   local px=221+ease((t-1)/2.5)*48
   machineArt.slider:draw(px,117);ball(px+42,133)
   left=t<1 and 'DOCK ON THE DECK' or t<3.5 and 'CRANK TO TRAVEL' or 'B: RELEASE'
   right=t<3.5 and 'MOVE TO THE FAR BANK' or 'ROLL OFF AT THE DOCK'
  elseif kind=='fan' then
   slab(207,142,166,23);machineArt.fan:draw(210,88)
   local angle=t<3 and math.pi/2 or 0
   for i=1,3 do local d=22+(t*20+i*10)%38;arrow(239+d,122,14*math.cos(angle),10*math.sin(angle)) end
   ball(327,130);left=t<3 and 'COUNTER THE GUST' or 'CRANK AT THE DIAL';right=t<3 and 'STAY ON THE ROAD' or 'AIM ALONG THE ROAD'
  elseif kind=='bumper' then
   slab(207,135,166,29);machineArt.bumper:draw(281,106)
   local q=t%3;local bx=q<1.5 and 234+q*22 or 267-(q-1.5)*22
   ball(bx,137);left='LEAVE SOME ROOM';right='CONTACT BOUNCES BACK'
  elseif kind=='ferry' then
   slab(205,151,35,13);slab(336,151,37,13)
   local travel=ease((t-1.2)/2.6);local px=240+travel*62
   slab(px,151,34,13)
   local bx=t<1.2 and 222+ease(t/1.2)*35 or t<4 and px+17 or 319+ease((t-4)/1.1)*34
   ball(bx,138);left='TILT GENTLY';right=t<1.2 and 'BOARD' or t<4 and 'RIDE' or 'ROLL OFF'
  elseif kind=='trap' then
   slab(205,151,51,13);slab(315,151,57,13)
   local open=t<2
   if not open then slab(256,151,59,13) else ink();for i=0,6 do g.drawLine(258+i*8,151,261+i*8,151) end end
   ball(open and 231 or 231+ease((t-2.5)/2.5)*114,138)
   left='WAIT ON THE ROAD';right=open and 'GAP: WAIT' or 'SOLID: CROSS'
  elseif kind=='gate' then
   slab(205,151,167,13);local open=t>=2.5
   if not open then ink();g.fillRect(285,103,12,48);white();for yy=108,143,10 do g.fillRect(286,yy,10,4) end end
   ball(open and 258+ease((t-2.7)/2)*85 or 258,138)
   left='WAIT, THEN TILT';right=open and 'OPEN: CROSS' or 'CLOSED: WAIT'
  else
   slab(205,128,167,35);local pos=315+math.sin(t*1.1)*28
   ink();g.fillRect(pos,101,12,50);white();for yy=108,143,10 do g.fillRect(pos+1,yy,10,4) end
   ball(233,141);left='KEEP CLEAR';right='WATCH THE PANEL'
  end
  if kind=='jump' then
   liftDevice:draw(48+lift*.31,85+lift*.95)
  else poses[dir][pose]:draw(48,85) end
  if kind=='control' or kind=='cannon' or kind=='lift' or kind=='slider' or kind=='fan' then
   local a=t*2;ink();g.drawCircleAtPoint(151,135,10);g.drawLine(151,135,151+math.cos(a)*9,135+math.sin(a)*9)
  end
  if left=='PRESS A TO FIRE' then UI.key('A',58,175,'Fire') elseif left=='B: RELEASE' then UI.key('B',49,175,'Release') else center(left,96,177) end
  if right=='B: RELEASE' then UI.key('B',233,175,'Release') else center(right,281,177) end
  -- Progress dots stay clear of device and game examples.
  for i=0,2 do ink();if math.floor(t/2)==i then g.fillCircleAtPoint(186+i*14,197,2) else g.drawCircleAtPoint(186+i*14,197,2) end end
 end
 ink();g.drawLine(23,205,377,205)
 UI.key('A',25,210,Guide and Guide.queue and Guide.index==#Guide.queue and (Guide.manual and 'Resume' or 'Play') or 'Next')
 UI.key('B',282,210,Guide.manual and 'Back' or 'Replay')
end
