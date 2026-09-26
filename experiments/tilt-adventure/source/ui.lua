-- High-contrast interface drawn at the device's native 400 x 240 resolution.
UI={}
local markerCandidates={{20,-45},{-92,-45},{20,18},{-92,18}}
function UI.markerOffset(course,point)
 course.markerOffsets=course.markerOffsets or {}
 local cached=course.markerOffsets[point];if cached then return cached[1],cached[2] end
 local best,minimum=markerCandidates[1],math.huge
 -- Pick once from static terrain, so the sign doesn't jump as the ball moves.
 for _,candidate in ipairs(markerCandidates) do
  local score=0
  for dx=12,60,24 do for dy=5,17,12 do
   local sx,sy=candidate[1]+dx,candidate[2]+dy
   local x=point[1]+sx/1.8+sy/0.9
   local y=point[2]-sx/1.8+sy/0.9
   if course.lookup[math.floor(x/32)..','..math.floor(y/32)] then score=score+1 end
  end end
  if score<minimum then best,minimum=candidate,score end
 end
 course.markerOffsets[point]=best;return best[1],best[2]
end
function UI.title(choice,effects,music)
 local g=playdate.graphics
 if not UI.titleImage then
  UI.titleImage=g.image.new(400,240,g.kColorWhite)
  local lettering=g.image.new(180,23,g.kColorClear)
  g.pushContext(lettering);g.setColor(g.kColorBlack);g.drawTextAligned('SKY HAMSTER',90,2,kTextAlignment.center);g.popContext()
  g.pushContext(UI.titleImage);g.setColor(g.kColorBlack)
  lettering:drawScaled(20,15,2)
  g.drawTextAligned('A little ball. A long way down.',200,60,kTextAlignment.center)
  -- A small floating track and its hamster, using the game's native line work.
  g.fillPolygon(112,107,190,130,284,102,284,111,190,139,112,116)
  g.setColor(g.kColorWhite);g.fillPolygon(112,107,190,84,284,102,190,130)
  g.setColor(g.kColorBlack);g.drawPolygon(112,107,190,84,284,102,190,130)
  g.drawLine(150,95,236,116);g.drawLine(157,120,237,93)
  g.setColor(g.kColorWhite);g.fillCircleAtPoint(199,95,16)
  g.setColor(g.kColorBlack);g.drawCircleAtPoint(199,95,16)
  g.fillCircleAtPoint(192,89,4);g.fillCircleAtPoint(205,89,4)
  g.drawCircleAtPoint(199,98,9);g.fillCircleAtPoint(196,96,1);g.fillCircleAtPoint(202,96,1);g.fillCircleAtPoint(199,101,2)
  g.drawText('D-pad: choose    A: confirm',82,221);g.popContext()
 end
 UI.titleImage:draw(0,0)
 local labels={'PLAY','SELECT LEVEL',effects and 'SOUND FX: ON' or 'SOUND FX: OFF',music and 'MUSIC: ON' or 'MUSIC: OFF'}
 for i=1,4 do
  local yy=139+(i-1)*19
  if i==choice then g.setColor(g.kColorBlack);g.fillRoundRect(96,yy,208,19,3);g.setImageDrawMode(g.kDrawModeFillWhite) end
  g.drawTextAligned(labels[i],200,yy+1,kTextAlignment.center);g.setImageDrawMode(g.kDrawModeCopy)
 end
end
function UI.failure(falls,checkpoint)
 local g=playdate.graphics
 UI.header('OFF THE TRACK','One more try?')
 g.drawCircleAtPoint(200,99,24);g.drawLine(188,91,196,99);g.drawLine(196,91,188,99)
 g.drawLine(204,91,212,99);g.drawLine(212,91,204,99);g.drawLine(194,110,206,110)
 g.drawTextAligned(string.format('Falls: %d',falls),200,139,kTextAlignment.center)
 g.drawTextAligned(checkpoint and 'Your checkpoint is safe.' or 'Back to the starting pad.',200,165,kTextAlignment.center)
 g.drawTextAligned('A: retry    B: select level',200,208,kTextAlignment.center)
end
function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
 local g=playdate.graphics
 if not UI.powerHint then
  UI.powerHint=g.image.new(226,24,g.kColorWhite)
  g.pushContext(UI.powerHint);g.setColor(g.kColorBlack);g.drawRect(0,0,226,24)
  g.drawText('Turn clockwise for POWER',5,3);g.popContext()
 end
 if UI.hudCourse~=course then
  UI.hudCourse=course;UI.timerText=nil;UI.speedText=nil
  UI.hudTop=g.image.new(400,44,g.kColorWhite);UI.hudBottom=g.image.new(400,36,g.kColorWhite)
  UI.timerImage=g.image.new(136,21,g.kColorBlack);UI.speedImage=g.image.new(43,20,g.kColorWhite)
  g.pushContext(UI.hudTop);g.setColor(g.kColorBlack);g.fillRect(0,0,400,21)
  g.setImageDrawMode(g.kDrawModeFillWhite);g.drawText(string.format('%02d  %s',level,course.shortName),7,2);g.setImageDrawMode(g.kDrawModeCopy)
  g.drawText('POWER',7,25);g.drawRect(67,28,86,8)
  local notch=68+84*Physics.tuning.latch;g.drawLine(notch,24,notch,38);g.fillTriangle(notch-3,23,notch+3,23,notch,26)
  if jump then g.drawText('JUMP',164,25);g.drawRect(211,28,66,8) else g.drawText('ROLL',165,25) end
  g.drawText('speed',341,25);g.popContext()
  g.pushContext(UI.hudBottom);g.setColor(g.kColorBlack)
  g.drawText(jump and 'Clockwise: POWER    B: retry' or 'Turn clockwise: POWER    B: retry',7,0)
  g.drawText(jump and 'Counterclockwise: JUMP    A: jump' or 'D-pad: steer    Menu: map / levels',7,18);g.popContext()
 end
 local timer=string.format('%.1fs  /  %d falls',elapsed,falls)
 if UI.timerText~=timer then
  UI.timerText=timer;g.pushContext(UI.timerImage);g.clear(g.kColorBlack)
  g.setImageDrawMode(g.kDrawModeFillWhite);g.drawText(timer,0,2);g.popContext()
 end
 local value=math.floor(speed)
 if UI.speedText~=value then
  UI.speedText=value;g.pushContext(UI.speedImage);g.clear(g.kColorWhite);g.setColor(g.kColorBlack);g.drawText(string.format('%03d',value),0,0);g.popContext()
 end
 UI.hudTop:draw(0,0);UI.timerImage:draw(264,0);UI.speedImage:draw(293,25);UI.hudBottom:draw(0,204)
 g.setColor(g.kColorBlack);g.fillRect(68,29,math.floor(power*84),6)
 if jump then g.fillRect(212,29,math.floor(charge*64),6) end
 g.drawLine(0,203,400,203)
end
function UI.moveSelection(selected,direction,count)
 local first=math.floor((selected-1)/6)*6+1
 local col=math.floor((selected-first)/3);local row=(selected-first)%3
 local column=first+col*3
 if direction=='up' then return math.max(column,selected-1) end
 if direction=='down' then return math.min(column+2,count,selected+1) end
 if direction=='right' then
  local target=column+3
  if target>count then return selected end
  return math.min(target+row,count)
 end
 if direction=='left' then
  local target=column-3
  if target<1 then return selected end
  return target+row
 end
 return selected
end
function UI.panel(x,y,w,h)
 local g=playdate.graphics
 g.setColor(g.kColorBlack);g.fillRoundRect(x+3,y+3,w,h,5)
 g.setColor(g.kColorWhite);g.fillRoundRect(x,y,w,h,5)
 g.setColor(g.kColorBlack);g.drawRoundRect(x,y,w,h,5)
end
function UI.header(title,subtitle)
 local g=playdate.graphics;g.clear(g.kColorWhite)
 g.fillRect(0,0,400,32);g.setImageDrawMode(g.kDrawModeFillWhite);g.drawText(title,12,7);g.setImageDrawMode(g.kDrawModeCopy)
 if subtitle then g.drawText(subtitle,12,39) end
end
function UI.selector(selected,completed)
 local g=playdate.graphics
 local page=math.floor((selected-1)/6);local first=page*6+1
 UI.header('SKY HAMSTER / SELECT LEVEL',string.format('Page %d / %d   -   %d courses',page+1,math.ceil(#Courses/6),#Courses))
 for i=first,math.min(first+5,#Courses) do
  local col=math.floor((i-first)/3);local row=(i-first)%3;local x,y=12+col*194,65+row*46
  if i==selected then g.fillRoundRect(x,y,182,40,4);g.setImageDrawMode(g.kDrawModeFillWhite) else g.drawRoundRect(x,y,182,40,4) end
  g.drawText(string.format('%02d  %s',i,Courses[i].shortName),x+7,y+3)
  g.drawText(completed[i] and 'CLEAR' or (i<5 and 'ROLLING' or i<8 and 'JUMP' or i<13 and 'TIMING' or 'MIXED'),x+7,y+21)
  g.setImageDrawMode(g.kDrawModeCopy)
 end
 g.drawText('D-pad: choose    A: play    B: back',12,216)
end
function UI.lesson(jump,kind)
 local g=playdate.graphics
 local lessons={
 gate={'TIMED GATE', 'The panel blocks your path.', 'Wait on solid ground for GO.', 'Release POWER before the barrier.', 'Build a little push and cross the opening.'},
 trap={'VANISHING FLOOR', 'CROSS means the floor is solid.', 'OPENING! warns that it will disappear.', 'HOLE is empty space: you will fall.', 'Time your crossing, or jump the gap.'},
 ferry={'MOVING PLATFORM', 'Wait for the platform at the dock.', 'Roll aboard, then release POWER.', 'The platform carries you across.', 'Roll off when it pauses at the far dock.'},
 rotor={'ROTATING FLOOR', 'Board the outer end near your dock.', 'Coast and let the floor carry you.', 'It turns halfway, then pauses.', 'Roll off at the opposite dock.'},
 sweeper={'MOVING PANELS', 'These panels sweep across the road.', 'Watch for the clear lane.', 'Contact pushes the ball sideways.', 'Stay away from the edge and time your run.'}}
 if kind and lessons[kind] then
  local lines=lessons[kind];UI.header('NEW OBSTACLE / '..lines[1])
  for i=2,#lines do g.drawText(lines[i],12,49+(i-2)*31) end
  g.drawText('A: start    B: level select',17,214);return
 end
 UI.header(jump and 'NEW ABILITY / SPRING JUMP' or 'WELCOME / LEARN TO ROLL')
 if jump then
  g.drawText('Turn counterclockwise to fill JUMP.',17,49)
  g.drawText('Press A to release your spring.',17,75)
  g.drawText('The ball keeps its sideways momentum.',17,101)
  g.drawText('Keep rolling, then jump across the gap.',17,127)
  g.drawText('POWER and JUMP are independent.',17,161)
 else
  g.drawText('Turn clockwise to build POWER.',17,49)
  g.drawText('Hold a direction to push. Stop to coast.',17,75)
  g.drawText('Above the notch: a sharp reversal',17,108)
  g.drawText('resets POWER. Turn again to push.',17,128)
  g.drawText(Build.classroom and 'Reach FINISH without falling.' or 'Jump unlocks in level 05.',17,164)
 end
 g.drawText('A: start    B: level select',17,214)
end
function UI.map(course,x,y,t)
 local g=playdate.graphics
 UI.header('ROUTE MAP / PAUSED','S  Start     C  Checkpoint     F  Finish')
 local maxX,maxY=1,1
 for _,t in ipairs(course.tiles) do maxX=math.max(maxX,t.x+1);maxY=math.max(maxY,t.y+1) end
 for _,m in ipairs(course.mechanisms or {}) do
  maxX=math.max(maxX,(math.max(m.x,m.toX or m.x)+math.max(m.w,m.h)/2)/32)
  maxY=math.max(maxY,(math.max(m.y,m.toY or m.y)+math.max(m.w,m.h)/2+(m.range or 0))/32)
 end
 local scale=math.min(350/maxX,111/maxY)
 local ox,oy=(400-maxX*scale)/2,67
 for _,t in ipairs(course.tiles) do g.drawRect(ox+t.x*scale,oy+t.y*scale,scale,scale) end
 for _,m in ipairs(course.mechanisms or {}) do
  local poly={}
  for _,p in ipairs(Mechanisms.corners(m,t or 0)) do poly[#poly+1]=ox+p[1]/32*scale;poly[#poly+1]=oy+p[2]/32*scale end
  g.drawPolygon(table.unpack(poly))
 end
 local function pin(p,label)
  if not p then return end
  local px,py=ox+p[1]/32*scale,oy+p[2]/32*scale
  g.setColor(g.kColorWhite);g.fillRect(px-6,py-9,14,18);g.setColor(g.kColorBlack);g.drawText(label,px-5,py-8)
 end
 pin(course.start,'S');pin(course.checkpoint,'C');pin(course.goal,'F')
 g.fillCircleAtPoint(ox+x/32*scale,oy+y/32*scale,3)
 g.drawText('Dot = you. Return, then tilt to roll.',12,185)
 g.drawText('A / B: return to game',12,214)
end
