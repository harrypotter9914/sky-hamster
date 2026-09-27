-- The flight instrument strip is exactly 400x43; the playfield and controls keep
-- their original space. Raster frames, glyphs and meter steps are cached once.
HudPanel={}
local g=playdate.graphics
local title=g.font.new('fonts/Roobert-11-Bold')
local numbers=g.font.new('fonts/Roobert-11-Mono-Condensed')
local small=g.font.new('fonts/Roobert-9-Mono-Condensed')
local emblems={}
for _,name in ipairs({'flag','tilt','jump','speed','clock','falls'}) do
 emblems[name]=g.image.new('hud-'..name)
end
local function image(w,h,fn)
 local im=g.image.new(w,h,g.kColorClear)
 g.pushContext(im);g.setImageDrawMode(g.kDrawModeCopy);fn();g.popContext()
 return im
end
local function label(s,x,y,font,inverted)
 g.setFont(font or title)
 g.setImageDrawMode(inverted and g.kDrawModeFillWhite or g.kDrawModeCopy)
 g.drawText(s,x,y);g.setImageDrawMode(g.kDrawModeCopy)
end
local function emblem(name,x,y,inverted)
 g.setImageDrawMode(inverted and g.kDrawModeInverted or g.kDrawModeCopy)
 emblems[name]:draw(x,y);g.setImageDrawMode(g.kDrawModeCopy)
end
local function meters(count)
 local frames={}
 for step=0,count do
  frames[step]=image(count*5+3,10,function()
   g.setColor(g.kColorWhite);g.fillRect(0,0,count*5+3,10)
   g.setColor(g.kColorBlack);g.drawRoundRect(0,0,count*5+3,10,2)
   for i=1,count do
    local x=3+(i-1)*5
    if i<=step then g.fillRect(x,2,3,6)
    else g.drawLine(x,7,x+2,7) end
   end
  end)
 end
 return frames
end
local forceFrames=meters(15)
local jumpFrames=meters(9)
local base,baseCourse,baseLevel,baseJump,readout,lastTime,lastFalls,lastSpeed
local function fit(s,w)
 while #s>1 and g.getTextSize(s)>w do s=s:sub(1,-2) end
 return s
end
local function value(s,x,y,w)
 -- Fixed-width digits stay anchored even when 111 changes to 888.
 g.setFont(numbers)
 local width=g.getTextSize(s)
 g.setImageDrawMode(g.kDrawModeCopy);g.drawText(s,x+w-width,y)
end
local function count(n)
 if n<10000 then return tostring(n) end
 if n<1000000 then return string.format('%dk',math.floor(n/1000)) end
 if n<1000000000 then return string.format('%dM',math.floor(n/1000000)) end
 return '999M+'
end
function HudPanel.draw(course,level,jump,power,elapsed,falls,speed)
 if baseCourse~=course or baseLevel~=level or baseJump~=jump then
  baseCourse,baseLevel,baseJump=course,level,jump
  base=image(400,43,function()
   g.setColor(g.kColorWhite);g.fillRect(0,0,400,43)
   g.setColor(g.kColorBlack);g.fillRect(0,0,400,21)
   g.setColor(g.kColorWhite);g.drawRoundRect(1,1,237,19,3)
   g.fillRoundRect(241,1,82,19,3);g.fillRoundRect(326,1,73,19,3)
   emblem('flag',4,2,true)
   label(string.format('%02d',level),27,3,numbers,true)
   g.drawLine(48,5,48,15)
   g.setFont(title);label(fit(course.shortName,180),54,2,title,true)
   emblem('clock',242,2);emblem('falls',328,2)
   g.setColor(g.kColorBlack)
   g.drawLine(0,21,399,21);g.drawLine(0,40,399,40);g.drawLine(0,42,399,42)
   for _,x in ipairs({0,140,254,399}) do g.drawLine(x,23,x,38) end
   emblem('tilt',3,22);label('TILT',25,24,small)
   emblem('jump',144,22);label('JUMP',165,24,small)
   if not jump then label('LOCK',211,24,small) end
   emblem('speed',259,22);label('SPEED',282,24,small)
  end)
 end
 base:draw(0,0)
 local p=math.max(0,math.min(1,power))
 forceFrames[math.floor(p*15+.5)]:draw(60,25)
 if jump then
  local ready=math.max(0,math.min(1,1-(Tilt.cooldown or 0)/.75))
  jumpFrames[math.floor(ready*9+.5)]:draw(202,25)
 end
 -- Preserve the small projected tilt-direction indicator inside the dial.
 local dx,dy=Tilt.dx or 0,Tilt.dy or 0
 local sx,sy=(dx-dy)*.9,(dx+dy)*.45
 local length=math.sqrt(sx*sx+sy*sy)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(12,31,5)
 g.setColor(g.kColorBlack)
 if length>0 then g.fillCircleAtPoint(12+sx/length*p*4,31+sy/length*p*4,1)
 else g.fillCircleAtPoint(12,31,1) end
 local t=math.max(0,math.floor(elapsed));local f=math.max(0,math.floor(falls));local v=math.max(0,math.floor(speed))
 if lastTime~=t or lastFalls~=f or lastSpeed~=v then
  lastTime,lastFalls,lastSpeed=t,f,v
  readout=readout or g.image.new(140,39,g.kColorClear)
  g.pushContext(readout);g.clear(g.kColorClear)
  local timer=string.format('%02d:%02d',math.floor(t/60),t%60)
  if t>=36000 then timer=string.format('%dh%02d',math.floor(t/3600),math.floor(t/60)%60) end
  if t>=3600000 then timer=string.format('%dd%02dh',math.min(999,math.floor(t/86400)),math.floor(t/3600)%24) end
  value(timer,1,3,56);value(count(f),89,3,46)
  value(v<10000 and string.format('%03d',v) or count(v),69,23,66)
  g.popContext()
 end
 readout:draw(262,0)
 g.setFont(UI.bodyFont);g.setImageDrawMode(g.kDrawModeCopy);g.setColor(g.kColorBlack)
end
