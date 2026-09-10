Mechanisms={}
local M=Mechanisms
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
-- Smooth travel with a genuine pause at each dock (quarter of a cycle).
function M.travel(t,period,phase)
 local u=((t+(phase or 0))%period)/period
 if u<0.2 then return 0 elseif u<0.5 then return (1-math.cos((u-0.2)/0.3*math.pi))/2
 elseif u<0.7 then return 1 else return (1+math.cos((u-0.7)/0.3*math.pi))/2 end
end
function M.pose(m,t)
 local u=M.travel(t,m.period or 10,m.phase)
 if m.kind=='ferry' then return m.x+(m.toX-m.x)*u,m.y+(m.toY-m.y)*u,0 end
 if m.kind=='rotor' then return m.x,m.y,(m.angle or 0)+u*math.pi end
 if m.kind=='sweeper' then return m.x,m.y+math.sin((t+(m.phase or 0))*math.pi*2/m.period)*m.range,0 end
 return m.x,m.y,0
end
function M.open(m,t) return ((t+(m.phase or 0))%m.period)/m.period < (m.openFor or 0.45) end
function M.warning(m,t)
 local u=((t+(m.phase or 0))%m.period)/m.period
 return m.kind=='trap' and not M.open(m,t) and u>0.86
end
function M.localPoint(m,x,y,t)
 local cx,cy,a=M.pose(m,t);local dx,dy=x-cx,y-cy
 return dx*math.cos(a)+dy*math.sin(a),-dx*math.sin(a)+dy*math.cos(a)
end
function M.contains(m,x,y,t)
 local a,b=M.localPoint(m,x,y,t)
 return math.abs(a)<=m.w/2 and math.abs(b)<=m.h/2
end
function M.carry(m,x,y,t,nextT)
 local a,b=M.localPoint(m,x,y,t);local cx,cy,r=M.pose(m,nextT)
 return cx+a*math.cos(r)-b*math.sin(r),cy+a*math.sin(r)+b*math.cos(r)
end
function M.support(course,x,y,t)
 for _,m in ipairs(course.mechanisms or {}) do
  if (m.kind=='ferry' or m.kind=='rotor' or (m.kind=='trap' and not M.open(m,t))) and M.contains(m,x,y,t) then return true,m end
 end
 return course.lookup[math.floor(x/32)..','..math.floor(y/32)]==true,nil
end
-- Circle / moving AABB response. Substeps prevent tunnelling; no bonus brake.
function M.collide(course,x,y,vx,vy,z,t,dt)
 local hit=false
 for _,m in ipairs(course.mechanisms or {}) do
  if (m.kind=='sweeper' or (m.kind=='gate' and not M.open(m,t))) and z<(m.wallHeight or 80) then
   local cx,cy=M.pose(m,t);local px,py=M.pose(m,t-dt)
   local nx,ny=x-clamp(x,cx-m.w/2,cx+m.w/2),y-clamp(y,cy-m.h/2,cy+m.h/2)
   local d=math.sqrt(nx*nx+ny*ny)
   if d<9 then
    local push=9-d
    if d<0.00001 then
     local ex,ey=m.w/2-math.abs(x-cx),m.h/2-math.abs(y-cy)
     if ex<ey then nx,ny=x<cx and -1 or 1,0;push=9+ex else nx,ny=0,y<cy and -1 or 1;push=9+ey end
    else nx,ny=nx/d,ny/d end
    x,y=x+nx*push,y+ny*push
    local wx,wy=(cx-px)/dt,(cy-py)/dt
    local approach=(vx-wx)*nx+(vy-wy)*ny
    if approach<0 then vx,vy=vx-approach*nx,vy-approach*ny end
    hit=true
   end
  end
 end
 return x,y,vx,vy,hit
end
function M.corners(m,t)
 local x,y,a=M.pose(m,t);local points={}
 for _,p in ipairs({{-1,-1},{1,-1},{1,1},{-1,1}}) do
  local u,v=p[1]*m.w/2,p[2]*m.h/2
  points[#points+1]={x+u*math.cos(a)-v*math.sin(a),y+u*math.sin(a)+v*math.cos(a)}
 end
 return points
end
function M.draw(course,t,project)
 local g=playdate.graphics
 for _,m in ipairs(course.mechanisms or {}) do
  local points=M.corners(m,t);local poly={};local wall=m.kind=='gate' or m.kind=='sweeper'
  local opened=(m.kind=='gate' or m.kind=='trap') and M.open(m,t)
  local h=course:height(m.x,m.y)
  for _,p in ipairs(points) do local sx,sy=project(p[1],p[2],h);poly[#poly+1]=sx;poly[#poly+1]=sy end
  g.setColor(g.kColorWhite);if not opened then g.fillPolygon(table.unpack(poly)) end
  g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(poly))
  if not opened then
   g.drawLine(poly[1],poly[2],poly[5],poly[6]);g.drawLine(poly[3],poly[4],poly[7],poly[8])
   if wall then
    -- Tall screen with hatch marks; even a fully charged jump cannot bypass it.
    g.setColor(g.kColorWhite);g.fillPolygon(poly[3],poly[4],poly[5],poly[6],poly[5],poly[6]-34,poly[3],poly[4]-34)
    g.setColor(g.kColorBlack);g.drawPolygon(poly[3],poly[4],poly[5],poly[6],poly[5],poly[6]-34,poly[3],poly[4]-34)
    g.drawLine(poly[3],poly[4]-17,poly[5],poly[6]-17)
   end
  end
  local cx,cy=M.pose(m,t);local sx,sy=project(cx,cy,h)
  local label=m.kind=='gate' and (opened and 'GO' or 'WAIT') or m.kind=='trap' and (opened and 'HOLE' or M.warning(m,t) and 'OPENING!' or 'CROSS') or m.kind=='rotor' and 'ROTATE' or m.kind=='ferry' and 'RIDE' or 'WATCH'
  local width=g.getTextSize(label)
  g.setColor(g.kColorWhite);g.fillRect(sx-width/2-3,sy-29,width+6,18)
  g.setColor(g.kColorBlack);g.drawTextAligned(label,sx,sy-28,kTextAlignment.center)
 end
end
