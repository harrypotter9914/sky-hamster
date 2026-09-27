-- Road slabs in front must occlude machinery skirts, even at a flush seam.
-- Candidate tiles are prepared once, rather than scanning the whole course per frame.
DepthOrder={}
local D=DepthOrder
local previousCourse
local g=playdate.graphics
function D.prepare(c)
 if previousCourse and previousCourse~=c then
  for _,m in ipairs(previousCourse.mechanisms or {}) do m.roadCovers=nil;m.coverPose=nil end
  for _,m in ipairs(previousCourse.pads or {}) do m.roadCovers=nil;m.coverPose=nil end
 end
 previousCourse=c
 for i,tile in ipairs(c.tiles or {}) do
  local x,y=tile.x*32+16,tile.y*32+16
  tile.depthX=(x-y)*.9;tile.depthY=(x+y)*.45-c:height(x,y)*.65;tile.depthId=i
 end
 local items={}
 for _,m in ipairs(c.mechanisms or {}) do items[#items+1]=m end
 for _,p in ipairs(c.pads or {}) do if p.kind=='cannon' then p.w,p.h=50,50;items[#items+1]=p end end
 for _,m in ipairs(items) do
  local reach=math.sqrt((m.maxWidth or m.w)^2+m.h^2)/2+80
  local x0,x1=math.min(m.x,m.toX or m.x)-reach,math.max(m.x,m.toX or m.x)+reach
  local y0,y1=math.min(m.y,m.toY or m.y)-reach-(m.range or 0),math.max(m.y,m.toY or m.y)+reach+(m.range or 0)
  m.roadFrontCandidates={}
  for _,tile in ipairs(c.tiles or {}) do
   local x,y=tile.x*32,tile.y*32
   if x+32>=x0 and x<=x1 and y+32>=y0 and y<=y1 then m.roadFrontCandidates[#m.roadFrontCandidates+1]=tile end
  end
 end
end
function D.bounds(m,t)
 local x,y,a=Mechanisms.pose(m,t);local c,s=math.abs(math.cos(a)),math.abs(math.sin(a))
 local ex,ey=(m.w*c+m.h*s)/2,(m.w*s+m.h*c)/2
 return x-ex,x+ex,y-ey,y+ey
end
function D.inFront(m,t,tile)
 local x0,x1,y0,y1=D.bounds(m,t)
 local a,b=tile.x*32,tile.y*32
 -- Separated footprints are essential: a supporting tile must not erase its machine.
 return (a>=x1-.00001 and b+32>=y0-40 and b<=y1+40)
     or (b>=y1-.00001 and a+32>=x0-40 and a<=x1+40)
end
function D.cover(c,m,t)
 local cx,cy,a=Mechanisms.pose(m,t)
 local h=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(cx,cy)
 local pose=m.coverPose
 if pose and pose.x==cx and pose.y==cy and pose.a==a and pose.w==m.w and pose.z==h then return pose.cover end
 local x0,x1,y0,y1=D.bounds(m,t)
 local sx,sy=(cx-cy)*.9,(cx+cy)*.45-h*.65
 local ex=(m.w+m.h)*.65+45
 local tiles,ids={},{}
 for _,tile in ipairs(m.roadFrontCandidates or {}) do
  local u,v=tile.x*32,tile.y*32
  if ((u>=x1-.00001 and v+32>=y0-40 and v<=y1+40) or (v>=y1-.00001 and u+32>=x0-40 and u<=x1+40))
    and math.abs(tile.depthX-sx)<ex and tile.depthY-24<sy+ex*.5 and tile.depthY+36>sy-ex*.5 then
   tiles[#tiles+1]=tile;ids[#ids+1]=tile.depthId
  end
 end
 local key=table.concat(ids,',');local covers=m.roadCovers or {};m.roadCovers=covers
 local cover=covers[key]
 if not cover then
  cover={tiles=tiles};covers[key]=cover
  local left,top,right,bottom=1e9,1e9,-1e9,-1e9
  local ready=#tiles>0
  for _,tile in ipairs(tiles) do
   local s=tile.surface
   if not s then ready=false;break end
   local w,h=s.image:getSize();left=math.min(left,s.x);top=math.min(top,s.y);right=math.max(right,s.x+w);bottom=math.max(bottom,s.y+h)
  end
  if ready then
   cover.image=g.image.new(right-left,bottom-top,g.kColorClear);cover.x,cover.y=left,top
   g.pushContext(cover.image)
   for _,tile in ipairs(tiles) do local s=tile.surface;s.image:draw(s.x-left,s.y-top) end
   g.popContext()
  end
 end
 m.coverPose={x=cx,y=cy,a=a,w=m.w,z=h,cover=cover}
 return cover
end
function D.roads(c,m,t,project,drawTile)
 if not drawTile then return end
 local cx,cy=Mechanisms.pose(m,t)
 local h=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(cx,cy)
 local sx,sy=project(cx,cy,h);local ex=(m.w+m.h)*.65+45
 if sx+ex<0 or sx-ex>400 or sy+ex<42 or sy-ex>212 then return end
 local cover=D.cover(c,m,t)
 if cover.image then local ox,oy=project(0,0,0);cover.image:draw(cover.x+ox-200,cover.y+oy-124)
 else for _,tile in ipairs(cover.tiles) do drawTile(tile) end end
end
function D.warm(c,m)
 local moving=m.kind=='ferry' or m.kind=='rotor' or m.kind=='lift' or m.kind=='sweeper'
 local angle,progress,elevation,width=m.angle,m.progress,m.elevation,m.w
 local count=moving and 36 or 0
 for i=0,count do
  local u=count>0 and i/count or 0
  if m.kind=='lift' then m.elevation=m.minHeight+u*(m.maxHeight-m.minHeight)
  elseif m.manual and m.kind=='ferry' then m.progress=u
  elseif m.manual and not m.retract then m.angle=u*math.pi end
  D.cover(c,m,u*(m.period or 10))
  if Loading and i%12==0 then Loading.checkpoint(.7,'FITTING THE ROAD EDGES') end
 end
 m.angle,m.progress,m.elevation,m.w=angle,progress,elevation,width
 m.coverPose=nil
end
