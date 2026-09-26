Dock={active=nil,blocked=nil}
local D=Dock
function D.reset(course)
 D.active=nil;D.blocked=nil
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
function D.draw(course,project)
 local g=playdate.graphics
 for _,p in ipairs(course.pads or {}) do
  local x,y=project(p.x,p.y,course:height(p.x,p.y))
  if x>-40 and x<440 and y>35 and y<205 then
   g.setColor(g.kColorWhite);g.fillEllipseInRect(x-15,y-7,30,14);g.setColor(g.kColorBlack);g.drawEllipseInRect(x-15,y-7,30,14)
   g.drawText(p.kind=='cannon' and 'CANNON' or 'CONTROL',x-30,y-29)
   if p.kind=='cannon' then
    local dx,dy=math.cos(p.angle or 0),math.sin(p.angle or 0)
    local ex,ey=project(p.x+dx*30,p.y+dy*30,course:height(p.x,p.y)+10)
    g.setLineWidth(5);g.drawLine(x,y-4,ex,ey);g.setLineWidth(1)
    if D.active==p then for i=1,10 do local t=i*.1;local px,py=project(p.x+dx*210*t,p.y+dy*210*t,course:height(p.x,p.y)+150*t-150*t*t);g.fillCircleAtPoint(px,py,2) end end
   end
  end
 end
end
local pose=Mechanisms.pose
function Mechanisms.pose(m,t) if m.manual then return m.x,m.y,m.angle or 0 end return pose(m,t) end
