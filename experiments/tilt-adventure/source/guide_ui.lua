-- Cached device poses; small animated demonstrations run while the world is paused.
local g=playdate.graphics
local function ink() g.setColor(g.kColorBlack);g.setImageDrawMode(g.kDrawModeCopy) end
local function white() g.setColor(g.kColorWhite) end
local function label(s,x,y) ink();g.drawText(s,x,y) end
local function center(s,x,y) ink();g.drawTextAligned(s,x,y,kTextAlignment.center) end
local function sprite(w,h,draw)
 local im=g.image.new(w,h,g.kColorClear);g.pushContext(im);draw();g.popContext();return im
end
local marble=sprite(28,28,function()
 white();g.fillCircleAtPoint(14,14,12);ink();g.drawCircleAtPoint(14,14,12);g.drawCircleAtPoint(13,15,9)
 g.fillCircleAtPoint(9,8,3);g.fillCircleAtPoint(18,8,3);white();g.fillEllipseInRect(6,9,17,14);ink();g.drawEllipseInRect(6,9,17,14)
 g.fillRect(10,12,2,2);g.fillRect(17,12,2,2);g.fillCircleAtPoint(14,17,1)
end)
local devices={}
for n=1,7 do
 local angle=math.rad(({ -14,-7,0,7,14,0,0 })[n]);local pitch=n==6 and .72 or n==7 and .85 or 1
 devices[n]=sprite(94,94,function()
  local function pt(x,y) return 44+x*math.cos(angle)-y*pitch*math.sin(angle),47+x*math.sin(angle)+y*pitch*math.cos(angle) end
  local function poly(points,fill)
   local p={};for i=1,#points,2 do local x,y=pt(points[i],points[i+1]);p[#p+1]=x;p[#p+1]=y end
   if fill then g.fillPolygon(table.unpack(p)) else g.drawPolygon(table.unpack(p)) end
  end
  white();poly({-22,-37,22,-37,27,-32,27,31,21,37,-21,37,-27,31,-27,-32},true)
  ink();poly({-22,-37,22,-37,27,-32,27,31,21,37,-21,37,-27,31,-27,-32})
  poly({-21,-30,21,-30,21,6,-21,6});local ax,ay=pt(0,-12);g.drawCircleAtPoint(ax,ay,8)
  local function line(a,b,c,d) local x,y=pt(a,b);local u,v=pt(c,d);g.drawLine(x,y,u,v) end
  g.setLineWidth(4);line(-17,20,-5,20);line(-11,14,-11,26);g.setLineWidth(1)
  for _,p in ipairs({{11,24},{21,17}}) do local x,y=pt(p[1],p[2]);g.drawCircleAtPoint(x,y,4) end
  line(28,10,37,10);line(37,10,37,20);local x,y=pt(37,21);g.fillCircleAtPoint(x,y,3)
  if n>5 then local y=n==6 and 14 or 80;g.drawLine(30,y,56,y);g.fillTriangle(41,y-6,35,y,47,y) end
 end)
end
local function ball(x,y) marble:draw(math.floor(x-14),math.floor(y-14)) end
local function slab(x,y,w,h)
 white();g.fillRect(x,y,w,h);ink();g.drawRect(x,y,w,h);g.fillRect(x,y+h,w,5)
 g.drawLine(x+3,y+3,x+w-3,y+3)
 for a=x+14,x+w-8,21 do g.drawLine(a,y+4,a,y+h-2) end
end
local function arrow(x,y,dx,dy)
 ink();g.setLineWidth(2);g.drawLine(x,y,x+dx,y+dy);g.setLineWidth(1)
 if math.abs(dx)>math.abs(dy) then local s=dx>0 and 1 or -1;g.fillTriangle(x+dx,y+dy,x+dx-s*6,y+dy-4,x+dx-s*6,y+dy+4)
 else local s=dy>0 and 1 or -1;g.fillTriangle(x+dx,y+dy,x+dx-4,y+dy-s*6,x+dx+4,y+dy-s*6) end
end
local info={
 arrival={'A LITTLE SKY JOURNEY','A little hamster. A big sky to explore.'},
 roll={'TILT TO ROLL','Lean gently. More tilt gives more force.'},
 jump={'LIFT AND LEAP','Lift quickly to jump. A also works.'},
 control={'CRANK THE BRIDGE','Dock slowly. Crank to turn. B releases.'},
 cannon={'READY, AIM, ROLL!','Dock slowly. Crank aims. A fires. B exits.'},
 gate={'WAIT FOR THE OPENING','Wait safely, then roll through the open gate.'},
 trap={'WATCH THE FLOOR','Wait for solid ground, or jump the gap.'},
 ferry={'CATCH A RIDE','Roll aboard. Balance. Roll off at the far dock.'},
 rotor={'ROUND THE CORNER','Ride the rotating floor, then roll off.'},
 sweeper={'MIND THE SWEEPER','Wait for a clear lane. Avoid the moving panel.'}}
function UI.lesson(kind,time)
 kind=info[kind] and kind or 'roll';local t=time or 0;local data=info[kind]
 UI.panel(14,44,372,190);label(data[1],28,54)
 g.drawLine(27,75,372,75)
 local phase=t%4;local u=phase/4
 if kind=='arrival' then
  local frame=math.floor(t/1.6)%3
  slab(54,155,113,12);slab(247,137,94,12)
  if frame==0 then ball(104,140);center('A CURIOUS HAMSTER',200,85)
  elseif frame==1 then ball(106+u*65,129);arrow(178,130,39,-10);center('A ROAD ABOVE THE CLOUDS',200,85)
  else ball(280,122);g.drawLine(329,139,329,106);g.fillPolygon(329,106,349,112,329,119);center('FIND YOUR WAY TO THE FLAG',200,85) end
  for i=0,2 do ink();if i==frame then g.fillCircleAtPoint(187+i*13,181,3) else g.drawCircleAtPoint(187+i*13,181,3) end end
 else
  local n=3;local lift=0
  if kind=='roll' then
   if phase<2 then n=math.max(1,math.min(5,3+math.floor(math.sin(phase*math.pi)*2.4))) else n=phase<3 and 6 or 7 end
  elseif kind=='jump' then lift=phase>.7 and phase<1.15 and -18*math.sin((phase-.7)/.45*math.pi) or 0 end
  devices[n]:draw(41,85+lift)
  if kind=='jump' then arrow(145,137,0,-30);center('QUICK LIFT',93,177)
  elseif kind=='roll' then
   if phase<2 then arrow(32,125,-13,0);arrow(138,125,13,0);center('LEFT / RIGHT',93,180)
   else arrow(142,135,0,phase<3 and -25 or 25);center('FORWARD / BACK',93,180) end
  elseif kind=='control' or kind=='cannon' then
   local a=t*3;g.drawCircleAtPoint(151,131,12);g.drawLine(151,131,151+math.cos(a)*11,131+math.sin(a)*11);g.fillCircleAtPoint(151+math.cos(a)*11,131+math.sin(a)*11,3)
   center('TURN THE CRANK',99,180)
  else center('WATCH THE TIMING',98,180) end
  arrow(171,135,21,0)
  if kind=='roll' then
   slab(212,110,146,51)
   local bx=285+(phase<2 and math.sin(phase*math.pi)*43 or 0);local by=135+(phase>=2 and -math.sin((phase-2)*math.pi)*15 or 0)
   ball(bx,by)
  elseif kind=='jump' then
   slab(211,158,48,12);slab(311,158,50,12)
   local flight=math.max(0,math.min(1,(phase-1)/1.7));ball(239+98*flight,144-math.sin(flight*math.pi)*45)
   if phase<1 then center('READY',284,177) elseif flight<1 then center('JUMP!',284,177) else center('LAND',284,177) end
  elseif kind=='control' or kind=='rotor' then
   slab(210,152,36,12);slab(333,152,32,12)
   local a=kind=='control' and math.max(0,1-phase/2)*math.pi/2 or t*.7
   local dx,dy=math.cos(a)*52,math.sin(a)*27
   ink();g.setLineWidth(14);g.drawLine(289-dx,153-dy,289+dx,153+dy);white();g.setLineWidth(10);g.drawLine(289-dx,151-dy,289+dx,151+dy);g.setLineWidth(1);ink();g.drawCircleAtPoint(289,152,6)
   ball(kind=='control' and 228 or 289+dx*.7,kind=='control' and 137 or 137+dy*.7)
   center(kind=='control' and 'DOCK > TURN > B' or 'RIDE > ROLL OFF',288,180)
  elseif kind=='cannon' then
   slab(211,163,68,9);slab(331,163,32,9)
   Dock.drawCannon(-.6+math.sin(t)*.15,249,166)
   for i=1,7 do g.fillCircleAtPoint(271+i*10,122-math.sin(i/7*math.pi)*17,1) end
   if phase<1 then ball(222+phase*23,147) elseif phase>2 then local q=(phase-2)/2;ball(270+77*q,134-34*math.sin(q*math.pi)+16*q);center('A: FIRE!',292,177) else center('AIM',294,177) end
  elseif kind=='ferry' then
   slab(210,158,30,12);slab(339,158,27,12)
   local travel=(1-math.cos(u*math.pi*2))/2;local px=241+travel*67;slab(px,158,31,12);ball(px+15,144);center('BALANCE ON BOARD',290,102)
  elseif kind=='trap' then
   slab(210,158,44,12);slab(315,158,48,12)
   if phase<2 then slab(254,158,61,12);ball(227+phase*50,144);center('SOLID: CROSS',288,104)
   else ink();for i=0,6 do g.drawLine(256+i*8,158,259+i*8,158) end;ball(233,144);center('GAP: WAIT / JUMP',287,104) end
  elseif kind=='gate' then
   slab(211,160,150,12);local open=phase>2
   if not open then ink();g.fillRect(289,115,12,45);white();for yy=120,153,10 do g.fillRect(290,yy,10,4) end end
   ball(open and 267+(phase-2)*36 or 258,145);center(open and 'OPEN: GO' or 'CLOSED: WAIT',287,95)
  else
   slab(211,143,150,29);local pos=282+math.sin(t*2)*35;ink();g.fillRect(pos,116,12,46)
   white();for yy=120,152,10 do g.fillRect(pos+1,yy,10,4) end
   ball(230,146);center('WAIT FOR A CLEAR LANE',285,96)
  end
 end
 center(data[2],200,197)
 ink();g.drawLine(28,213,370,213);label('A  '..(Guide and Guide.queue and Guide.index==#Guide.queue and 'Play' or 'Next'),29,215);label('B  Replay',286,215)
end
