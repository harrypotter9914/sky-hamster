-- New machinery shares the existing collision/render paths where possible.
Expansion={}
local E=Expansion
local M,D=Mechanisms,Dock
local clamp=function(v,a,b)return math.max(a,math.min(b,v))end
local oldPose=M.pose
function M.pose(m,t)
 if m.kind=='lift' then return m.x,m.y,0 end
 if m.kind=='ferry' and m.manual then local u=m.progress or 0;return m.x+(m.toX-m.x)*u,m.y+(m.toY-m.y)*u,0 end
 return oldPose(m,t)
end
local oldSupport=M.support
function M.support(c,x,y,t)
 for _,m in ipairs(c.mechanisms or {}) do if m.kind=='lift' and M.contains(m,x,y,t) then return true,m end end
 return oldSupport(c,x,y,t)
end
function M.floor(c,x,y,t)
 local supported,m=M.support(c,x,y,t)
 if m and m.kind=='lift' then return m.elevation or m.minHeight end
 return c:height(x,y)
end
local oldReset=D.reset
function D.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='lift' then m.elevation=m.minHeight end
  if m.manual and m.kind=='ferry' then m.progress=0 end
  if m.kind=='fan' then m.angle=m.initialAngle or 0 end
 end
 for _,p in ipairs(c.pads or {}) do
  p.homeX,p.homeY=p.homeX or p.x,p.homeY or p.y;p.x,p.y=p.homeX,p.homeY
 end
 oldReset(c)
end
local oldUpdate=D.update
function D.update(c,x,y,vx,vy,airborne,crank,a,b)
 -- Acquisition and re-entry exclusion remain centralized in Dock.
 local result=oldUpdate(c,x,y,vx,vy,airborne,crank,a,b)
 local p=D.active
 if p and result and result.locked then
  if p.kind=='lift' then p.target.elevation=clamp((p.target.elevation or p.target.minHeight)+crank*.25,p.target.minHeight,p.target.maxHeight)
  elseif p.kind=='slider' then
   p.target.progress=clamp((p.target.progress or 0)+crank/540,0,1)
   p.x,p.y=M.pose(p.target,0);result.x,result.y=p.x,p.y
  elseif p.kind=='fan' then p.target.angle=p.angle end
 end
 return result
end
local oldCollide=M.collide
function M.collide(c,x,y,vx,vy,z,t,dt)
 local hit;x,y,vx,vy,hit=oldCollide(c,x,y,vx,vy,z,t,dt)
 for _,m in ipairs(c.mechanisms or {}) do if m.kind=='bumper' and z<28 then
  local dx,dy=x-m.x,y-m.y;local r=(m.radius or 18)+9;local d=math.sqrt(dx*dx+dy*dy)
  if d<r then
   local speed=math.sqrt(vx*vx+vy*vy)
   local nx,ny
   if d>.001 then nx,ny=dx/d,dy/d
   elseif speed>.001 then nx,ny=-vx/speed,-vy/speed
   else nx,ny=1,0 end
   x,y=m.x+nx*(r+.05),m.y+ny*(r+.05)
   local dot=vx*nx+vy*ny
   -- An active round spring ejects radially, including slow and grazing hits.
   -- Separating contacts only depenetrate; they must not fire a second impulse.
   if dot<=0 then
    local rebound=math.max(90,math.min(240,speed*.85))
    vx,vy=nx*rebound,ny*rebound;m.hitAt=t
   end
   hit=true
  end
 end end
 return x,y,vx,vy,hit
end
function M.wind(c,x,y,vx,vy,z,dt)
 for _,m in ipairs(c.mechanisms or {}) do if m.kind=='fan' and z<85 then
  local r=m.region
  if math.abs(x-r[1])<r[3]/2 and math.abs(y-r[2])<r[4]/2 then
   vx=vx+math.cos(m.angle or 0)*(m.force or 65)*dt;vy=vy+math.sin(m.angle or 0)*(m.force or 65)*dt
  end
 end end
 return vx,vy
end
local assets
local function art()
 if not assets then assets={lift=playdate.graphics.image.new('machine-lift'),slider=playdate.graphics.image.new('machine-slider'),fan=playdate.graphics.image.new('machine-fan'),bumper=playdate.graphics.image.new('machine-bumper')} end
 return assets
end
local oldDraw=M.draw
function M.draw(c,t,project)
 if not c.legacyView then
  local list={};for _,m in ipairs(c.mechanisms or {}) do if m.kind~='lift' and m.kind~='fan' and m.kind~='bumper' and not (m.kind=='ferry' and m.manual) then list[#list+1]=m end end
  c.legacyView=setmetatable({mechanisms=list},{__index=c})
 end
 oldDraw(c.legacyView,t,project)
 local g=playdate.graphics;local a=art()
 if not c.artMechanisms then
  c.artMechanisms={}
  for _,m in ipairs(c.mechanisms or {}) do if m.kind=='lift' or m.kind=='fan' or m.kind=='bumper' or (m.kind=='ferry' and m.manual) then c.artMechanisms[#c.artMechanisms+1]=m end end
 end
 for _,m in ipairs(c.artMechanisms) do
  local cx,cy=M.pose(m,t);local h=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(cx,cy)
  local sx,sy=project(cx,cy,h)
  if sx>-140 and sx<540 and sy>-100 and sy<330 then
   if m.kind=='lift' then
    local _,base=project(cx,cy,m.minHeight-15)
    g.setColor(g.kColorBlack);g.fillRect(sx-7,sy,14,math.max(4,base-sy));g.setColor(g.kColorWhite);g.fillRect(sx-3,sy,4,math.max(4,base-sy))
    a.lift:draw(sx-58,sy-40)
   elseif m.kind=='ferry' and m.manual then a.slider:draw(sx-72,sy-50)
   elseif m.kind=='bumper' then MachineArt.bumper(m,t,sx,sy)
   elseif m.kind=='fan' then
    a.fan:draw(sx-26,sy-43)
    MachineArt.fan(m,t,sx,sy)
   end
  end
 end
end
