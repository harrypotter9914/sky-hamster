import "CoreLibs/graphics"
import "physics"
import "courses"
import "physics_tests"
local pd,g=playdate,playdate.graphics
pd.display.setRefreshRate(30)
local level=1
local course=Courses[level]
local x,y,vx,vy,throttle,elapsed,falls,state,fallTime,braking,ballHeight
local controls=Physics.newControls()
local airborne=false
local jumpZ,jumpV=0,0
local rollAngle=0
local checkpoint=false
local overview=false
local function reset(full)
 if full then elapsed=0;falls=0;checkpoint=false end
 local point=checkpoint and course.checkpoint or course.start
 x,y=point[1],point[2];vx,vy,throttle=0,0,0
 state='play';fallTime=0;braking=false;ballHeight=course:height(x,y);controls=Physics.newControls();airborne=false;jumpZ=ballHeight;jumpV=0;rollAngle=0
end
local function selectLevel(n) level=n;course=Courses[level];overview=false;reset(true) end
reset(true)
local camX,camY=0,0
local function project(a,b,h) return 200+(a-b)*0.9-camX,124+(a+b)*0.45-(h or 0)*0.65-camY end
local function support(a,b) return course.lookup[math.floor(a/32)..','..math.floor(b/32)] end
local function drawTile(t)
 local a,b=t.x*32,t.y*32
 local p,q=project(a,b,course:height(a,b));local r,s=project(a+32,b,course:height(a+32,b))
 local u,v=project(a+32,b+32,course:height(a+32,b+32));local w,z=project(a,b+32,course:height(a,b+32))
 if math.max(p,r,u,w)<0 or math.min(p,r,u,w)>400 or math.max(q,s,v,z)<42 or math.min(q,s,v,z)>212 then return end
 g.setColor(g.kColorBlack)
 g.fillPolygon(r,s,u,v,u,v+12,r,s+12);g.fillPolygon(w,z,u,v,u,v+12,w,z+12)
 g.setColor(g.kColorWhite);g.fillPolygon(p,q,r,s,u,v,w,z)
 g.setColor(g.kColorBlack);g.drawPolygon(p,q,r,s,u,v,w,z)
 local _,sx=course:height(a+16,b+16)
 local cx,cy=project(a+16,b+16,course:height(a+16,b+16))
 if math.abs(sx)>0.01 then
  -- Arrow points DOWN the slope, independent of the travel direction.
  local sign=sx<0 and 1 or -1
  local tipX,tipY=project(a+16+sign*8,b+16,course:height(a+16+sign*8,b+16))
  g.drawLine(cx,cy,tipX,tipY);g.drawLine(tipX,tipY,tipX-sign*5,tipY-3);g.drawLine(tipX,tipY,tipX-sign*5,tipY+2)
 else g.fillCircleAtPoint(cx,cy,1) end
end
local function marker(point,label)
 if not point then return end
 local p,q=project(point[1],point[2],course:height(point[1],point[2]))
 g.setColor(g.kColorBlack);g.drawEllipseInRect(p-12,q-6,24,12);g.drawText(label,p-14,q+10)
end
local last=pd.getCurrentTimeMilliseconds()
function pd.update()
 local now=pd.getCurrentTimeMilliseconds();local dt=math.min((now-last)/1000,0.05);last=now
 if pd.buttonJustPressed(pd.kButtonA) then
  if state=='win' then selectLevel(level%#Courses+1)
  elseif not overview and state=='play' and not airborne and controls.charge>=0.05 then
   airborne=true;jumpZ=ballHeight;jumpV=Physics.launch(controls.charge);controls.charge=0
  end
 end
 if pd.buttonJustPressed(pd.kButtonB) then overview=false;reset(state=='win') end
 local crank=pd.getCrankChange()
 if state=='play' and not overview then
  elapsed=elapsed+dt
  -- Control meters are updated after reading direction.
  local dx,dy=0,0
  if pd.buttonIsPressed(pd.kButtonRight) then dx=dx+1 end
  if pd.buttonIsPressed(pd.kButtonLeft) then dx=dx-1 end
  if pd.buttonIsPressed(pd.kButtonDown) then dy=dy+1 end
  if pd.buttonIsPressed(pd.kButtonUp) then dy=dy-1 end
  dx,dy=Physics.controls(controls,crank,dx,dy,dt);throttle=controls.power
  braking=false
  local steps=math.max(4,math.ceil(math.sqrt(vx*vx+vy*vy)*dt/3))
  for _=1,steps do
   local step=dt/steps
   local oldX,oldY=x,y
   if airborne then
    local oldZ=jumpZ
    jumpZ,jumpV=Physics.air(jumpZ,jumpV,step)
    x,y=x+vx*step,y+vy*step
    local floor=course:height(x,y)
    if support(x,y) and jumpZ<=floor and oldZ>=floor and jumpV<0 then
     airborne=false;ballHeight=floor;jumpZ=floor;jumpV=0
    elseif support(x,y) and jumpZ<floor-1 then
     state='fall';falls=falls+1;fallTime=0;break
    elseif jumpZ < -140 then state='fall';falls=falls+1;fallTime=0;break end
   else
    local _,sx,sy=course:height(x,y)
    local b;vx,vy,b=Physics.step(vx,vy,dx,dy,throttle,sx,sy,step);braking=braking or b
    x,y=x+vx*step,y+vy*step
    if not support(x,y) then state='fall';falls=falls+1;fallTime=0;break end
    ballHeight=course:height(x,y);jumpZ=ballHeight
   end
   local travel=math.sqrt((x-oldX)^2+(y-oldY)^2)
   local sign=(vx-vy)<0 and -1 or 1
   rollAngle=(rollAngle+sign*travel/11)%(math.pi*2)
  end  if course.checkpoint and not airborne and state=='play' and math.abs(x-course.checkpoint[1])<14 and math.abs(y-course.checkpoint[2])<14 then checkpoint=true end
  if state=='play' and not airborne and math.abs(x-course.goal[1])<17 and math.abs(y-course.goal[2])<22 then state='win' end
 elseif state=='fall' and not overview then fallTime=fallTime+dt;if fallTime>0.8 then reset(false) end end
 camX=(x-y)*0.9;camY=(x+y)*0.45-ballHeight*0.65
 g.clear(g.kColorWhite)
 for _,t in ipairs(course.tiles) do drawTile(t) end
 marker(course.start,'START');marker(course.checkpoint,checkpoint and 'SAVED' or 'SAVE');marker(course.goal,'GOAL')
 -- Rolling shell and rotating hamster face follow distance travelled.
 local ground=course:height(x,y)
 local bx,shadowY=project(x,y,ground)
 local _,by=project(x,y,airborne and jumpZ or ballHeight)
 if state~='fall' and support(x,y) then g.setColor(g.kColorBlack);g.fillEllipseInRect(bx-8,shadowY-2,16,4) end
 local squash=not airborne and controls.charge*4 or 0
 by=by-12+squash
 if state=='fall' then by=by+fallTime*fallTime*150 end
 local radius=state=='fall' and math.max(3,11-fallTime*8) or 11
 if not airborne and controls.charge>0.05 then
  g.setColor(g.kColorBlack)
  for i=0,3 do local yy=shadowY-2-i*(2-controls.charge);g.drawLine(bx-4,yy,bx+4,yy-1) end
 end
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(bx,by,radius)
 g.setColor(g.kColorBlack);g.drawCircleAtPoint(bx,by,radius)
 local function rot(a,b) return bx+a*math.cos(rollAngle)-b*math.sin(rollAngle),by+a*math.sin(rollAngle)+b*math.cos(rollAngle) end
 if radius>7 then
  local ex,ey=rot(-4,-4);g.fillCircleAtPoint(ex,ey,3)
  ex,ey=rot(4,-4);g.fillCircleAtPoint(ex,ey,3)
  g.setColor(g.kColorWhite);g.fillCircleAtPoint(bx,by+1,6)
  g.setColor(g.kColorBlack);g.drawCircleAtPoint(bx,by+1,6)
  for _,p in ipairs({{-3,-1},{3,-1},{0,3}}) do ex,ey=rot(p[1],p[2]);g.fillCircleAtPoint(ex,ey,1) end
  ex,ey=rot(8,0);local fx,fy=rot(-8,0);g.drawLine(ex,ey,fx,fy)
 end
 g.setColor(g.kColorWhite);g.fillRect(0,0,400,43);g.fillRect(0,212,400,28)
 g.setColor(g.kColorBlack);g.drawLine(0,42,400,42)
 g.drawText(course.name,6,2);g.drawText(string.format('%.1fs / %d falls',elapsed,falls),263,2)
 g.drawText('PWR',6,23);g.drawRect(40,26,84,7);g.fillRect(41,27,math.floor(throttle*82),5)
 local latchX=41+82*Physics.tuning.latch;g.drawLine(latchX,22,latchX,35)
 g.drawText('JUMP',136,23);g.drawRect(182,26,67,7);g.fillRect(183,27,math.floor(controls.charge*65),5)
 g.drawText(string.format('SPD %03d',math.floor(math.sqrt(vx*vx+vy*vy))),264,23)
 g.drawText('CW: push  CCW: charge  A: jump  B: retry',4,218)
 if controls.flash>0 then g.drawTextAligned('RE-CRANK TO PUSH',200,48,kTextAlignment.center) end
 if overview then
  g.setColor(g.kColorWhite);g.fillRect(10,48,380,158);g.setColor(g.kColorBlack);g.drawRect(10,48,380,158)
  g.drawText(course.hint,16,52)
  for _,t in ipairs(course.tiles) do g.drawRect(30+t.x*16,83+t.y*12,16,12) end
  g.fillCircleAtPoint(30+x/2,83+y*0.375,3)
  g.drawText('UP = upper-right. RIGHT = lower-right.',16,180)
 end
 if state=='win' then
  g.setColor(g.kColorWhite);g.fillRoundRect(55,75,290,88,8);g.setColor(g.kColorBlack);g.drawRoundRect(55,75,290,88,8)
  g.drawTextAligned('COURSE CLEAR!',200,84,kTextAlignment.center)
  g.drawTextAligned(string.format('%.1f seconds / %d falls',elapsed,falls),200,108,kTextAlignment.center)
  g.drawTextAligned('A: next course   B: retry',200,137,kTextAlignment.center)
 end
end
pd.getSystemMenu():addOptionsMenuItem('Course',{'1 Corners','2 Downhill','3 Valley','4 Brake bend','5 First hop','6 Precision'},'1 Corners',function(value) selectLevel(tonumber(string.sub(value,1,1))) end)
pd.getSystemMenu():addMenuItem('Map / pause',function() overview=not overview end)
pd.getSystemMenu():addMenuItem('Restart course',function() reset(true) end)
