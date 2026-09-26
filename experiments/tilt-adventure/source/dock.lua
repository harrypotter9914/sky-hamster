Dock={active=nil,blocked=nil}
local D=Dock
function D.reset(course)
 D.active=nil;D.blocked=nil
 if D.prepareArt and #(course.pads or {})>0 then D.prepareArt() end
 for _,p in ipairs(course.pads or {}) do p.angle=p.initialAngle or 0;if p.target then p.target.angle=p.angle end end
end
function D.update(course,x,y,vx,vy,airborne,crank,a,b)
 local blocked=D.blocked
 if blocked and (x-blocked.x)^2+(y-blocked.y)^2>32^2 then D.blocked=nil end
 if not D.active and not airborne then
  for _,p in ipairs(course.pads or {}) do
   if p~=D.blocked and (x-p.x)^2+(y-p.y)^2<17^2 and vx*vx+vy*vy<35^2 then D.active=p;break end
  end
 end
 local p=D.active;if not p then return nil end
 if b then D.active=nil;D.blocked=p;return {x=p.x,y=p.y,exit=true} end
 p.angle=(p.angle or 0)+math.rad(crank)
 if p.kind=='cannon' then p.angle=math.max(-math.pi/3,math.min(math.pi/3,p.angle))
 elseif p.target then p.target.angle=p.angle end
 if a and p.kind=='cannon' then
  D.active=nil;D.blocked=p
  return {x=p.x,y=p.y,vx=210*math.cos(p.angle),vy=210*math.sin(p.angle),launch=true}
 end
 return {x=p.x,y=p.y,locked=true}
end
-- Seventeen small prebuilt barrel orientations; no per-frame image allocation.
local cannonArt={}
local function buildCannons()
 if cannonArt[1] then return end
 local g=playdate.graphics;local barrel=g.image.new('cannon-barrel')
 for n=1,17 do
  local angle=-math.pi/3+(n-1)*math.pi/24
  local dx,dy=math.cos(angle),math.sin(angle)
  local bearing=math.deg(math.atan((dx+dy)*.45-.75,(dx-dy)*.9))
  local im=g.image.new(104,104,g.kColorClear);g.pushContext(im)
  -- A solid saddle with an exposed top, front and shaded side.
  g.setColor(g.kColorWhite);g.fillPolygon(23,76,50,68,80,78,52,87);g.setColor(g.kColorBlack);g.drawPolygon(23,76,50,68,80,78,52,87)
  g.setColor(g.kColorWhite);g.fillPolygon(23,76,52,87,52,98,23,87);g.setColor(g.kColorBlack);g.drawPolygon(23,76,52,87,52,98,23,87)
  g.fillPolygon(52,87,80,78,80,89,52,98);g.setColor(g.kColorWhite);g.drawLine(56,88,76,81)
  barrel:drawRotated(51,49,bearing)
  g.popContext();cannonArt[n]=im
 end
end
D.prepareArt=buildCannons
function D.drawCannon(angle,x,y)
 buildCannons();local n=math.max(1,math.min(17,math.floor((angle+math.pi/3)/(math.pi/24)+1.5)))
 cannonArt[n]:draw(x-51,y-96)
end
function D.draw(course,project)
 local g=playdate.graphics
 for _,p in ipairs(course.pads or {}) do
  local x,y=project(p.x,p.y,course:height(p.x,p.y))
  if x>-50 and x<450 and y>35 and y<225 then
   if p.kind=='cannon' then
    buildCannons();local n=math.max(1,math.min(17,math.floor(((p.angle or 0)+math.pi/3)/(math.pi/24)+1.5)))
    cannonArt[n]:draw(x-51,y-96)
    if D.active==p then for i=1,10 do local t=i*.1;local px,py=project(p.x+math.cos(p.angle)*210*t,p.y+math.sin(p.angle)*210*t,course:height(p.x,p.y)+150*t-150*t*t);g.setColor(g.kColorBlack);g.fillCircleAtPoint(px,py,2) end end
   else
    g.setColor(g.kColorBlack);g.fillEllipseInRect(x-23,y-8,46,21)
    g.setColor(g.kColorWhite);g.fillEllipseInRect(x-22,y-10,44,18);g.setColor(g.kColorBlack);g.drawEllipseInRect(x-22,y-10,44,18);g.drawEllipseInRect(x-15,y-7,30,12)
    for i=0,7 do local a=i*math.pi/4;local px,py=x+math.cos(a)*18,y-1+math.sin(a)*7;g.fillRect(px-1,py-1,2,2) end
    local a=p.angle or 0;g.drawLine(x,y-1,x+math.cos(a)*12,y-1+math.sin(a)*5);g.fillCircleAtPoint(x,y-1,3)
   end
   if UI and UI.worldSign then
    local tx=math.max(4,math.min(319,x>275 and x-114 or x+48));local ty=math.max(48,math.min(176,y-29))
    g.setColor(g.kColorBlack);g.drawLine(x+18,y-12,tx,ty+11)
    UI.worldSign(p.kind=='cannon' and 'CANNON' or 'CRANK',tx,ty)
   end
  end
 end
end
local pose=Mechanisms.pose
function Mechanisms.pose(m,t) if m.manual then return m.x,m.y,m.angle or 0 end return pose(m,t) end
