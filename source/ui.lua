-- High-contrast interface drawn at the device's native 400 x 240 resolution.
UI={names={'Corner school','Downhill','Momentum valley','Brake at the bend','First hop','Precision landing'}}
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
 UI.header('SKY HAMSTER / SELECT LEVEL','01-04: rolling     05-06: rolling + jump')
 for i=1,6 do
  local col=(i-1)%2;local row=math.floor((i-1)/2);local x,y=12+col*194,65+row*46
  if i==selected then g.fillRoundRect(x,y,182,40,4);g.setImageDrawMode(g.kDrawModeFillWhite) else g.drawRoundRect(x,y,182,40,4) end
  g.drawText(string.format('%02d  %s',i,UI.names[i]),x+7,y+3)
  g.drawText(completed[i] and 'CLEAR' or (i<5 and 'ROLLING' or 'JUMP'),x+7,y+21)
  g.setImageDrawMode(g.kDrawModeCopy)
 end
 g.drawText('D-pad: choose    A: play    B: back',12,216)
end
function UI.lesson(jump)
 local g=playdate.graphics
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
  g.drawText('Jump unlocks in level 05.',17,164)
 end
 g.drawText('A: start    B: level select',17,214)
end
function UI.map(course,x,y)
 local g=playdate.graphics
 UI.header('ROUTE MAP / PAUSED','S  Start     C  Checkpoint     F  Finish')
 local maxX,maxY=1,1
 for _,t in ipairs(course.tiles) do maxX=math.max(maxX,t.x+1);maxY=math.max(maxY,t.y+1) end
 local scale=math.min(350/maxX,111/maxY)
 local ox,oy=(400-maxX*scale)/2,67
 for _,t in ipairs(course.tiles) do g.drawRect(ox+t.x*scale,oy+t.y*scale,scale,scale) end
 local function pin(p,label)
  if not p then return end
  local px,py=ox+p[1]/32*scale,oy+p[2]/32*scale
  g.setColor(g.kColorWhite);g.fillRect(px-6,py-9,14,18);g.setColor(g.kColorBlack);g.drawText(label,px-5,py-8)
 end
 pin(course.start,'S');pin(course.checkpoint,'C');pin(course.goal,'F')
 g.fillCircleAtPoint(ox+x/32*scale,oy+y/32*scale,3)
 g.drawText('Dot = you. Map axes match the D-pad.',12,185)
 g.drawText('A / B: return to game',12,214)
end
