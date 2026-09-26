-- One-bit scene layers and a shared, cached instrument-panel vocabulary.
local g=playdate.graphics
local scene=g.image.new('title-scene')
local regular=g.getSystemFont('normal')
local bold=g.getSystemFont('bold')
UI.motion=true
local function bitmap(w,h,draw)
 local im=g.image.new(w,h,g.kColorClear);g.pushContext(im);g.setImageDrawMode(g.kDrawModeCopy);draw();g.popContext();return im
end
local function ink() g.setColor(g.kColorBlack);g.setImageDrawMode(g.kDrawModeCopy) end
local function text(s,x,y) ink();g.drawText(s,x,y) end
local function center(s,x,y) ink();g.drawTextAligned(s,x,y,kTextAlignment.center) end
local function heading(s,x,y) g.setFont(bold);text(s,x,y);g.setFont(regular) end
local function fit(s,w)
 if g.getTextSize(s)<=w then return s end
 while #s>1 and g.getTextSize(s..'..')>w do s=s:sub(1,-2) end
 return s..'..'
end
local function ball(x,y,r)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(x,y,r);ink();g.drawCircleAtPoint(x,y,r);g.drawCircleAtPoint(x-1,y+1,r-3)
 g.fillCircleAtPoint(x+2,y-1,1);g.drawLine(x-r+2,y-2,x-r+4,y-4)
 if r>=18 then
  g.setColor(g.kColorWhite);g.fillEllipseInRect(x-14,y-9,28,26);ink();g.drawEllipseInRect(x-14,y-9,28,26)
  g.setColor(g.kColorWhite);g.fillCircleAtPoint(x-9,y-10,5);g.fillCircleAtPoint(x+9,y-10,5);ink();g.drawCircleAtPoint(x-9,y-10,5);g.drawCircleAtPoint(x+9,y-10,5)
  g.fillCircleAtPoint(x-6,y-2,2);g.fillCircleAtPoint(x+6,y-2,2);g.fillCircleAtPoint(x,y+4,2)
  g.drawLine(x-10,y+5,x-16,y+3);g.drawLine(x+10,y+5,x+16,y+3);g.drawLine(x-3,y+9,x+3,y+9)
 end
end
local icons={}
local function icon(name,x,y)
 if not icons[name] then icons[name]=bitmap(20,20,function()
  ink()
  if name=='clock' then g.drawCircleAtPoint(10,11,7);g.fillRect(7,0,6,3);g.drawLine(10,6,10,11);g.drawLine(10,11,14,13)
  elseif name=='flag' then g.drawLine(4,2,4,18);g.fillPolygon(5,2,17,4,13,9,5,8);g.drawLine(1,18,9,18)
  elseif name=='jump' then g.drawLine(10,2,10,11);g.drawLine(10,2,5,7);g.drawLine(10,2,15,7);g.drawEllipseInRect(3,13,14,5)
  elseif name=='lock' then g.drawRoundRect(5,1,10,12,4);g.fillRect(3,8,14,11);g.setColor(g.kColorWhite);g.fillCircleAtPoint(10,12,2);g.fillRect(9,12,2,4)
  elseif name=='crank' then g.drawCircleAtPoint(6,13,4);g.drawLine(6,13,14,6);g.fillRoundRect(12,1,5,8,2)
  elseif name=='sound' then g.fillPolygon(2,7,6,7,11,3,11,17,6,13,2,13);g.drawLine(14,6,16,8);g.drawLine(16,8,16,12);g.drawLine(16,12,14,14)
  elseif name=='music' then g.drawLine(8,3,8,15);g.drawLine(8,3,17,1);g.drawLine(17,1,17,13);g.fillEllipseInRect(2,12,7,5);g.fillEllipseInRect(11,10,7,5)
  elseif name=='tilt' then g.drawPolygon(2,6,14,2,18,14,6,18);g.drawLine(7,7,12,6);g.fillCircleAtPoint(12,12,2)
  elseif name=='map' then g.drawPolygon(1,4,7,1,13,4,19,1,19,16,13,19,7,16,1,19);g.drawLine(7,1,7,16);g.drawLine(13,4,13,19)
  else ball(10,10,8) end
 end) end
 icons[name]:draw(x,y)
end
function UI.panel(x,y,w,h)
 ink();g.fillRect(x+3,y+3,w,h);g.setColor(g.kColorWhite);g.fillRect(x,y,w,h);ink();g.drawRect(x,y,w,h);g.drawRect(x+3,y+3,w-6,h-6)
 for _,dx in ipairs({6,w-8}) do for _,dy in ipairs({6,h-8}) do g.fillRect(x+dx,y+dy,2,2) end end
end
local function key(s,x,y,label)
 ink();g.fillRoundRect(x,y,19,19,4);g.setImageDrawMode(g.kDrawModeFillWhite);g.drawTextAligned(s,x+9,y+1,kTextAlignment.center);g.setImageDrawMode(g.kDrawModeCopy)
 if label then text(label,x+24,y+1) end
end
local cloud=bitmap(38,14,function()
 g.setColor(g.kColorWhite);g.fillEllipseInRect(1,6,36,7);g.fillCircleAtPoint(14,7,6);g.fillCircleAtPoint(24,6,5);ink();g.drawLine(5,13,33,13)
end)
local island=bitmap(32,23,function()
 g.setColor(g.kColorWhite);g.fillPolygon(1,5,16,0,30,5,24,15,16,22,7,15);ink();g.drawPolygon(1,5,16,0,30,5,24,15,16,22,7,15)
 g.drawLine(2,6,17,10);g.drawLine(17,10,29,6);g.drawLine(17,10,16,20);g.drawLine(8,10,11,15);g.drawLine(22,10,20,15)
end)
local flags={}
for f=1,4 do flags[f]=bitmap(18,26,function()
 g.setColor(g.kColorWhite);g.fillRect(0,0,3,26);ink();g.fillRect(1,0,1,26)
 local d=({0,2,0,-2})[f];g.fillPolygon(2,1,9,3+d,17,1+d,15,10+d,8,11+d,2,8)
 g.setColor(g.kColorWhite);g.fillRect(4,3,3,3);g.fillRect(10,6+d,3,3)
end) end
local floats={{island,246,71,2.5,.63,.4},{island,278,108,3,1.03,2},{cloud,241,29,2,.42,1.7},{cloud,325,96,2, .77,3.1}}
function UI.scene()
 g.clear(g.kColorBlack);if scene then scene:draw(0,0) end
 local t=UI.motion and playdate.getCurrentTimeMilliseconds()/1000 or 0
 for _,o in ipairs(floats) do o[1]:draw(o[2],o[3]+(UI.motion and math.floor(math.sin(t*o[5]+o[6])*o[4]) or 0)) end
 flags[UI.motion and (math.floor(t*5)%4+1) or 1]:draw(373,63)
end
local menuLabels={bitmap(165,19,function() g.setFont(bold);center('START GAME',82,0);g.setFont(regular) end),bitmap(165,19,function() g.setFont(bold);center('SETTINGS',82,0);g.setFont(regular) end)}
function UI.title(choice)
 UI.scene()
 for i,y in ipairs({145,178}) do menuLabels[i]:draw(20,y);if i==choice then ball(23,y+8,7);g.drawLine(170,y+5,174,y+8);g.drawLine(174,y+8,170,y+11) end end
end
local function page(title,symbol,subtitle)
 UI.scene();UI.panel(8,8,384,223)
 icon(symbol,20,19);heading(title,48,20);g.drawLine(20,44,380,44)
 if subtitle then text(subtitle,23,50) end
end
local function footer(a,b)
 g.setColor(g.kColorWhite);g.fillRect(15,204,370,22);ink();g.drawLine(20,201,380,201)
 key('A',24,208,a);key('B',231,208,b)
end
local function meter(x,y,w,value)
 ink();g.drawRect(x,y,w,8)
 for i=0,math.floor(math.max(0,math.min(1,value))*(w-4)/5)-1 do g.fillRect(x+2+i*5,y+2,3,4) end
end
function UI.settings(choice,effects,music,gesture)
 page('FLIGHT SETTINGS','crank','Make yourself comfortable.')
 local labels={'Sound effects','Music','Scene animation','Lift to jump'}
 local values={effects,music,UI.motion,gesture};local symbols={'sound','music','tilt','jump'}
 for i=1,4 do local y=76+(i-1)*29
  if i==choice then g.drawRoundRect(19,y-2,361,28,4);ball(31,y+11,7) end
  icon(symbols[i],48,y+1);text(labels[i],77,y+2)
  ink();g.drawRoundRect(307,y+4,59,19,7);g.fillCircleAtPoint(values[i] and 355 or 317,y+13,6)
  text(values[i] and 'ON' or 'OFF',values[i] and 312 or 331,y+5)
 end
 footer('change','back')
end
function UI.calibration()
 page('FIND YOUR BALANCE','tilt','Hold at your comfortable playing angle.')
 UI.panel(165,82,70,74);g.drawRoundRect(176,91,48,36,3);ball(200,109,10)
 g.fillRect(179,137,14,4);g.fillRect(184,132,4,14);g.drawCircleAtPoint(216,137,4)
 meter(72,171,256,math.min(1,(Tilt.time or 0)/.8));center('Keep still for a moment',200,184)
end
local lessonInfo={
 control={'CRANK BRIDGE','crank','Roll slowly onto the control pad.','Turn the crank to rotate the bridge.','B releases you. Move away to re-enter.'},
 cannon={'CLOUD CANNON','crank','Roll slowly into the cannon.','Crank to aim. A fires. B exits.','The dots show your flight path.'},
 relay={'FINAL FLIGHT','flag','Aim your cannon at the far platform.','Keep your momentum across the route.','Reach the final flag to finish the journey.'},
 gate={'TIMED GATE','clock','Watch the barrier open and close.','Wait on solid ground for a clear path.','Tilt gently, then cross in one motion.'},
 trap={'VANISHING FLOOR','clock','The floor disappears on a timer.','Watch a full cycle before you cross.','Jump the gap or wait for solid ground.'},
 ferry={'MOVING PLATFORM','map','Wait for the platform at the dock.','Roll aboard, then hold the device level.','Ride across and roll off at the far dock.'},
 rotor={'ROTATING FLOOR','crank','Board the outer end at your dock.','Balance while the floor carries you.','Roll off when it reaches the other side.'},
 sweeper={'SWEEPING PANELS','clock','Panels sweep across the road.','Watch for an open lane before moving.','Avoid the edge: contact pushes you.'}}
function UI.lesson(jump,kind)
 local l=lessonInfo[kind] or (jump and {'LIFT AND LEAP','jump','Give the device a quick upward lift.','A also jumps. Keep moving across gaps.','Wait for the jump indicator to refill.'} or {'LEARN TO BALANCE','tilt','Tilt gently in the direction you want.','More tilt gives the ball more force.','Stay on the road and reach the flag.'})
 page(l[1],l[2])
 for i=1,3 do local y=63+(i-1)*39;ball(32,y+9,8);text(tostring(i),27,y+1);text(l[i+2],52,y) end
 icon('map',26,176);text('UP map     DOWN recenter',53,177);footer('start','courses')
end
local previews={}
local function route(course,x,y,w,h,px,py,t)
 local minX,minY,maxX,maxY=0,0,1,1
 for _,tile in ipairs(course.tiles) do minX=math.min(minX,tile.x);minY=math.min(minY,tile.y);maxX=math.max(maxX,tile.x+1);maxY=math.max(maxY,tile.y+1) end
 for _,m in ipairs(course.mechanisms or {}) do local r=math.max(m.w,m.h)/32
  minX=math.min(minX,m.x/32-r);minY=math.min(minY,m.y/32-r)
  maxX=math.max(maxX,math.max(m.x,m.toX or m.x)/32+r);maxY=math.max(maxY,math.max(m.y,m.toY or m.y)/32+r+(m.range or 0)/32)
 end
 local s=math.min(w/(maxX-minX),h/(maxY-minY));local ox=x+(w-(maxX-minX)*s)/2-minX*s;local oy=y+(h-(maxY-minY)*s)/2-minY*s
 ink();for _,tile in ipairs(course.tiles) do g.fillRect(ox+tile.x*s,oy+tile.y*s,math.max(1,s),math.max(1,s)) end
 if t then for _,m in ipairs(course.mechanisms or {}) do local poly={};for _,p in ipairs(Mechanisms.corners(m,t)) do poly[#poly+1]=ox+p[1]/32*s;poly[#poly+1]=oy+p[2]/32*s end;g.drawPolygon(table.unpack(poly)) end end
 if px then
  local function pin(p,name) if p then local a,b=ox+p[1]/32*s,oy+p[2]/32*s;g.setColor(g.kColorWhite);g.fillRect(a-7,b-9,15,18);if name=='flag' then icon(name,a-10,b-10) else text(name,a-5,b-8) end end end
  pin(course.start,'S');pin(course.checkpoint,'C');pin(course.goal,'flag')
  ball(ox+px/32*s,oy+py/32*s,5)
 end
end
function UI.selector(selected,completed)
 local p=math.floor((selected-1)/6);local first=p*6+1
 page('CHOOSE YOUR ROUTE','map',string.format('%02d  %s',selected,Courses[selected].shortName))
 text(string.format('%d / %d',p+1,math.ceil(#Courses/6)),330,50)
 for n=first,math.min(first+5,#Courses) do
  local c=Courses[n];local x=20+math.floor((n-first)/3)*186;local y=75+(n-first)%3*41
  if n==selected then ink();g.fillRoundRect(x,y,175,37,3) else g.drawRoundRect(x,y,175,37,3) end
  if not previews[n] then previews[n]=bitmap(38,24,function() route(c,1,2,36,20) end) end
  g.setImageDrawMode(n==selected and g.kDrawModeFillWhite or g.kDrawModeCopy);previews[n]:draw(x+7,y+6)
  g.drawText(fit(string.format('%02d %s',n,c.shortName),120),x+49,y+1)
  g.drawText(completed[n] and 'CLEARED' or (c.jump and 'LEAP ROUTE' or 'ROLL ROUTE'),x+49,y+18);g.setImageDrawMode(g.kDrawModeCopy)
 end
 footer('play','back')
end
function UI.map(course,x,y,t)
 page('ROUTE CHART','map',course.shortName..' / PAUSED')
 UI.panel(22,75,356,98);route(course,39,87,320,73,x,y,t)
 icon('ball',24,178);text('YOU',49,179);icon('flag',135,178);text('FINISH',160,179);text('S start / C save',252,179)
 footer('resume','resume')
end
local hudBase,hudKey,readout,readoutKey,bottom,bottomKey
function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
 local id=tostring(level)..tostring(jump)
 if hudKey~=id then hudKey=id;hudBase=bitmap(400,43,function()
  g.setColor(g.kColorWhite);g.fillRect(0,0,400,43);ink();g.drawLine(0,42,400,42);g.drawLine(2,40,398,40)
  icon('flag',5,1);text(string.format('%02d %s',level,course.shortName),28,2)
  icon('tilt',5,21);meter(31,27,95,0);icon(jump and 'jump' or 'lock',147,21);if jump then meter(171,27,55,0) else text('JUMP',173,23) end
  icon('clock',250,0);icon('ball',347,0);text('SPEED',251,23)
 end) end
 hudBase:draw(0,0);g.setColor(g.kColorWhite);g.fillRect(4,21,22,19);ink();g.drawCircleAtPoint(15,31,8)
 local dx,dy=Tilt.dx or 0,Tilt.dy or 0;local sx,sy=(dx-dy)*.9,(dx+dy)*.45;local length=math.sqrt(sx*sx+sy*sy)
 if length>0 then g.fillCircleAtPoint(15+sx/length*power*6,31+sy/length*power*6,2) else g.fillCircleAtPoint(15,31,1) end
 meter(31,27,95,power);if jump then meter(171,27,55,math.max(0,1-Tilt.cooldown/.75)) end
 local value=math.floor(elapsed*10);local vel=math.floor(speed);local rk=string.format('%d/%d/%d',value,falls,vel)
 if rk~=readoutKey then readoutKey=rk;readout=readout or g.image.new(130,40,g.kColorClear);g.pushContext(readout);g.clear(g.kColorClear)
  text(string.format('%02d:%02d.%d',math.floor(value/600),math.floor(value/10)%60,value%10),0,1);text(tostring(falls),101,1);text(string.format('%03d',vel),63,23);g.popContext()
 end
 readout:draw(270,0)
 local dock=Dock.active and Dock.active.kind or 'roll';local bk=dock..tostring(jump)
 if bottomKey~=bk then bottomKey=bk;bottom=bitmap(400,37,function()
  g.setColor(g.kColorWhite);g.fillRect(0,0,400,37);ink();g.drawLine(0,0,400,0);g.drawLine(2,2,398,2)
  if dock~='roll' then icon('crank',7,9);text(dock=='cannon' and 'AIM' or 'ROTATE',32,10);if dock=='cannon' then key('A',148,9,'fire') end;key('B',283,9,'release')
  else icon('tilt',7,9);text('ROLL',32,10);if jump then key('A',95,9,'jump') end;icon('map',193,9);text('UP',218,10);text('DOWN recenter',274,10) end
 end) end
 bottom:draw(0,203)
end
function UI.failure(falls,checkpoint)
 page('BACK TO THE CLOUDS','ball')
 ball(200,90,25);g.drawLine(186,90,192,96);g.drawLine(192,90,186,96);g.drawLine(208,90,214,96);g.drawLine(214,90,208,96)
 center('Every flight teaches you something.',200,131)
 center(checkpoint and 'Your checkpoint is safe.' or 'Try again from the starting pad.',200,156)
 footer('retry','courses')
end
function UI.result(elapsed,falls,best,last)
 UI.panel(43,63,314,122);icon('flag',61,78);text('ROUTE COMPLETE',91,79)
 icon('clock',62,111);text(string.format('%.1fs  /  BEST %.1fs',elapsed,best),88,112)
 key('A',62,150,last and 'finish' or 'next');key('B',234,150,'retry')
end
function UI.ending(completed)
 local count=0;for _,v in pairs(completed) do if v then count=count+1 end end
 page('THE SKY IS YOURS','flag');ball(200,89,25)
 center(string.format('%02d / %02d ROUTES CLEARED',count,#Courses),200,132)
 center('Return to the sky. Beat your best time.',200,164);footer('title','courses')
end

-- World callouts stay in the final foreground pass, above the rolling ball.
local signCache={}
function UI.worldSign(label,x,y)
 if not signCache[label] then signCache[label]=bitmap(78,25,function()
  UI.panel(0,0,75,22);g.setFont(bold);g.drawTextAligned(label,37,3,kTextAlignment.center);g.setFont(regular)
 end) end
 signCache[label]:draw(x,y)
end
