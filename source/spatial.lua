Spatial={}
local S=Spatial
S.thickness=12/0.65
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
-- Resolve low airborne contact with platform volume, never treat it as landing.
function S.sides(course,x,y,vx,vy,z,t)
 local hit=false
 local function box(cx,cy,w,h,angle,floor)
  if z>=floor-0.5 or z+24<=floor-S.thickness then return end
  local c,s=math.cos(angle),math.sin(angle)
  local px,py=(x-cx)*c+(y-cy)*s,-(x-cx)*s+(y-cy)*c
  local nx,ny=px-clamp(px,-w/2,w/2),py-clamp(py,-h/2,h/2)
  local d=math.sqrt(nx*nx+ny*ny)
  if d>=9 then return end
  local push=9-d
  if d<0.00001 then
   local ex,ey=w/2-math.abs(px),h/2-math.abs(py)
   if ex<ey then nx,ny=px<0 and -1 or 1,0;push=9+ex else nx,ny=0,py<0 and -1 or 1;push=9+ey end
  else nx,ny=nx/d,ny/d end
  nx,ny=nx*c-ny*s,nx*s+ny*c
  x,y=x+nx*push,y+ny*push
  local speed=vx*nx+vy*ny
  if speed<0 then vx,vy=vx-1.15*speed*nx,vy-1.15*speed*ny end
  hit=true
 end
 -- Only nearby tiles; radius is smaller than a tile.
 local tx,ty=math.floor(x/32),math.floor(y/32)
 for i=tx-1,tx+1 do for j=ty-1,ty+1 do
  if course.lookup[i..','..j] then
   box(i*32+16,j*32+16,32,32,0,course:height(clamp(x,i*32,(i+1)*32),clamp(y,j*32,(j+1)*32)))
  end
 end end
 for _,m in ipairs(course.mechanisms or {}) do
  if m.kind=='ferry' or m.kind=='rotor' or (m.kind=='trap' and not Mechanisms.open(m,t)) then
   local cx,cy,a=Mechanisms.pose(m,t);box(cx,cy,m.w,m.h,a,course:height(cx,cy))
  end
 end
 return x,y,vx,vy,hit
end
-- Orthographic camera ray points toward increasing x, y and height.
-- Pixel masks preserve partial occlusion without drawing a whole wall over a ball.
function S.hidden(box,x,y,z)
 local c,s=box.c,box.s
 local px,py=(x-box.x)*c+(y-box.y)*s,-(x-box.x)*s+(y-box.y)*c
 local dx,dy=c+s,c-s
 local low,high=0.001,10000
 if math.abs(dx)<0.000001 then if math.abs(px)>box.w/2 then return false end
 else
  local l,h=(-box.w/2-px)/dx,(box.w/2-px)/dx;if l>h then l,h=h,l end
  low,high=math.max(low,l),math.min(high,h);if high<low then return false end
 end
 if math.abs(dy)<0.000001 then if math.abs(py)>box.h/2 then return false end
 else
  local l,h=(-box.h/2-py)/dy,(box.h/2-py)/dy;if l>h then l,h=h,l end
  low,high=math.max(low,l),math.min(high,h);if high<low then return false end
 end
 local p,d=z-box.slope*(x-box.x),18/13-box.slope
 if math.abs(d)<0.000001 then return p>=box.bottom and p<=box.top end
 local l,h=(box.bottom-p)/d,(box.top-p)/d;if l>h then l,h=h,l end
 return math.min(high,h)>=math.max(low,l)
end
local function makeBox(x,y,w,h,a,bottom,roof,slope)
  local c,s=math.cos(a),math.sin(a);local minX,minY,maxX,maxY=1e9,1e9,-1e9,-1e9
  for _,u in ipairs({-w/2,w/2}) do for _,v in ipairs({-h/2,h/2}) do
   local px,py=x+u*c-v*s,y+u*s+v*c
   for _,z in ipairs({bottom,roof}) do
    local sx,sy=(px-py)*0.9,(px+py)*0.45-(z+slope*(px-x))*0.65;minX=math.min(minX,sx);maxX=math.max(maxX,sx);minY=math.min(minY,sy);maxY=math.max(maxY,sy)
   end
  end end
  return {x=x,y=y,w=w,h=h,c=c,s=s,bottom=bottom,top=roof,slope=slope,minX=minX,maxX=maxX,minY=minY,maxY=maxY,maxRoof=roof+math.abs(slope)*(math.abs(w*c)+math.abs(h*s))/2}
end
function S.occluders(course,t,project,left,top,width,height,minZ)
 if not course.maxTerrainRoof then
  course.maxTerrainRoof=-1e9
  for _,p in ipairs(course.profile) do course.maxTerrainRoof=math.max(course.maxTerrainRoof,p[2]) end
 end
 local needTerrain=not minZ or course.maxTerrainRoof>minZ
 if needTerrain and not course.occlusionCache then
  course.occlusionCache={}
  for _,tile in ipairs(course.tiles) do
   local x,y=tile.x*32+16,tile.y*32+16;local h,slope=course:height(x,y)
   course.occlusionCache[#course.occlusionCache+1]=makeBox(x,y,32,32,0,h-S.thickness,h,slope)
  end
 end
 local out={};local ox,oy=project(0,0,0)
 left,top=left-ox,top-oy
 local right,bottom=left+width,top+height
 local function add(b)
  if minZ and b.maxRoof<=minZ then return end
  if b.maxX<left or b.minX>right or b.maxY<top or b.minY>bottom then return end
  out[#out+1]=b
 end
 if needTerrain then for _,b in ipairs(course.occlusionCache) do add(b) end end
 for _,m in ipairs(course.mechanisms or {}) do
  local open=(m.kind=='gate' or m.kind=='trap') and Mechanisms.open(m,t)
  if not open then
   local x,y,a=Mechanisms.pose(m,t);local floor=course:height(x,y)
   local wall=m.kind=='gate' or m.kind=='sweeper'
   local roof=wall and floor+(m.wallHeight or 80) or floor
   if not minZ or roof>minZ then add(makeBox(x,y,m.w,m.h,a,wall and floor or floor-1,roof,0)) end
  end
 end
 return out
end
function S.visible(boxes,x,y,z,ox,oy)
 for _,box in ipairs(boxes) do if S.hidden(box,x+ox/1.8,y-ox/1.8,z+(12-oy)/0.65) then return false end end
 return true
end
-- Clip a convex volume to the half-space in front of the ball billboard.
-- Its projected convex hull is exactly the occluding region; native rasterization
-- replaces hundreds of Lua ray queries per frame.
function S.maskPolygon(box,bx,by,project,left,top)
 local vertices={};local points={};local near=bx+by+0.002
 for layer=0,1 do
  for _,p in ipairs({{-1,-1},{1,-1},{1,1},{-1,1}}) do
   local u,v=p[1]*box.w/2,p[2]*box.h/2
   local x,y=box.x+u*box.c-v*box.s,box.y+u*box.s+v*box.c
   local z=(layer==0 and box.bottom or box.top)+box.slope*(x-box.x)
   vertices[#vertices+1]={x,y,z}
  end
 end
 local function add(x,y,z)
  local sx,sy=project(x,y,z);points[#points+1]={sx-left,sy-top}
 end
 for _,v in ipairs(vertices) do if v[1]+v[2]>=near then add(v[1],v[2],v[3]) end end
 local function edge(a,b)
  local p,q=vertices[a],vertices[b];local da,db=p[1]+p[2]-near,q[1]+q[2]-near
  if (da<0 and db>0) or (da>0 and db<0) then
   local u=da/(da-db);add(p[1]+(q[1]-p[1])*u,p[2]+(q[2]-p[2])*u,p[3]+(q[3]-p[3])*u)
  end
 end
 for i=1,4 do edge(i,i%4+1);edge(i+4,i%4+5);edge(i,i+4) end
 if #points<3 then return nil end
 table.sort(points,function(a,b) return a[1]==b[1] and a[2]<b[2] or a[1]<b[1] end)
 local function cross(o,a,b) return (a[1]-o[1])*(b[2]-o[2])-(a[2]-o[2])*(b[1]-o[1]) end
 local hull={}
 for _,p in ipairs(points) do
  while #hull>=2 and cross(hull[#hull-1],hull[#hull],p)<=0 do hull[#hull]=nil end
  hull[#hull+1]=p
 end
 local lower=#hull
 for i=#points-1,1,-1 do
  local p=points[i]
  while #hull>lower and cross(hull[#hull-1],hull[#hull],p)<=0 do hull[#hull]=nil end
  hull[#hull+1]=p
 end
 hull[#hull]=nil
 if #hull<3 then return nil end
 local out={};for _,p in ipairs(hull) do out[#out+1]=p[1];out[#out+1]=p[2] end
 return out
end
