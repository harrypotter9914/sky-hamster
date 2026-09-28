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
   if p~=D.blocked and (x-p.x)^2+(y-p.y)^2<17^2 and vx*vx+vy*vy<35^2
    and (not p.onboard or Mechanisms.contains(p.target,x,y,0)) then
    if p.target and p.target.kind=='rotor' then p.angle=p.target.angle or p.angle end
    D.active=p;break
   end
  end
 end
 local p=D.active;if not p then return nil end
 if b then D.active=nil;D.blocked=p;return {x=p.x,y=p.y,exit=true} end
 p.angle=(p.angle or 0)+math.rad(crank)
 if p.kind=='cannon' then p.angle=math.max(-math.pi/3,math.min(math.pi/3,p.angle))
 elseif p.target then p.target.angle=p.angle end
 if a and p.kind=='cannon' then
  D.active=nil;D.blocked=p
  local mx,my=CannonModel.muzzle(p.angle)
  return {x=p.x+mx,y=p.y+my,z=course:height(p.x,p.y)+CannonModel.bottom,vz=CannonModel.vertical,vx=210*math.cos(p.angle),vy=210*math.sin(p.angle),launch=true}
 end
 return {x=p.x,y=p.y,locked=true}
end
-- Barrel art, trajectory and projectile spawn share one three-dimensional muzzle.
local cannonArt={}
local cannonBase
function D.projectedDirection(angle) return CannonModel.direction(angle) end
function D.cannonFrame(angle)
 return math.max(1,math.min(61,math.floor((angle+math.pi/3)/(math.pi/90)+1.5)))
end
local function buildCannons()
 if cannonArt[1] then return end
 cannonBase=CannonModel.base()
 for n=1,61 do cannonArt[n]=CannonModel.raster(-math.pi/3+(n-1)*math.pi/90) end
end
D.prepareArt=buildCannons
function D.muzzle(course,p)
 local mx,my,mz=CannonModel.muzzle(p.angle or 0)
 return p.x+mx,p.y+my,course:height(p.x,p.y)+mz
end
function D.trajectory(course,p,t)
 local mx,my,mz=D.muzzle(course,p);local a=p.angle or 0
 return mx+210*math.cos(a)*t,my+210*math.sin(a)*t,mz+CannonModel.vertical*t-150*t*t
end
function D.drawCannon(angle,x,y,recoil,p,floor)
 buildCannons()
 cannonBase:draw(x-64,y-78)
 local ux,uy=D.projectedDirection(angle)
 local frame=D.cannonFrame(angle)
 local im=cannonArt[frame]
 local sx,sy=x-64-(recoil or 0)*ux,y-78-(recoil or 0)*uy
 im:draw(sx,sy)
 if p then
  PropOcclusion.add(cannonBase,x-64,y-78,p.x,p.y,50,50,0,floor,floor+12,true)
  local a=-math.pi/3+(frame-1)*math.pi/90
  local along=(CannonModel.forward-10)/2-(recoil or 0)
  PropOcclusion.add(im,sx,sy,p.x+math.cos(a)*along,p.y+math.sin(a)*along,CannonModel.forward+32,34,a,floor,floor+65,true)
 end
end
function D.draw(course,project,drawTile)
 local g=playdate.graphics
 for _,p in ipairs(course.pads or {}) do
  local roughX,roughY=project(p.x,p.y,course:height(p.x,p.y))
  -- A remote dial needs no support query. Margin includes the tallest lift.
  if roughX>-80 and roughX<480 and roughY>-140 and roughY<410 then
  local x,y=project(p.x,p.y,Mechanisms.floor(course,p.x,p.y,0))
  if x>-50 and x<450 and y>35 and y<225 then
   if p.kind=='cannon' then
    local age=p.fireAt and MachineArt.time-p.fireAt or 10
    local recoil=age>=0 and age<.24 and math.sin(age/.24*math.pi)*5 or 0
    D.drawCannon(p.angle or 0,x,y,recoil,p,course:height(p.x,p.y))
    if D.active==p then
     local px,py=project(D.trajectory(course,p,0))
     g.setColor(g.kColorBlack)
     for i=1,18 do
      local qx,qy=project(D.trajectory(course,p,i*.05))
      if i==1 then g.drawLine(px,py,qx,qy) else g.fillCircleAtPoint(qx,qy,i%2==0 and 1.5 or 1) end
      px,py=qx,qy
     end
    end
    if DepthOrder then DepthOrder.roads(course,p,0,project,drawTile) end
   elseif p.kind=='bridge' or p.kind=='fan' or p.kind=='extend' or p.kind=='switch' then
    Structures.dial(x,y,p.spin or math.deg(p.angle or 0))
    if p.onboard then
     MachineArt.solidSprite('switch',x,y,p.x,p.y,course:height(p.x,p.y),16,16,25)
     MachineArt.handle(x,y-18,p.spin or 0)
    end
   end
  end
  end
 end
end
-- Station labels, like checkpoint labels, are foreground UI rather than solids.
function D.drawLabels(course,project)
 local g=playdate.graphics
 for _,p in ipairs(course.pads or {}) do
  local rx,ry=project(p.x,p.y,course:height(p.x,p.y))
  if rx>-80 and rx<480 and ry>-140 and ry<410 then
   local x,y=project(p.x,p.y,Mechanisms.floor(course,p.x,p.y,0))
   if x>-50 and x<450 and y>35 and y<225 and UI and UI.worldSign then
    local tx=math.max(4,math.min(319,x>275 and x-114 or x+48));local ty=math.max(48,math.min(176,y-29))
    -- The wind dial is beside a tall fan; keep its road sign above the housing.
    if p.kind=='fan' then ty=math.max(48,ty-47) end
    UI.worldSign(({cannon='CANNON',lift='LIFT',slider='FERRY',fan='WIND',extend='EXTEND',switch='ROUTE'})[p.kind] or 'CRANK',tx,ty,x+18,y-12)
   end
  end
 end
end
local pose=Mechanisms.pose
function Mechanisms.pose(m,t) if m.manual then return m.x,m.y,m.angle or 0 end return pose(m,t) end
