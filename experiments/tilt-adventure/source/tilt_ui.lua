-- One-bit scene layers and a shared, cached instrument-panel vocabulary.
local g=playdate.graphics
import 'hud_panel'
local scene=g.image.new('title-scene')
local regular=g.font.new('fonts/ui-bold')
local bold=regular
local titleFont=regular
g.setFont(regular)
UI.bodyFont=regular;UI.titleFont=titleFont
UI.motion=true
local portrait=g.image.new('ui-mascot')
local trophy=g.image.new('ui-trophy')
local gripDevice=g.image.new('ui-device')
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
-- Screen-space thrust compass: independent of ball velocity and track orientation.
function UI.tiltPointer(x,y,dx,dy,power)
 local cy=y-29
 local sx,sy=(dx-dy)*.9,(dx+dy)*.45
 local length=math.sqrt(sx*sx+sy*sy)
 ink();g.fillCircleAtPoint(x+1,cy+2,13)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(x,cy,13)
 ink();g.drawCircleAtPoint(x,cy,13)
 g.drawLine(x,cy+14,x,y-13)
 if power<=0 or length<.001 then
  g.drawCircleAtPoint(x,cy,3);g.fillCircleAtPoint(x,cy,1)
  return
 end
 sx,sy=sx/length,sy/length
 local reach=6+4*math.min(1,power)
 local tipX,tipY=x+sx*reach,cy+sy*reach
 local tailX,tailY=x-sx*5,cy-sy*5
 g.drawLine(tailX,tailY,tipX,tipY)
 g.drawLine(tailX-sy,tailY+sx,tipX-sy,tipY+sx)
 g.fillPolygon(tipX,tipY,tipX-sx*5-sy*4,tipY-sy*5+sx*4,tipX-sx*5+sy*4,tipY-sy*5-sx*4)
end
function UI.panel(x,y,w,h)
 ink();g.fillRect(x+3,y+3,w,h);g.setColor(g.kColorWhite);g.fillRect(x,y,w,h);ink();g.drawRect(x,y,w,h);g.drawRect(x+3,y+3,w-6,h-6)
 for _,dx in ipairs({6,w-8}) do for _,dy in ipairs({6,h-8}) do g.fillRect(x+dx,y+dy,2,2) end end
end
local glyphs={
 A={'0011100','0110110','1100011','1100011','1111111','1100011','1100011','1100011','1100011'},
 B={'1111100','1100110','1100011','1100110','1111100','1100110','1100011','1100110','1111100'}}
local upGlyph={'000010000','000111000','001111100','011111110','111111111','000111000','000111000','000111000','000111000'}
local function drawKeycap(button,x,y)
 ink();g.fillRoundRect(x,y,17,17,3);g.setColor(g.kColorWhite)
 local glyph=glyphs[button]
 if glyph then
  for row,line in ipairs(glyph) do for col=1,#line do if line:sub(col,col)=='1' then g.fillRect(x+4+col,y+3+row,1,1) end end end
 elseif button=='crank' then
  g.drawCircleAtPoint(x+6,y+11,3);g.drawLine(x+6,y+11,x+12,y+5);g.fillRect(x+11,y+3,3,5)
 else
  for row,line in ipairs(upGlyph) do for col=1,9 do if line:sub(col,col)=='1' then
   local a,b=col-5,row-5
   if button=='down' then a,b=-a,-b elseif button=='left' then a,b=b,-a elseif button=='right' then a,b=-b,a end
   g.fillRect(x+8+a,y+8+b,1,1)
  end end end
 end
 ink()
end
local keycaps={}
function UI.keycap(button,x,y)
 local cap=keycaps[button]
 if not cap then cap=bitmap(17,17,function() drawKeycap(button,0,0) end);keycaps[button]=cap end
 ink();cap:draw(x,y)
end
function UI.key(button,x,y,label)
 UI.keycap(button,x,y);if label then text(label,x+24,y) end
end
local key=UI.key
local cloud=bitmap(38,14,function()
 g.setColor(g.kColorWhite);g.fillEllipseInRect(1,6,36,7);g.fillCircleAtPoint(14,7,6);g.fillCircleAtPoint(24,6,5);ink();g.drawLine(5,13,33,13)
end)
local island=bitmap(32,23,function()
 g.setColor(g.kColorWhite);g.fillPolygon(1,5,16,0,30,5,24,15,16,22,7,15);ink();g.drawPolygon(1,5,16,0,30,5,24,15,16,22,7,15)
 g.drawLine(2,6,17,10);g.drawLine(17,10,29,6);g.drawLine(17,10,16,20);g.drawLine(8,10,11,15);g.drawLine(22,10,20,15)
end)
-- Generated one-bit cloud banks. Size, transparency and distant contrast are
-- baked into these three sprites: no per-frame scaling, fading or allocation.
local skyClouds={}
for i=1,3 do skyClouds[i]=assert(g.image.new('sky-art/cloud-'..i),'Missing sky cloud '..i) end
function UI.sky(cx,cy,t)
 local drift=UI.motion and t*1.1 or 0
 for i=1,5 do
  local px=((i*137-cx*.12+drift)%540)-90
  local py=48+((i*61-cy*.07)%150)
  skyClouds[(i-1)%3+1]:draw(math.floor(px),math.floor(py))
 end
end
local flags={}
for f=1,4 do flags[f]=bitmap(30,39,function()
 g.setColor(g.kColorWhite);g.fillRoundRect(0,0,5,39,2);ink();g.fillRect(2,1,2,37)
 local d=({0,2,0,-2})[f]
 g.setColor(g.kColorWhite);g.fillPolygon(4,1,16,4+d,28,2+d,26,19+d,15,21+d,4,17)
 ink();g.drawPolygon(4,1,16,4+d,28,2+d,26,19+d,15,21+d,4,17)
 for row=0,2 do for col=0,3 do if (row+col)%2==0 then g.fillRect(6+col*5,5+row*4+math.floor(col*d/3),4,4) end end end
end) end
local cannonTitle=g.image.new('cannon-barrel')
local cannonScene=bitmap(78,75,function()
 -- A deep three-dimensional saddle on the pale foreground paving.
 g.setColor(g.kColorWhite);g.fillPolygon(4,45,40,34,74,45,37,57)
 ink();g.drawPolygon(4,45,40,34,74,45,37,57)
 g.setColor(g.kColorWhite);g.fillPolygon(4,45,37,57,37,72,4,59)
 ink();g.drawPolygon(4,45,37,57,37,72,4,59)
 g.fillPolygon(37,57,74,45,74,60,37,72)
 g.setColor(g.kColorWhite);g.drawLine(41,59,70,49);g.drawLine(41,68,70,58)
 cannonTitle:draw(3,0)
end)
local floats={{island,246,71,2.5,.63,.4},{island,278,108,3,1.03,2},{cloud,241,29,2,.42,1.7},{cloud,325,96,2, .77,3.1}}
function UI.scene()
 g.clear(g.kColorBlack);if scene then scene:draw(0,0) end
 local t=UI.motion and playdate.getCurrentTimeMilliseconds()/1000 or 0
 for _,o in ipairs(floats) do o[1]:draw(o[2],o[3]+(UI.motion and math.floor(math.sin(t*o[5]+o[6])*o[4]) or 0)) end
 flags[UI.motion and (math.floor(t*5)%4+1) or 1]:draw(366,48,g.kImageFlippedX)
 cannonScene:draw(320,161)
end
local menuLabels={};local boards={};local boardY={139,172}
for i,label in ipairs({'Start Game','Settings'}) do
 menuLabels[i]=bitmap(150,19,function()
  g.setFont(regular);g.setFontTracking(1);center(label,75,0);g.setFontTracking(0)
 end)
 boards[i]=bitmap(188,31,function() scene:draw(-8,-boardY[i]) end)
end
local menuLift={0,0};local lastMenuTime
function UI.title(choice)
 UI.scene()
 local now=playdate.getCurrentTimeMilliseconds();local dt=math.min(.1,(now-(lastMenuTime or now))/1000);lastMenuTime=now
 for i,base in ipairs(boardY) do
  local target=i==choice and 3 or 0;menuLift[i]=menuLift[i]+(target-menuLift[i])*math.min(1,dt*18)
  local lift=math.floor(menuLift[i]+.5);local y=base-lift
  -- Raise the original illustrated board, keeping its wooden posts and border.
  ink();g.fillRect(8,base,188,31);boards[i]:draw(8,y)
  menuLabels[i]:draw(27,y+5)
  if i==choice then
   ball(29,y+15,5);g.fillTriangle(173,y+12,178,y+15,173,y+18)
  end
 end
end
local function page(title,symbol,subtitle)
 UI.scene();UI.panel(8,8,384,223)
 icon(symbol,20,19);heading(title,48,20);g.drawLine(20,44,380,44)
 if subtitle then text(subtitle,23,50) end
end
local function footer(a,b)
 g.setColor(g.kColorWhite);g.fillRect(15,204,370,22);ink();g.drawLine(20,201,380,201)
 key('A',24,208,a);if b~=nil then key('B',231,208,b) end
end
local function meter(x,y,w,value)
 ink();g.drawRect(x,y,w,8)
 for i=0,math.floor(math.max(0,math.min(1,value))*(w-4)/5)-1 do g.fillRect(x+2+i*5,y+2,3,4) end
end
function UI.settings(choice,effects,music,gesture)
 page('FLIGHT SETTINGS','crank',CampaignAccess and CampaignAccess.developer and 'DEVELOPER / all routes open this session' or 'Make yourself comfortable.')
 local labels={'Sound effects','Music','Scene animation','Lift to jump','Steering'}
 local values={effects,music,UI.motion,gesture};local symbols={'sound','music','tilt','jump','tilt'}
 -- All row parts share one centerline. A 23px selection with 26px
 -- spacing leaves room for the 19px value capsule without touching neighbors.
 for i=1,5 do local cy=82+(i-1)*26
  if i==choice then g.drawRoundRect(19,cy-11,361,23,4);ball(31,cy,7) end
  icon(symbols[i],48,cy-10);text(labels[i],77,cy-8)
  ink();g.drawRoundRect(275,cy-9,91,19,i==5 and 5 or 7)
  if i==5 then
   center(Tilt.mode=='screen' and 'SCREEN' or 'ROAD',321,cy-8)
  else
   g.fillCircleAtPoint(values[i] and 355 or 286,cy,6)
   center(values[i] and 'ON' or 'OFF',values[i] and 310 or 331,cy-8)
  end
 end
 footer(choice>=5 and 'open' or 'change','back')
end
-- Generated art is loaded once. The paired demonstrations use the same input.
local steeringCard=g.image.new('menu-art/card')
local startCard=g.image.new('menu-art/start-card')
local steeringSmall=g.font.new('fonts/Roobert-9-Mono-Condensed')
local steeringRoad=g.image.new('menu-art/road')
local routeLock=g.image.new('menu-art/lock')
local steeringDevices,steeringBalls={},{}
for i=1,9 do steeringDevices[i]=g.image.new('menu-art/device-'..i) end
for i=1,3 do steeringBalls[i]=g.image.new('menu-art/ball-'..i) end
local controlLabels={'RIGHT EDGE DOWN','LEFT EDGE DOWN','TOP EDGE DOWN','BOTTOM EDGE DOWN'}
local modeVectors={{1,0},{-1,0},{0,-1},{0,1}}
function UI.steering(choice,t,current,onboarding)
 page('CHOOSE YOUR STEERING','tilt')
 -- Every direction returns to neutral before the next demonstration.
 local phase=math.floor(t/2)%4+1;local within=t%2
 local travel=math.sin(math.min(1,within/1.4)*math.pi/2)
 local pose=1
 if within<.2 or within>1.8 then pose=1
 elseif within<.45 or within>1.55 then pose=({2,4,6,8})[phase]
 else pose=({3,4,7,9})[phase] end
 local dx,dy=table.unpack(modeVectors[phase])
 for i,mode in ipairs({'screen','road'}) do
  local x=12+(i-1)*196;local y=58-(i==choice and 3 or 0)
  ink();if i==choice then g.fillRect(x+3,y+5,180,140) end
  steeringCard:draw(x,y)
  if i==choice then g.drawRoundRect(x-1,y-1,182,142,3) end
  if i==choice then g.fillRoundRect(x+14,y+15,152,21,3);g.setImageDrawMode(g.kDrawModeFillWhite) end
  g.drawTextAligned(i==1 and 'SCREEN' or 'ROAD',x+90,y+17,kTextAlignment.center)
  ink()
  if current==mode then g.setColor(i==choice and g.kColorWhite or g.kColorBlack);g.fillCircleAtPoint(x+154,y+25,2);ink() end
  g.setFont(steeringSmall)
  center(controlLabels[phase],x+90,y+39)
  g.setFont(regular)
  steeringDevices[pose]:draw(x+17,y+53)
  steeringRoad:draw(x+75,y+62)
  local sx,sy=dx,dy
  if mode=='road' then sx,sy=(dx-dy)*.9,(dx+dy)*.45;local n=math.sqrt(sx*sx+sy*sy);sx,sy=sx/n,sy/n end
  local mx,my=x+118+sx*17*travel,y+78+sy*17*travel
  local rolling=within>.2 and within<1.4
  steeringBalls[rolling and math.floor(within*9)%3+1 or 1]:draw(math.floor(mx)-12,math.floor(my)-12)
  local names=mode=='screen' and {'Screen right','Screen left','Screen up','Screen down'} or {'Right + down','Left + up','Right + up','Left + down'}
  center(names[phase],x+90,y+107)
 end
 g.setColor(g.kColorWhite);g.fillRect(15,204,370,23);ink()
 UI.keycap('left',21,208);UI.keycap('right',41,208);text('choose',64,208)
 key('A',160,208,'save');key('B',269,208,onboarding and 'intro' or 'cancel')
end
function UI.steeringSaved(mode)
 page('STEERING SAVED','tilt','Ready for your first roll.')
 steeringDevices[1]:draw(56,78)
 steeringRoad:draw(146,86);steeringBalls[1]:draw(178,88)
 center(mode=='road' and 'ROAD DIRECTIONS' or 'SCREEN DIRECTIONS',200,137)
 center('Change this anytime in Settings.',200,159)
 center('Open Steering, choose, then A to save.',200,180)
 footer('continue',nil)
end
function UI.startMenu(choice,level)
 page('READY TO ROLL?','flag','Continue your journey, or start fresh.')
 for i,label in ipairs({'Continue','New Game'}) do
  local y=78+(i-1)*59
  startCard:draw(20,y)
  -- Fixed frame export keeps this menu within the existing page grid.
  if i==choice then ink();g.drawRoundRect(18,y-2,364,52,4) end
  steeringBalls[1]:draw(40,y+13)
  if i==choice then ink();g.fillRoundRect(74,y+8,148,20,3);g.setImageDrawMode(g.kDrawModeFillWhite) end
  g.drawText(label,80,y+9);ink()
  g.setFont(steeringSmall)
  text(i==1 and string.format('Course %02d / resume',level) or 'Course 01 / replay tutorials',76,y+29)
  g.setFont(regular)
 end
 footer('select','title')
end
function UI.newGame(choice)
 page('START NEW GAME','flag','Begin again from Course 1.')
 text('Clears progress, best times and tutorials.',23,77)
 text('Tutorials will appear again.',23,98)
 text('Keep sound settings; choose steering again.',23,119)
 for i,label in ipairs({'Cancel','Start New Game'}) do
  local y=148+(i-1)*25
  if choice==i then ink();g.drawRoundRect(19,y-2,361,24,4);ball(31,y+9,7) end
  text(label,49,y+2)
 end
 footer('select','cancel')
end
function UI.calibration()
 page('HOLD STILL TO CENTER','tilt','Hold comfortably. This grip becomes neutral.')
 gripDevice:draw(162,86)
 meter(72,171,256,math.min(1,(Tilt.time or 0)/.8));center(Tilt.stillReady and 'Keep this grip...' or 'Hold steady for a moment',200,184)
end
local previews={}
local function route(course,x,y,w,h,px,py,t)
 local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
 for _,tile in ipairs(course.tiles) do minX=math.min(minX,tile.x);minY=math.min(minY,tile.y);maxX=math.max(maxX,tile.x+1);maxY=math.max(maxY,tile.y+1) end
 for _,m in ipairs(course.mechanisms or {}) do local r=math.max(m.w,m.h)/32
  minX=math.min(minX,m.x/32-r);minY=math.min(minY,m.y/32-r)
  maxX=math.max(maxX,math.max(m.x,m.toX or m.x)/32+r);maxY=math.max(maxY,math.max(m.y,m.toY or m.y)/32+r+(m.range or 0)/32)
 end
 local s=math.min(w/(maxX-minX),h/(maxY-minY));local ox=x+(w-(maxX-minX)*s)/2-minX*s;local oy=y+(h-(maxY-minY)*s)/2-minY*s
 ink();for _,tile in ipairs(course.tiles) do g.fillRect(ox+tile.x*s,oy+tile.y*s,math.max(1,s),math.max(1,s)) end
 if t then for _,m in ipairs(course.mechanisms or {}) do local poly={};for _,p in ipairs(Mechanisms.corners(m,t)) do poly[#poly+1]=ox+p[1]/32*s;poly[#poly+1]=oy+p[2]/32*s end;g.drawPolygon(table.unpack(poly)) end end
 if px or course.sectionMap then
  local function pin(p,name) if p then local a,b=ox+p[1]/32*s,oy+p[2]/32*s;g.setColor(g.kColorWhite);g.fillRect(a-7,b-9,15,18);if name=='flag' then icon(name,a-10,b-10) else text(name,a-5,b-8) end end end
  pin(course.start,'S');for _,point in ipairs(course.checkpoints or {}) do pin(point,'C') end;pin(course.goal,'flag')
  if px then ball(ox+px/32*s,oy+py/32*s,5) end
 end
end
function UI.selector(selected,completed,allowed,developer)
 allowed=allowed or function(n) return not CampaignAccess or CampaignAccess.allowed(n,completed) end
 local p=math.floor((selected-1)/6);local first=p*6+1
 local unlocked=allowed(selected)
 page('CHOOSE YOUR ROUTE','map',developer and 'DEVELOPER / all routes open' or (unlocked and string.format('%02d  %s',selected,Courses[selected].shortName) or string.format('Clear Course %02d to unlock this route.',selected-1)))
 text(string.format('%d/%d',p+1,math.ceil(#Courses/6)),346,50)
 for n=first,math.min(first+5,#Courses) do
  local c=Courses[n];local x=20+math.floor((n-first)/3)*186;local y=75+(n-first)%3*41
  if n==selected then ink();g.fillRoundRect(x,y,175,37,3) else g.drawRoundRect(x,y,175,37,3) end
  if not previews[n] then previews[n]=bitmap(38,24,function()
   if c.blueprint then
    ink();g.drawRoundRect(1,2,36,20,3);g.drawTextAligned(tostring(c.encounters),19,4,kTextAlignment.center)
   else route(c,1,2,36,20) end
  end) end
  g.setImageDrawMode(g.kDrawModeCopy)
  if not allowed(n) then routeLock:draw(x+14,y+5)
  else g.setImageDrawMode(n==selected and g.kDrawModeFillWhite or g.kDrawModeCopy);previews[n]:draw(x+7,y+6) end
  g.setImageDrawMode(n==selected and g.kDrawModeFillWhite or g.kDrawModeCopy)
  g.drawText(fit(string.format('%02d %s',n,c.shortName),120),x+49,y+3)
  g.drawText(not allowed(n) and 'LOCKED' or completed[n] and 'CLEARED' or (c.finale and 'EXPEDITION' or c.review and 'SKILL REVIEW' or (c.jump and 'LEAP ROUTE' or 'ROLL ROUTE')),x+49,y+18);g.setImageDrawMode(g.kDrawModeCopy)
 end
 footer(unlocked and 'play' or 'locked','back')
end
function UI.map(course,x,y,t)
 page('ROUTE CHART','map',course.shortName..' / PAUSED')
 UI.panel(22,75,356,98)
 if course.sections then
  local index=UI.mapSection or UI.sectionIndex(course,x)
  index=math.max(1,math.min(#course.sections,index));local s=course.sections[index]
  course.mapViews=course.mapViews or {};local view=course.mapViews[index]
  if not view then
   view={tiles={},mechanisms={},checkpoints={s.start},sectionMap=true};course.mapViews[index]=view
   for _,tile in ipairs(course.tiles) do if tile.x*32>=s.x and tile.x*32<s.x+s.width then view.tiles[#view.tiles+1]=tile end end
   for i=s.first,s.last do view.mechanisms[#view.mechanisms+1]=course.mechanisms[i] end
   if index==1 then view.start=course.start end;if index==#course.sections then view.goal=course.goal end
  end
  local names={jet='STEAM JETS',conveyor='CONVEYOR BELT',magnet='MAGNET',windcontrol='WIND DIAL',switch='ROUTE GATES'}
  text(string.format('SECTION %d/%d / %s',index,#course.sections,names[s.kind] or s.kind:upper()),32,80)
  route(view,40,103,320,53,x>=s.x and x<s.x+s.width and x or nil,y,t)
  for i=1,#course.sections do
   local a=32+(i-1)*336/#course.sections;local w=math.max(2,math.floor(336/#course.sections)-2)
   ink();if i==index then g.fillRect(a,162,w,5) else g.drawRect(a,162,w,5) end
  end
  text('< > Sections',252,179)
 else route(course,39,87,320,73,x,y,t);text('S start / C save',252,179) end
 icon('ball',24,178);text('YOU',49,179);icon('flag',135,178);text('FINISH',160,179)
 footer('resume','resume')
end
function UI.sectionIndex(course,x)
 local found=1;for i,s in ipairs(course.sections or {}) do if x>=s.x then found=i else break end end;return found
end
function UI.mapMove(course,x,direction)
 if course.sections then UI.mapSection=math.max(1,math.min(#course.sections,(UI.mapSection or UI.sectionIndex(course,x))+direction)) end
end
-- Fixed-size keycaps and fixed label origins keep both rows aligned.
local function controlHint(button,label,x,y) UI.key(button,x,y,label) end
local bottom,bottomKey
local bottomCache={}
function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
 HudPanel.draw(course,level,jump,power,elapsed,falls,speed)
 local dock=Dock.active and Dock.active.kind or 'roll';local bk=dock..tostring(jump)
 if bottomKey~=bk then bottomKey=bk;bottom=bottomCache[bk]
 if not bottom then bottom=bitmap(400,37,function()
  g.setColor(g.kColorWhite);g.fillRect(0,0,400,37);ink();g.drawLine(0,0,400,0);g.drawLine(2,2,398,2)
  if dock~='roll' then
   controlHint('crank',({cannon='Aim',lift='Raise/lower',slider='Travel',fan='Aim wind',extend='Extend',switch='Route'})[dock] or 'Rotate',8,2)
   if dock=='cannon' then controlHint('A','Fire',138,2) end;controlHint('B','Release',292,2)
  else
   controlHint('up','Map',8,2);controlHint('down','Recenter',138,2)
   if jump then controlHint('A','Jump',292,2) end
  end
  controlHint('left','Help',8,20);controlHint('right','Goal',138,20)
 end);bottomCache[bk]=bottom end end
 bottom:draw(0,203)
end
function UI.prepareHud(course,level,jump)
 local active=Dock.active
 local scratch=g.image.new(400,240,g.kColorClear)
 local modes={false};for _,pad in ipairs(course.pads or {}) do modes[#modes+1]=pad end
 for _,pad in ipairs(modes) do
  Dock.active=pad or nil
  g.pushContext(scratch);UI.hud(course,level,jump,0,0,0,0,0)
  UI.dockStatus('LOCKED');UI.dockStatus('UNLOCKED');g.popContext()
  if Loading then Loading.checkpoint(.74,'PREPARING THE CONTROLS') end
 end
 Dock.active=active
end
function UI.failure(falls,checkpoint)
 page('BACK TO THE CLOUDS','ball')
 portrait:draw(174,68)
 center('Every flight teaches you something.',200,131)
 center(checkpoint and 'Your checkpoint is safe.' or 'Try again from the starting pad.',200,156)
 footer('retry','courses')
end
function UI.result(elapsed,falls,best,last)
 UI.panel(35,53,330,143);trophy:draw(49,76);text('ROUTE COMPLETE',135,69)
 text(string.format('TIME  %.1fs',elapsed),135,96)
 text(string.format('BEST  %.1fs',best),135,118)
 key('A',59,164,last and 'finish' or 'next');key('B',236,164,'retry')
end
function UI.ending(completed)
 local count=0;for _,v in pairs(completed) do if v then count=count+1 end end
 page('THE SKY IS YOURS','flag');trophy:draw(164,63)
 center(string.format('%02d / %02d ROUTES CLEARED',count,#Courses),200,132)
 center('Return to the sky. Beat your best time.',200,164);footer('title','courses')
end

-- World callouts stay in the final foreground pass, above the rolling ball.
local signCache={}
function UI.worldSign(label,x,y,ax,ay)
 if Passage then
  x,y=Passage.labelPosition(x,y,78,25)
  if not x then return end
  if ax then
   g.setColor(g.kColorBlack);Passage.leader(ax,ay,math.max(x+4,math.min(x+74,ax)),math.max(y+3,math.min(y+22,ay)))
  end
  Passage.reserve(x,y,78,25)
 end
 if not signCache[label] then signCache[label]=bitmap(78,25,function()
  UI.panel(0,0,75,22);g.setFont(bold);g.drawTextAligned(label,37,3,kTextAlignment.center);g.setFont(regular)
 end) end
 signCache[label]:draw(x,y)
end

-- Course notes are cached and use current tilt controls, never legacy crank-throttle hints.
local notes={
 {'Build speed on the straight road.','Counter-tilt before the narrow corners.'},
 {'Keep level to coast downhill.','Gravity still acts when tilt is neutral.'},
 {'Use the downhill run for momentum.','Carry enough speed up the far slope.'},
 {'Brake early before the narrow bend.','Opposite tilt takes time to slow you.'},
 {'Approach the gap with some speed.','Lift screenward or press A at the edge.'},
 {'Choose your approach speed carefully.','Land on the small middle platform.'},
 {'Land safely before the next leap.','Wait for jump recovery between gaps.'},
 {'Wait on the road while the gate shuts.','Cross when the barrier opens.'},
 {'Watch the floor before moving ahead.','Cross only while it is solid.'},
 {'Board the moving platform at the dock.','Balance, ride across, then roll off.'},
 {'Board the rotating deck when aligned.','Roll off when it reaches the far road.'},
 {'Keep clear of the moving panels.','Wait for a safe lane, then cross.'},
 {'Control the descent and time the gate.','Jump the gap, then ride the ferry.'},
 {'Combine jumps, rotation and timing.','Use the checkpoint before the finale.'},
 {'Dock at the control station slowly.','Crank the bridge into line; B releases.'},
 {'Roll slowly into the cannon.','Crank to aim; A fires and B exits.'},
 {'Aim the cannon toward the next road.','Save at the checkpoint; time the gate.'}}
local machineNotes={
 gate={'TIMED GATE','Wait while the barrier is closed.','Roll through during the opening.'},
 trap={'VANISHING FLOOR','Missing floor cannot support the ball.','Wait on solid ground for it to return.'},
 ferry={'MOVING PLATFORM','Board only when it reaches your dock.','Balance on it, then roll off across.'},
 rotor={'ROTATING DECK','Ride the deck as it turns.','Leave when it lines up with the road.'},
 sweeper={'MOVING PANEL','The panel can push you off the road.','Keep clear and cross behind it.'},
 control={'CRANK BRIDGE','Dock slowly, then crank to align it.','B releases; leave before docking again.'},
 cannon={'CANNON','Crank to aim; check the dotted arc.','A fires. B leaves without firing.'},
 lift={'LIFT','Dock at the center; crank up or down.','B releases. Match the exit height.'},
 slider={'CRANK FERRY','Dock on the deck; crank to travel.','B releases at the destination.'},
 fan={'WIND','The gust pushes the ball sideways.','At a wind dial, crank to change aim.'},
 bumper={'RUBBER BUMPER','Touch the low ring to bounce outward.','Pass beside it or jump over the top.'},
 conveyor={'CONVEYOR','The belt moves a grounded ball.','Counter-tilt or jump off the belt.'},
 jet={'STEAM NOZZLES','Pulses push hard across the road.','Wait for the quiet part of the cycle.'},
 magnet={'MAGNETIC FIELD','Attraction gets stronger nearby.','Keep distance; counter-tilt early.'},
 extend={'EXTENDING BRIDGE','Dock, then crank the bridge outward.','Reach the far road before releasing.'},
 switch={'ROUTE SWITCH','Crank to open one of two lanes.','One gate opens as the other closes.'},
 onboard={'ONBOARD TURNTABLE','Board and dock at the centre control.','Crank to GO at the exit; B releases.'}}
local goalCache={}
function UI.goalPages(course,level)
 if goalCache[level] then return goalCache[level] end
 local hint=course.note or notes[course.legacyIndex or level] or {'Stay on the road.','Reach the finish flag.'}
 local pages={{'REACH THE FINISH',hint[1],hint[2]},
  {'SAFE PROGRESS',course.checkpoint and 'Touch CHECK to save your retry point.' or 'Falls restart this route from START.',course.jump and 'Jump: lift screenward or press A.' or 'No jumping on this route.'},
  {'PASSAGE SIGNALS','Check mark + GO: this crossing is ready.','Cross + WAIT: wait or adjust the crank.'}}
 local seen={}
 local function add(k) if machineNotes[k] and not seen[k] then pages[#pages+1]=machineNotes[k];seen[k]=true end end
 for _,m in ipairs(course.mechanisms or {}) do add(m.lesson or (m.manual and 'control' or m.kind)) end
 for _,p in ipairs(course.pads or {}) do add(p.kind=='bridge' and 'control' or p.kind) end
 goalCache[level]=pages;return pages
end
function UI.goal(course,level,index)
 local pages=UI.goalPages(course,level);local p=pages[index] or pages[1]
 page('ROUTE GOAL','flag',string.format('%02d  %s',level,course.shortName))
 UI.panel(20,76,360,115)
 center(p[1],200,87);center(p[2],200,117);center(p[3],200,140)
 center(string.format('%d / %d',index,#pages),200,168)
 footer('next page','back')
end

local dockSigns={}
function UI.dockStatus(status)
 if not status then return end
 if not dockSigns[status] then dockSigns[status]=bitmap(110,23,function()
  ink();g.fillRoundRect(0,0,110,23,5);g.setImageDrawMode(g.kDrawModeFillWhite)
  g.drawTextAligned(status,55,4,kTextAlignment.center);g.setImageDrawMode(g.kDrawModeCopy)
 end) end
 dockSigns[status]:draw(145,47)
end
