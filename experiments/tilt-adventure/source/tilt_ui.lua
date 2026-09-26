-- A compact visual layer for the independent tilt edition.
local g=playdate.graphics
local art=g.image.new('title-art')
local titleText=g.image.new(120,46,g.kColorClear)
g.pushContext(titleText);g.drawText('SKY',0,0);g.drawText('HAMSTER',0,21);g.popContext()
function UI.title(choice,effects,music)
 g.clear(g.kColorWhite)
 local t=playdate.getCurrentTimeMilliseconds()/1000
 if art then art:draw(0,math.floor(math.sin(t)*2)) end
 g.setColor(g.kColorWhite);g.fillRoundRect(8,9,158,111,5)
 g.setColor(g.kColorBlack);titleText:drawScaled(17,15,1.5)
 g.drawText('TILT ADVENTURE',17,92)
 for i=1,3 do local x=285+i*23;local y=24+math.sin(t+i)*4;g.drawLine(x-2,y,x+2,y);g.drawLine(x,y-2,x,y+2) end
 local labels={'CONTINUE','LEVEL SELECT',effects and 'SFX: ON' or 'SFX: OFF',music and 'MUSIC: ON' or 'MUSIC: OFF'}
 for i=1,4 do local y=127+(i-1)*21
  g.setColor(i==choice and g.kColorBlack or g.kColorWhite);g.fillRoundRect(10,y,156,20,4)
  g.setImageDrawMode(i==choice and g.kDrawModeFillWhite or g.kDrawModeCopy);g.drawText(labels[i],18,y+1)
 end
 g.setImageDrawMode(g.kDrawModeCopy);g.setColor(g.kColorWhite);g.fillRect(0,216,400,24);g.setColor(g.kColorBlack)
 g.drawText('D-pad: choose  A: confirm',10,219)
end
function UI.calibration()
 g.clear(g.kColorWhite);UI.panel(22,35,356,165)
 g.drawTextAligned('FIND YOUR BALANCE',200,49,kTextAlignment.center)
 g.drawText('Hold at a comfortable playing angle.',37,82)
 g.drawText('Keep still for a moment.',37,108)
 g.drawRect(45,148,310,12);g.fillRect(47,150,math.floor(306*math.min(1,Tilt.time/.8)),8)
 g.drawText('Recenter any time: D-pad DOWN',37,176)
end
function UI.lesson(jump,kind)
 g.clear(g.kColorWhite);UI.header('SKY HAMSTER / TILT')
 if kind=='control' then
  g.drawText('Roll slowly onto the CONTROL pad.',12,58);g.drawText('Crank to rotate the bridge.',12,87)
  g.drawText('B: leave. Move away before re-entry.',12,116)
 elseif kind=='cannon' or kind=='relay' then
  g.drawText('Roll slowly into the cannon.',12,58);g.drawText('Crank: aim   A: fire   B: exit',12,87)
  g.drawText('Dots show the flight path.',12,116)
 else
  g.drawText('Tilt gently to roll. More tilt = force.',12,58)
  g.drawText(jump and 'Quick upward lift or A: jump.' or 'Learn to balance before jumping.',12,87)
  g.drawText('Keep momentum when crossing gaps.',12,116)
 end
 g.drawText('UP: map / pause   DOWN: recenter',12,151)
 g.drawText('A: start   B: level select',12,211)
end
function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
 g.setColor(g.kColorWhite);g.fillRect(0,0,400,43);g.fillRect(0,203,400,37)
 g.setColor(g.kColorBlack);g.fillRect(0,0,400,21);g.setImageDrawMode(g.kDrawModeFillWhite)
 g.drawText(string.format('%02d  %s',level,course.shortName),6,2);g.drawText(string.format('%.1fs / %d',elapsed,falls),265,2)
 g.setImageDrawMode(g.kDrawModeCopy);g.drawText('TILT',7,24);g.drawRect(51,28,86,8);g.fillRect(52,29,math.floor(power*84),6)
 g.drawText(string.format('SPD %03d',math.floor(speed)),282,24)
 if jump then g.drawText(Tilt.cooldown>0 and 'JUMP ...' or 'JUMP READY',149,24) end
 if Dock.active then
  g.drawText(Dock.active.kind=='cannon' and 'CRANK aim / A fire / B exit' or 'CRANK rotate bridge / B exit',8,205)
  g.drawText('Tilt is paused while docked.',8,223)
 else
  g.drawText(jump and 'Tilt: roll   Lift / A: jump' or 'Tilt gently to roll',8,205)
  g.drawText('UP: map   DOWN: recenter',8,223)
 end
end
function UI.ending(completed)
 g.clear(g.kColorWhite);if art then art:draw(0,0) end
 UI.panel(30,55,340,150);g.drawTextAligned('SKY JOURNEY COMPLETE',200,70,kTextAlignment.center)
 local count=0;for _ in pairs(completed) do count=count+1 end
 g.drawTextAligned(string.format('%d / %d courses cleared',count,#Courses),200,107,kTextAlignment.center)
 g.drawTextAligned('Replay to improve your best times.',200,139,kTextAlignment.center)
 g.drawTextAligned('A: title   B: level select',200,176,kTextAlignment.center)
end
