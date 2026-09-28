import "footing"
Mechanisms={}
local M=Mechanisms
local empty={}
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
-- Smooth travel with a genuine pause at each dock (quarter of a cycle).
function M.travel(t,period,phase)
 local u=((t+(phase or 0))%period)/period
 if u<0.2 then return 0 elseif u<0.5 then return (1-math.cos((u-0.2)/0.3*math.pi))/2
 elseif u<0.7 then return 1 else return (1+math.cos((u-0.7)/0.3*math.pi))/2 end
end
function M.pose(m,t)
 if m.kind~='ferry' and m.kind~='rotor' and m.kind~='sweeper' then return m.x,m.y,0 end
 local u=(m.kind=='ferry' or m.kind=='rotor') and M.travel(t,m.period or 10,m.phase) or 0
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
 if a==0 then return dx,dy end
 local c,s=math.cos(a),math.sin(a)
 return dx*c+dy*s,-dx*s+dy*c
end
function M.contains(m,x,y,t)
 local a,b=M.localPoint(m,x,y,t)
 return math.abs(a)<=m.w/2+.000001 and math.abs(b)<=m.h/2+.000001
end
function M.carry(m,x,y,t,nextT)
 local a,b=M.localPoint(m,x,y,t);local cx,cy,r=M.pose(m,nextT)
 return cx+a*math.cos(r)-b*math.sin(r),cy+a*math.sin(r)+b*math.cos(r)
end
function M.support(course,x,y,t)
 local ok,m=Footing.query(course,x,y,t);return ok,m
end
-- Circle / moving AABB response. Substeps prevent tunnelling; no bonus brake.
function M.collide(course,x,y,vx,vy,z,t,dt)
 local hit=false
 for _,m in ipairs(course.mechanisms or empty) do
  if (m.kind=='sweeper' or (m.kind=='gate' and not M.open(m,t))) and z<(M.wallHeight and M.wallHeight(m,t) or m.wallHeight or 80) then
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
 for _,m in ipairs(course.mechanisms or empty) do
  local cx,cy=M.pose(m,t)
  local sx,sy=project(cx,cy,course:height(m.x,m.y))
  -- Conservative rotated bounds, including wall height and the raised label.
  local extent=(m.w+m.h)*0.64+40
  local rise=(m.wallHeight or 80)*0.65+30
  if sx+extent>=-32 and sx-extent<=432 and sy+extent>=12 and sy-extent-rise<=236 then
  local points=M.corners(m,t);local poly={};local wall=m.kind=='gate' or m.kind=='sweeper'
  local opened=(m.kind=='gate' or m.kind=='trap') and M.open(m,t)
  local wallHeight=M.wallHeight and M.wallHeight(m,t) or m.wallHeight or 80
  local h=course:height(m.x,m.y)
  for _,p in ipairs(points) do local sx,sy=project(p[1],p[2],h);poly[#poly+1]=sx;poly[#poly+1]=sy end
  if wall and not opened then
   -- One closed prism: both long faces, both end caps, and the top.
   -- Project the same world height used by collision rather than a fake lip.
   local top={}
   for _,p in ipairs(points) do local sx,sy=project(p[1],p[2],h+wallHeight);top[#top+1]=sx;top[#top+1]=sy end
   for _,i in ipairs({1,4,2,3}) do
    local j=i%4+1;local a,b=2*i-1,2*j-1
    local face={poly[a],poly[a+1],poly[b],poly[b+1],top[b],top[b+1],top[a],top[a+1]}
    g.setColor(g.kColorWhite);g.fillPolygon(table.unpack(face))
    g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(face))
    for k=1,3 do
     local u=k/4
     g.drawLine(poly[a]+(poly[b]-poly[a])*u,poly[a+1]+(poly[b+1]-poly[a+1])*u,
      top[a]+(top[b]-top[a])*u,top[a+1]+(top[b+1]-top[a+1])*u)
    end
    -- Riveted panels and an inset warning stripe stay on the actual wall face.
    local function fp(u,v) return poly[a]+(poly[b]-poly[a])*u+(top[a]-poly[a])*v,poly[a+1]+(poly[b+1]-poly[a+1])*u+(top[a+1]-poly[a+1])*v end
    local x1,y1=fp(.01,.04);local x2,y2=fp(.99,.04);local x3,y3=fp(.99,.34);local x4,y4=fp(.01,.34)
    g.fillPolygon(x1,y1,x2,y2,x3,y3,x4,y4)
    for k=0,2 do
     local u=.07+k*.3
     local a1,b1=fp(u,.07);local a2,b2=fp(u+.12,.07);local a3,b3=fp(u+.23,.31);local a4,b4=fp(u+.11,.31)
     g.setColor(g.kColorWhite);g.fillPolygon(a1,b1,a2,b2,a3,b3,a4,b4);g.setColor(g.kColorBlack)
     local bx,by=fp(u+.07,.84);g.fillCircleAtPoint(bx,by,1.5)
    end
    local lx,ly=fp(.03,.7);local rx,ry=fp(.97,.7);g.drawLine(lx,ly,rx,ry)
   end
   g.setColor(g.kColorWhite);g.fillPolygon(table.unpack(top))
   g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(top))
  else
   g.setColor(g.kColorWhite);if not opened then g.fillPolygon(table.unpack(poly)) end
   g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(poly))
  end
  if not opened and not wall then
   local function fp(u,v) return poly[1]+(poly[3]-poly[1])*u+(poly[7]-poly[1])*v,poly[2]+(poly[4]-poly[2])*u+(poly[8]-poly[2])*v end
   local function seam(u,v,s,t) local a,b=fp(u,v);local c,d=fp(s,t);g.drawLine(a,b,c,d) end
   seam(.04,.07,.96,.07);seam(.04,.93,.96,.93);seam(.04,.07,.04,.93);seam(.96,.07,.96,.93)
   -- Dark steel edge rails make moving decks distinct from the stone road.
   for _,v in ipairs({0,.9}) do
    local a,b=fp(0,v);local c,d=fp(1,v);local e,f=fp(1,v+.1);local h,i=fp(0,v+.1);g.fillPolygon(a,b,c,d,e,f,h,i)
   end
   local count=math.min(8,math.max(3,math.floor(m.w/32)))
   for k=1,count-1 do seam(k/count,.10,k/count,.90);seam(k/count-.025,.10,k/count-.025,.90) end
   for _,u in ipairs({.09,.91}) do for _,v in ipairs({.17,.83}) do local a,b=fp(u,v);g.fillCircleAtPoint(a,b,1.5) end end
   if m.kind=='trap' then
    for k=0,4 do local u=.10+k*.16;seam(u,.09,u+.08,.25);seam(u,.75,u+.08,.91) end
   elseif m.kind=='rotor' then
    local a,b=fp(.5,.5);g.setColor(g.kColorWhite);g.fillCircleAtPoint(a,b,7);g.setColor(g.kColorBlack);g.fillCircleAtPoint(a,b,7);g.setColor(g.kColorWhite);g.drawCircleAtPoint(a,b,5);g.fillCircleAtPoint(a,b,2);g.setColor(g.kColorBlack)
   else
    seam(.20,.42,.38,.5);seam(.38,.5,.20,.58);seam(.62,.42,.80,.5);seam(.80,.5,.62,.58)
   end
  end
  local cx,cy=M.pose(m,t);local sx,sy=project(cx,cy,h+(wall and not opened and wallHeight or 0))
  local label=m.kind=='gate' and (opened and 'GO' or 'WAIT') or m.kind=='trap' and (opened and 'HOLE' or M.warning(m,t) and 'OPENING!' or 'CROSS') or m.retract and 'EXTEND' or m.kind=='rotor' and 'ROTATE' or m.kind=='ferry' and 'RIDE' or 'WATCH'
  if not m.retract and not m.hideLabel then
  local width=g.getTextSize(label)
  g.setColor(g.kColorWhite);g.fillRect(sx-width/2-3,sy-29,width+6,18)
  g.setColor(g.kColorBlack);g.drawTextAligned(label,sx,sy-28,kTextAlignment.center)
  end
  end
 end
end
