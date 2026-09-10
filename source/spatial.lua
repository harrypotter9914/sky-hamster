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
 local function slab(p,d,a,b)
  if math.abs(d)<0.000001 then return p>=a and p<=b end
  local l,h=(a-p)/d,(b-p)/d;if l>h then l,h=h,l end
  low,high=math.max(low,l),math.min(high,h);return high>=low
 end
 if not slab(px,dx,-box.w/2,box.w/2) or not slab(py,dy,-box.h/2,box.h/2) then return false end
 return slab(z-box.slope*(x-box.x),18/13-box.slope,box.bottom,box.top) and high>=low
end
function S.occluders(course,t,project,left,top,width,height)
 local out={}
 local function add(x,y,w,h,a,bottom,roof,slope)
  local c,s=math.cos(a),math.sin(a);local minX,minY,maxX,maxY=1e9,1e9,-1e9,-1e9
  for _,u in ipairs({-w/2,w/2}) do for _,v in ipairs({-h/2,h/2}) do
   local px,py=x+u*c-v*s,y+u*s+v*c
   for _,z in ipairs({bottom,roof}) do
    local sx,sy=project(px,py,z+slope*(px-x));minX=math.min(minX,sx);maxX=math.max(maxX,sx);minY=math.min(minY,sy);maxY=math.max(maxY,sy)
   end
  end end
  if maxX<left or minX>left+width or maxY<top or minY>top+height then return end
  out[#out+1]={x=x,y=y,w=w,h=h,c=c,s=s,bottom=bottom,top=roof,slope=slope}
 end
 for _,tile in ipairs(course.tiles) do
  local x,y=tile.x*32+16,tile.y*32+16;local h,slope=course:height(x,y)
  add(x,y,32,32,0,h-S.thickness,h,slope)
 end
 for _,m in ipairs(course.mechanisms or {}) do
  local open=(m.kind=='gate' or m.kind=='trap') and Mechanisms.open(m,t)
  if not open then
   local x,y,a=Mechanisms.pose(m,t);local floor=course:height(x,y)
   local wall=m.kind=='gate' or m.kind=='sweeper'
   add(x,y,m.w,m.h,a,wall and floor or floor-1,wall and floor+(m.wallHeight or 80) or floor,0)
  end
 end
 return out
end
function S.visible(boxes,x,y,z,ox,oy)
 for _,box in ipairs(boxes) do if S.hidden(box,x+ox/1.8,y-ox/1.8,z+(12-oy)/0.65) then return false end end
 return true
end
