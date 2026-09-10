import "CoreLibs/graphics"
import "physics"
import "courses"
import "mechanisms"
import "spatial"
import "physics_tests"
import "ui"
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
local choosing=false
local selected=1
local lesson=true
local completed={}
local jumpEnabled=false
local worldTime=0
local ballImage=g.image.new(28,28,g.kColorClear)
local ballMask=g.image.new(28,28,g.kColorWhite)
local function reset(full)
 if full then elapsed=0;falls=0;checkpoint=false end
 worldTime=0
 local point=checkpoint and course.checkpoint or course.start
 x,y=point[1],point[2];vx,vy,throttle=0,0,0
 state='play';fallTime=0;braking=false;ballHeight=course:height(x,y);controls=Physics.newControls();airborne=false;jumpZ=ballHeight;jumpV=0;rollAngle=0
end
local function selectLevel(n) level=n;selected=n;course=Courses[level];jumpEnabled=course.jump;overview=false;choosing=false;lesson=(n==1 or n==5 or course.lesson~=nil);reset(true) end
reset(true)
local camX,camY=0,0
local function project(a,b,h) return 200+(a-b)*0.9-camX,124+(a+b)*0.45-(h or 0)*0.65-camY end
local function support(a,b) return Mechanisms.support(course,a,b,worldTime) end
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
 if p < -70 or p>440 or q<50 or q>210 then return end
 local text=label=='SAVE' and 'CHECK' or label=='SAVED' and 'SAVED' or label=='GOAL' and 'FINISH' or 'START'
 local tx=math.max(5,math.min(321,p+20));local ty=q-45
 g.setColor(g.kColorBlack);g.drawEllipseInRect(p-11,q-5,22,10)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(p,q,3);g.setColor(g.kColorBlack);g.drawCircleAtPoint(p,q,3)
 -- Raised sign with a leader to the exact pad, never text on the road surface.
 g.drawLine(p,q,tx,ty+21)
 g.setColor(g.kColorWhite);g.fillRoundRect(tx,ty,72,23,3)
 g.setColor(g.kColorBlack);g.drawRoundRect(tx,ty,72,23,3);g.drawText(text,tx+5,ty+3)
 if label=='GOAL' then
  g.drawLine(p-15,q,p-15,q-23)
  for i=0,2 do for j=0,1 do if (i+j)%2==0 then g.fillRect(p-15+i*4,q-23+j*4,4,4) end end end
 end
end
local last=pd.getCurrentTimeMilliseconds()
function pd.update()
 local now=pd.getCurrentTimeMilliseconds();local dt=math.min((now-last)/1000,0.05);last=now
 if choosing then
  if pd.buttonJustPressed(pd.kButtonLeft) then selected=math.max(1,selected-1) end
  if pd.buttonJustPressed(pd.kButtonRight) then selected=math.min(#Courses,selected+1) end
  if pd.buttonJustPressed(pd.kButtonUp) then selected=math.max(1,selected-2) end
  if pd.buttonJustPressed(pd.kButtonDown) then selected=math.min(#Courses,selected+2) end
  if pd.buttonJustPressed(pd.kButtonA) then selectLevel(selected)
  elseif pd.buttonJustPressed(pd.kButtonB) then choosing=false end
  pd.getCrankChange();UI.selector(selected,completed);return
 end
 if lesson then
  if pd.buttonJustPressed(pd.kButtonA) then lesson=false
  elseif pd.buttonJustPressed(pd.kButtonB) then choosing=true end
  pd.getCrankChange();UI.lesson(jumpEnabled,course.lesson);return
 end
 if overview then
  if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then overview=false end
  pd.getCrankChange();UI.map(course,x,y,worldTime);return
 end
 if pd.buttonJustPressed(pd.kButtonA) then
  if state=='win' then
   if level==#Courses then choosing=true;selected=level else selectLevel(level+1) end
   return
  elseif jumpEnabled and state=='play' and not airborne and controls.charge>=0.05 then
   local _,riding=support(x,y)
   if riding and (riding.kind=='ferry' or riding.kind=='rotor') then
    local ax,ay=Mechanisms.carry(riding,x,y,worldTime,worldTime+1/120)
    vx,vy=vx+(ax-x)*120,vy+(ay-y)*120
   end
   airborne=true;jumpZ=ballHeight;jumpV=Physics.launch(controls.charge);controls.charge=0
  end
 end
 if pd.buttonJustPressed(pd.kButtonB) then reset(state=='win') end local crank=pd.getCrankChange()
 if state=='play' and not overview then
  elapsed=elapsed+dt
  -- Control meters are updated after reading direction.
  local dx,dy=0,0
  if pd.buttonIsPressed(pd.kButtonRight) then dx=dx+1 end
  if pd.buttonIsPressed(pd.kButtonLeft) then dx=dx-1 end
  if pd.buttonIsPressed(pd.kButtonDown) then dy=dy+1 end
  if pd.buttonIsPressed(pd.kButtonUp) then dy=dy-1 end
  dx,dy=Physics.controls(controls,jumpEnabled and crank or math.max(0,crank),dx,dy,dt);throttle=controls.power
  if not jumpEnabled then controls.charge=0 end
  braking=false
  local steps=math.max(4,math.ceil(math.sqrt(vx*vx+vy*vy)*dt/3))
  for _=1,steps do
   local step=dt/steps
   local oldX,oldY=x,y
   local beforeTime=worldTime
   local _,riding=support(x,y)
   worldTime=worldTime+step
   if not airborne and riding and (riding.kind=="ferry" or riding.kind=="rotor") then
    x,y=Mechanisms.carry(riding,x,y,beforeTime,worldTime)
   end
   if airborne then
    local oldZ=jumpZ
    jumpZ,jumpV=Physics.air(jumpZ,jumpV,step)
    x,y=x+vx*step,y+vy*step
    x,y,vx,vy=Mechanisms.collide(course,x,y,vx,vy,jumpZ-course:height(x,y),worldTime,step)
    x,y,vx,vy=Spatial.sides(course,x,y,vx,vy,jumpZ,worldTime)
    local floor=course:height(x,y)
    if support(x,y) and jumpZ<=floor and oldZ>=floor and jumpV<0 then
     airborne=false;ballHeight=floor;jumpZ=floor;jumpV=0
    elseif jumpZ < -140 then state='fall';falls=falls+1;fallTime=0;break end
   else
    local _,sx,sy=course:height(x,y)
    local b;vx,vy,b=Physics.step(vx,vy,dx,dy,throttle,sx,sy,step);braking=braking or b
    x,y=x+vx*step,y+vy*step
    x,y,vx,vy=Mechanisms.collide(course,x,y,vx,vy,0,worldTime,step)
    if not support(x,y) then state='fall';falls=falls+1;fallTime=0;break end
    ballHeight=course:height(x,y);jumpZ=ballHeight
   end
   local travel=math.sqrt((x-oldX)^2+(y-oldY)^2)
   local sign=(vx-vy)<0 and -1 or 1
   rollAngle=(rollAngle+sign*travel/11)%(math.pi*2)
  end  if course.checkpoint and not airborne and state=='play' and math.abs(x-course.checkpoint[1])<14 and math.abs(y-course.checkpoint[2])<14 then checkpoint=true end
  if state=='play' and not airborne and math.abs(x-course.goal[1])<17 and math.abs(y-course.goal[2])<22 then state='win';completed[level]=true end
 elseif state=='fall' and not overview then fallTime=fallTime+dt;if fallTime>0.8 then reset(false) end end
 camX=(x-y)*0.9;camY=(x+y)*0.45-ballHeight*0.65
 g.clear(g.kColorWhite)
 for _,t in ipairs(course.tiles) do drawTile(t) end
 if state~='fall' and support(x,y) then
  local sx,sy=project(x,y,course:height(x,y))
  g.setColor(g.kColorBlack);g.fillEllipseInRect(sx-8,sy-2,16,4)
  if not airborne and controls.charge>0.05 then
   for i=0,3 do local yy=sy-2-i*(2-controls.charge);g.drawLine(sx-4,yy,sx+4,yy-1) end
  end
 end
 Mechanisms.draw(course,worldTime,project)
 marker(course.start,'START');marker(course.checkpoint,checkpoint and 'SAVED' or 'SAVE');marker(course.goal,'GOAL')
 -- Rolling shell and rotating hamster face follow distance travelled.
 local ground=course:height(x,y)
 local bx,shadowY=project(x,y,ground)
 local _,by=project(x,y,airborne and jumpZ or ballHeight)
 local squash=not airborne and controls.charge*4 or 0
 by=by-12+squash
 if state=='fall' then by=by+fallTime*fallTime*150 end
 local radius=state=='fall' and math.max(3,11-fallTime*8) or 11
 local screenX,screenY=bx,by
 g.pushContext(ballImage);g.clear(g.kColorClear);bx,by=14,14
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
 g.popContext()
 local left,top=screenX-14,screenY-14
 local boxes=Spatial.occluders(course,worldTime,project,left,top,28,28)
 local z=airborne and jumpZ or ballHeight
 z=z-squash/0.65-(state=='fall' and fallTime*fallTime*150/0.65 or 0)
 g.pushContext(ballMask);g.clear(g.kColorBlack);g.setColor(g.kColorWhite)
 for row=0,27 do
  local start=nil
  for col=0,28 do
   local visible=col<28 and ballImage:sample(col,row)~=g.kColorClear and Spatial.visible(boxes,x,y,z,col-14,row-14)
   if visible and not start then start=col end
   if not visible and start then g.fillRect(start,row,col-start,1);start=nil end
  end
 end
 g.popContext();ballImage:setMaskImage(ballMask);ballImage:draw(left,top)
 g.setColor(g.kColorWhite);g.fillRect(0,0,400,44);g.fillRect(0,204,400,36)
 g.setColor(g.kColorBlack);g.fillRect(0,0,400,21)
 g.setImageDrawMode(g.kDrawModeFillWhite)
 g.drawText(string.format('%02d  %s',level,course.shortName),7,2)
 g.drawText(string.format('%.1fs  /  %d falls',elapsed,falls),264,2)
 g.setImageDrawMode(g.kDrawModeCopy)
 g.drawText('POWER',7,25);g.drawRect(67,28,86,8);g.fillRect(68,29,math.floor(throttle*84),6)
 local latchX=68+84*Physics.tuning.latch;g.drawLine(latchX,24,latchX,38);g.fillTriangle(latchX-3,23,latchX+3,23,latchX,26)
 if jumpEnabled then
  g.drawText('JUMP',164,25);g.drawRect(211,28,66,8);g.fillRect(212,29,math.floor(controls.charge*64),6)
 else g.drawText('ROLLING LESSON',165,25) end
 g.drawText(string.format('%03d',math.floor(math.sqrt(vx*vx+vy*vy))),293,25);g.drawText('speed',341,25)
 g.drawLine(0,203,400,203)
 if jumpEnabled then
  g.drawText('Clockwise: POWER    B: retry',7,204)
  g.drawText('Counterclockwise: JUMP    A: jump',7,222)
 else
  g.drawText('Turn clockwise: POWER    B: retry',7,204)
  g.drawText('D-pad: steer    Menu: map / levels',7,222)
 end
 if controls.flash>0 then
  UI.panel(99,48,202,22);g.drawTextAligned('Turn again for POWER',200,51,kTextAlignment.center)
 end if state=='win' then
  g.setColor(g.kColorWhite);g.fillRoundRect(55,75,290,88,8);g.setColor(g.kColorBlack);g.drawRoundRect(55,75,290,88,8)
  g.drawTextAligned('COURSE CLEAR!',200,84,kTextAlignment.center)
  g.drawTextAligned(string.format('%.1f seconds / %d falls',elapsed,falls),200,108,kTextAlignment.center)
  g.drawTextAligned(level==#Courses and 'A: level select   B: retry' or 'A: next level   B: retry',200,137,kTextAlignment.center)
 end
end
pd.getSystemMenu():addMenuItem('Level select',function() choosing=true;selected=level end)
pd.getSystemMenu():addMenuItem('Map / pause',function() overview=not overview end)
pd.getSystemMenu():addMenuItem('Restart level',function() choosing=false;overview=false;reset(true) end)
