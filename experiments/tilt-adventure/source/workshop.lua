-- Reuse the established bridge, dial and stone materials for moving machinery.
local M,D=Mechanisms,Dock
local pose,opened,reset,update,wind,draw=M.pose,M.open,D.reset,D.update,M.wind,M.draw
function M.pose(m,t)
 if m.retract then return m.anchor+m.w/2,m.y,0 end
 return pose(m,t)
end
function M.open(m,t) if m.switchGate then return m.isOpen end return opened(m,t) end
function D.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  if m.retract then m.w=16 end
  if m.switchGate then m.isOpen=m.initialOpen end
 end
 reset(c)
end
function D.update(c,x,y,vx,vy,airborne,crank,a,b)
 local r=update(c,x,y,vx,vy,airborne,crank,a,b);local p=D.active
 if p and r and r.locked then
  if p.kind=='extend' then p.target.w=math.max(16,math.min(p.target.maxWidth,p.target.w+crank*.5))
  elseif p.kind=='switch' then
   p.target.isOpen=math.sin(p.angle)>=0;p.target.partner.isOpen=not p.target.isOpen
  end
 end
 return r
end
function M.wind(c,x,y,vx,vy,z,dt,t)
 vx,vy=wind(c,x,y,vx,vy,z,dt)
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='conveyor' and z<3 and z>=-1 and M.contains(m,x,y,t or 0) then
   local dx,dy=math.cos(m.angle or 0),math.sin(m.angle or 0)
   local along=vx*dx+vy*dy;local force=((m.speed or 65)-along)*1.4
   vx,vy=vx+dx*force*dt,vy+dy*force*dt
  elseif m.kind=='jet' and z<70 and M.contains(m,x,y,t or 0) and ((t or 0)+(m.phase or 0))%m.period<m.period*.4 then
   vx,vy=vx+math.cos(m.angle or 0)*160*dt,vy+math.sin(m.angle or 0)*160*dt
  elseif m.kind=='magnet' and z<45 then
   local dx,dy=m.x-x,m.y-y;local d=math.sqrt(dx*dx+dy*dy)
   if d>10 and d<(m.radius or 140) then local f=(1-d/(m.radius or 140))*110*dt;vx,vy=vx+dx/d*f,vy+dy/d*f end
  end
 end
 return vx,vy
end
local decor={conveyor=true,jet=true,magnet=true}
function M.draw(c,t,project)
 if not c.workshopView then
  local list={};for _,m in ipairs(c.mechanisms or {}) do if not decor[m.kind] then list[#list+1]=m end end
  c.workshopView=setmetatable({mechanisms=list},{__index=c})
 end
 draw(c.workshopView,t,project)
 local g=playdate.graphics
 for _,m in ipairs(c.mechanisms or {}) do if decor[m.kind] then
  local sx,sy=project(m.x,m.y,c:height(m.x,m.y))
  local extent=math.max(80,(m.w+m.h)*.64)
  if sx+extent>0 and sx-extent<400 and sy+extent>40 and sy-extent<205 then
   local pts=M.corners(m,t);local poly={}
   for _,p in ipairs(pts) do local px,py=project(p[1],p[2],c:height(p[1],p[2]));poly[#poly+1]=px;poly[#poly+1]=py end
   g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(poly))
   if m.kind=='magnet' then
    MachineArt.sprite('magnet',sx,sy+4)
    for i=1,2 do local r=18+(t*12+i*14)%30;g.drawArc(sx,sy-10,r,220,320) end
   else
    local active=m.kind=='conveyor' or (t+(m.phase or 0))%m.period<m.period*.4
    if m.kind=='conveyor' then
     g.fillPolygon(table.unpack(poly));g.setColor(g.kColorWhite)
     local horizontal=math.abs(math.cos(m.angle or 0))>.5
     local span=horizontal and m.w or m.h;local dir=horizontal and math.cos(m.angle or 0) or math.sin(m.angle or 0)
     for off=0,span-12,16 do
      local at=-span/2+((off+t*18*dir)%math.max(1,span-8))+4
      local ax,ay,bx,by
      if horizontal then ax,ay=project(m.x+at,m.y-m.h/2+5,c:height(m.x+at,m.y));bx,by=project(m.x+at,m.y+m.h/2-5,c:height(m.x+at,m.y))
      else ax,ay=project(m.x-m.w/2+5,m.y+at,c:height(m.x,m.y));bx,by=project(m.x+m.w/2-5,m.y+at,c:height(m.x,m.y)) end
     g.drawLine(ax,ay,bx,by)
     end
     local mx,my=project(m.x-m.w/2+16,m.y,c:height(m.x,m.y));MachineArt.sprite('roller',mx,my+5);MachineArt.gear(mx-8,my-12,t*120)
    end
    for i=-2,2 do
     local x=m.x+i*m.w/6;local px,py=project(x,m.y,c:height(x,m.y))
     if m.kind=='jet' then
      MachineArt.sprite('nozzle',px,py+3);g.setColor(g.kColorBlack)
     else g.fillEllipseInRect(px-4,py-2,8,4) end
     if active then
      local d=m.kind=='jet' and 13+(t*20)%8 or 8+(t*18)%12
      local dx,dy=math.cos(m.angle or 0),math.sin(m.angle or 0)
      local ux,uy=(dx-dy)*.9,(dx+dy)*.45
      g.drawLine(px,py,px+ux*d,py+uy*d);g.fillCircleAtPoint(px+ux*d,py+uy*d,2)
      if m.kind=='jet' then for k=1,3 do local dist=16+((t*48+k*13)%42);g.drawArc(px+ux*dist,py+uy*dist-17-k*2,3+k,210,345) end end
     end
    end
   end
  end
 end end
end
