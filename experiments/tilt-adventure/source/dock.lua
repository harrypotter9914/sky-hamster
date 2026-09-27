Dock={active=nil,blocked=nil}
local D=Dock
function D.status()
 if D.active then return 'LOCKED' end
 if D.blocked then return 'UNLOCKED' end
end
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
local cannonBase
local function buildCannons()
 if cannonArt[1] then return end
 local g=playdate.graphics;local barrel=g.image.new('structures/barrel')
 cannonBase=g.image.new('structures/cradle')
 for n=1,17 do
  local angle=-math.pi/3+(n-1)*math.pi/24
  local dx,dy=math.cos(angle),math.sin(angle)
  local bearing=math.deg(math.atan((dx+dy)*.45-.75,(dx-dy)*.9))
  local im=g.image.new(104,104,g.kColorClear);g.pushContext(im)
  barrel:drawRotated(51,49,bearing)
  g.popContext();cannonArt[n]=im
 end
end
D.prepareArt=buildCannons
function D.drawCannon(angle,x,y)
 buildCannons();local n=math.max(1,math.min(17,math.floor((angle+math.pi/3)/(math.pi/24)+1.5)))
 cannonBase:draw(x-35,y-56)
 cannonArt[n]:draw(x-51,y-96)
end
function D.draw(course,project)
 local g=playdate.graphics
 for _,p in ipairs(course.pads or {}) do
  local roughX,roughY=project(p.x,p.y,course:height(p.x,p.y))
  -- A remote dial needs no support query. Margin includes the tallest lift.
  if roughX>-80 and roughX<480 and roughY>-140 and roughY<410 then
  local x,y=project(p.x,p.y,Mechanisms.floor(course,p.x,p.y,0))
  if x>-50 and x<450 and y>35 and y<225 then
   if p.kind=='cannon' then
    buildCannons();local n=math.max(1,math.min(17,math.floor(((p.angle or 0)+math.pi/3)/(math.pi/24)+1.5)))
    local age=p.fireAt and MachineArt.time-p.fireAt or 10
    local recoil=age>=0 and age<.24 and math.sin(age/.24*math.pi)*5 or 0
    local dx,dy=math.cos(p.angle or 0),math.sin(p.angle or 0)
    local ux,uy=(dx-dy)*.9,(dx+dy)*.45-.75;local length=math.sqrt(ux*ux+uy*uy)
    cannonBase:draw(x-35,y-56)
    cannonArt[n]:draw(x-51-recoil*ux/length,y-96-recoil*uy/length)
    if D.active==p then for i=1,10 do local t=i*.1;local px,py=project(p.x+math.cos(p.angle)*210*t,p.y+math.sin(p.angle)*210*t,course:height(p.x,p.y)+150*t-150*t*t);g.setColor(g.kColorBlack);g.fillCircleAtPoint(px,py,2) end end
   elseif p.kind=='bridge' or p.kind=='fan' or p.kind=='extend' or p.kind=='switch' then
    Structures.dial(x,y,p.spin or math.deg(p.angle or 0))
   end
   if UI and UI.worldSign then
    local tx=math.max(4,math.min(319,x>275 and x-114 or x+48));local ty=math.max(48,math.min(176,y-29))
    -- The wind dial is beside a tall fan; keep its road sign above the housing.
    if p.kind=='fan' then ty=math.max(48,ty-47) end
    g.setColor(g.kColorBlack);g.drawLine(x+18,y-12,tx,ty+11)
    UI.worldSign(({cannon='CANNON',lift='LIFT',slider='FERRY',fan='WIND',extend='EXTEND',switch='ROUTE'})[p.kind] or 'CRANK',tx,ty)
   end
  end
  end
 end
end
local pose=Mechanisms.pose
function Mechanisms.pose(m,t) if m.manual then return m.x,m.y,m.angle or 0 end return pose(m,t) end
