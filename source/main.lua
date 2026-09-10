import "CoreLibs/graphics"
local pd, g = playdate, playdate.graphics
pd.display.setRefreshRate(30)
-- World axes: right = down-right; up = up-right. Crank sets a speed,
-- not acceleration. Reverse steering brakes before reversing velocity.
local T = {maxSpeed=85, crankPerDegree=0.045, acceleration=42, brake=115, coast=9}
local tiles, lookup = {}, {}
local function tile(x,y)
 local key=x..","..y
 if not lookup[key] then lookup[key]=true; tiles[#tiles+1]={x=x,y=y} end
end
for x=0,3 do for y=0,2 do tile(x,y) end end
for x=4,8 do tile(x,1) end
for y=2,5 do tile(8,y) end
for x=9,12 do tile(x,5) end
for y=2,4 do tile(12,y) end
for x=13,16 do for y=1,3 do tile(x,y) end end
 table.sort(tiles,function(a,b) return a.x+a.y < b.x+b.y end)
local size=32
local x,y,vx,vy,target,elapsed,falls,state,fallTime,braking
local checkpoint=false
local function reset(full)
 if full then elapsed=0;falls=0;checkpoint=false end
 x,y= checkpoint and 272 or 48, checkpoint and 176 or 48
 vx,vy,target=0,0,0;state="play";fallTime=0;braking=false
end
reset(true)
local camX,camY=0,0
local function project(a,b) return 200+(a-b)*0.9-camX,126+(a+b)*0.45-camY end
local function support(a,b) return lookup[math.floor(a/size)..","..math.floor(b/size)] end
local function approach(a,b,d) if a<b then return math.min(a+d,b) else return math.max(a-d,b) end end
local function drawTile(t)
 local a,b=t.x*size,t.y*size
 local p,q=project(a,b);local r,s=project(a+size,b);local u,v=project(a+size,b+size);local w,z=project(a,b+size)
 g.setColor(g.kColorBlack)
 g.fillPolygon(r,s,u,v,u,v+12,r,s+12)
 g.fillPolygon(w,z,u,v,u,v+12,w,z+12)
 g.setColor(g.kColorWhite);g.fillPolygon(p,q,r,s,u,v,w,z)
 g.setColor(g.kColorBlack);g.drawPolygon(p,q,r,s,u,v,w,z)
 -- Small corner marks keep the track legible without noisy checkerboards.
 g.fillCircleAtPoint((p+u)/2,(q+v)/2,1)
end
local function marker(a,b,label)
 local p,q=project(a,b);g.setColor(g.kColorBlack);g.drawEllipseInRect(p-12,q-6,24,12);g.drawText(label,p-12,q+12)
end
local last=pd.getCurrentTimeMilliseconds()
function pd.update()
 local now=pd.getCurrentTimeMilliseconds();local dt=math.min((now-last)/1000,0.05);last=now
 if pd.buttonJustPressed(pd.kButtonB) then reset(state=="win") end
 if state=="play" then
  elapsed=elapsed+dt
  target=math.max(0,math.min(T.maxSpeed,target+pd.getCrankChange()*T.crankPerDegree))
  local dx,dy=0,0
  if pd.buttonIsPressed(pd.kButtonRight) then dx=dx+1 end
  if pd.buttonIsPressed(pd.kButtonLeft) then dx=dx-1 end
  if pd.buttonIsPressed(pd.kButtonDown) then dy=dy+1 end
  if pd.buttonIsPressed(pd.kButtonUp) then dy=dy-1 end
  local len=math.sqrt(dx*dx+dy*dy);local speed=math.sqrt(vx*vx+vy*vy)
  braking=false
  if len>0 then
   dx,dy=dx/len,dy/len
   braking=(vx*dx+vy*dy < -3) or speed>target+3
   local ax,ay=dx*target-vx,dy*target-vy
   local diff=math.sqrt(ax*ax+ay*ay)
   if diff>0 then local step=math.min(diff,(braking and T.brake or T.acceleration)*dt);vx=vx+ax/diff*step;vy=vy+ay/diff*step end
  elseif speed>0 then
   braking=speed>target+3
   local nextSpeed=math.max(0,speed-(braking and T.brake or T.coast)*dt)
   vx,vy=vx*nextSpeed/speed,vy*nextSpeed/speed
  end
  -- Substeps prevent skipping a narrow platform at low frame rates.
  for i=1,3 do
   x,y=x+vx*dt/3,y+vy*dt/3
   if not support(x,y) then state="fall";falls=falls+1;fallTime=0;break end
  end
  if state=="play" and x>256 and x<288 and y>160 and y<192 then checkpoint=true end
  if state=="play" and x>480 and y>32 and y<96 then state="win" end
 elseif state=="fall" then
  fallTime=fallTime+dt
  if fallTime>0.8 then reset(false) end
 end
 camX=(x-y)*0.9;camY=(x+y)*0.45
 g.clear(g.kColorWhite)
 for _,t in ipairs(tiles) do drawTile(t) end
 marker(48,48,"START");marker(272,176,checkpoint and "SAVED" or "SAVE");marker(512,64,"GOAL")
 -- Procedural 1-bit hamster-ball: shell, ears, face, feet and moving seam.
 local bx,by=project(x,y);local drop=state=="fall" and fallTime*fallTime*150 or 0
 local radius=state=="fall" and math.max(3,11-fallTime*8) or 11
 if state~="fall" then g.setColor(g.kColorBlack);g.fillEllipseInRect(bx-9,by-3,18,6) end
 by=by-12+drop
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(bx,by,radius)
 g.setColor(g.kColorBlack);g.drawCircleAtPoint(bx,by,radius)
 if radius>7 then
  g.fillCircleAtPoint(bx-4,by-4,3);g.fillCircleAtPoint(bx+4,by-4,3)
  g.setColor(g.kColorWhite);g.fillEllipseInRect(bx-6,by-5,12,13)
  g.setColor(g.kColorBlack);g.drawEllipseInRect(bx-6,by-5,12,13)
  g.fillRect(bx-3,by-1,1,2);g.fillRect(bx+3,by-1,1,2);g.drawLine(bx-1,by+3,bx+1,by+3)
  local roll=math.sin((x+y)/8)*7;g.drawLine(bx-7,by+roll,bx-5,by+roll+2)
 end
 g.setColor(g.kColorWhite);g.fillRect(0,0,400,43);g.fillRect(0,213,400,27)
 g.setColor(g.kColorBlack);g.drawLine(0,42,400,42)
 g.drawText("SKY HAMSTER",8,3)
 g.drawText(string.format("%05.1fs  Falls %d",elapsed,falls),229,3)
 g.drawText("SET",8,23);g.drawRect(43,26,86,7);g.fillRect(44,27,math.floor(target),5)
 g.drawText("NOW",145,23);g.drawRect(187,26,86,7);g.fillRect(188,27,math.min(84,math.floor(math.sqrt(vx*vx+vy*vy))),5)
 if braking then g.drawText("BRAKING",292,23) end
 g.drawText("D-pad: steer   Crank: speed   B: retry",8,218)
 if target<0.5 and state=="play" then
  g.setColor(g.kColorWhite);g.fillRoundRect(36,169,328,38,5);g.setColor(g.kColorBlack);g.drawRoundRect(36,169,328,38,5)
  g.drawText("Crank clockwise, then hold D-pad",43,174);g.drawText("UP = upper-right / RIGHT = lower-right",43,189)
 end
 if state=="win" then
  g.setColor(g.kColorWhite);g.fillRoundRect(58,76,284,78,8);g.setColor(g.kColorBlack);g.drawRoundRect(58,76,284,78,8)
  g.drawTextAligned("DELIVERY COMPLETE!",200,86,kTextAlignment.center)
  g.drawTextAligned(string.format("%.1f seconds / %d falls",elapsed,falls),200,110,kTextAlignment.center)
  g.drawTextAligned("B: race again",200,133,kTextAlignment.center)
 end
end
pd.getSystemMenu():addMenuItem("Restart course",function() reset(true) end)

