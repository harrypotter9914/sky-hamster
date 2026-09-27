-- Generated material panels are projected onto the actual collision footprint.
-- Machinery below a deck is decorative; the visible walkable top stays exact.
Structures={}
local A,M,g=Structures,Mechanisms,playdate.graphics
local tex,parts,boxes,belt={},{},{},{}
local wheel=g.image.new('detail-gear')
local xf=playdate.geometry and playdate.geometry.affineTransform.new()
for _,name in ipairs({'deck','beam','hatch','gate','belt','bearing','socket','rail'}) do tex[name]=g.image.new('structures/'..name) end
for _,name in ipairs({'pillar','bogie','cradle','gearbox'}) do parts[name]=g.image.new('structures/'..name) end
local function panel(image,p)
 if not xf then g.setColor(g.kColorWhite);g.fillPolygon(table.unpack(p));return end
 xf.m11=(p[3]-p[1])/64;xf.m12=(p[7]-p[1])/64
 xf.m21=(p[4]-p[2])/64;xf.m22=(p[8]-p[2])/64;xf.tx=0;xf.ty=0
 image:drawWithTransform(xf,(p[1]+p[5])/2,(p[2]+p[6])/2)
end
local function outline(p)
 g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(p))
end
local function prism(poly,depth,top,side)
 -- Front-facing faces only. Their 12-pixel depth matches Spatial.thickness.
 for i=1,4 do
  local j=i%4+1;local a,b=i*2-1,j*2-1
  if poly[a]>poly[b] then
   local face={poly[a],poly[a+1],poly[b],poly[b+1],poly[b],poly[b+1]+depth,poly[a],poly[a+1]+depth}
   panel(side or tex.beam,face);outline(face)
  end
 end
 if top then panel(top,poly);outline(poly) end
end
local function gearFrame(angle)
 local frame=math.floor((angle or 0)/22.5)%16
 if not boxes[frame] then
  local im=g.image.new(28,30,g.kColorClear);g.pushContext(im)
  parts.gearbox:draw(0,0)
  wheel:drawRotated(10,18,frame*22.5,.42,.42)
  g.popContext();boxes[frame]=im
 end
 return boxes[frame]
end
local bases={}
local function base(kind,x,y)
 local im=bases[kind]
 if not im then
  im=g.image.new(80,60,g.kColorClear);g.pushContext(im)
  local x,y=40,14
  if kind=='socket' then prism({x,y-12,x+23,y-1,x,y+10,x-23,y-1},5,tex.socket,tex.beam)
  elseif kind=='small' then prism({x,y-8,x+21,y+2,x,y+12,x-21,y+2},7,tex.bearing,tex.beam)
  else prism({x,y+4,x+24,y+16,x,y+28,x-24,y+16},kind=='bearing' and 6 or 5,kind=='bearing' and tex.bearing or tex.rail,tex.beam) end
  g.popContext();bases[kind]=im
 end
 im:draw(x-40,y-14)
end
-- Storyboards use the same generated machinery and pose functions as play.
local demos={}
function A.demo(kind,x,y,t,u)
 local item=demos[kind]
 if not item then
  local m={kind=kind,x=0,y=0,w=48,h=30,period=6,openFor=.4,wallHeight=48,range=24,angle=0,
   minHeight=0,maxHeight=44,elevation=0,toX=44,toY=-44}
  if kind=='slider' or kind=='ferry' then m.kind='ferry';m.x=-22;m.y=22;m.toX=22;m.toY=-22;m.w=34;m.h=28;m.manual=kind=='slider' end
  if kind=='rotor' then m.w=100;m.h=20 end
  if kind=='gate' or kind=='sweeper' then m.w=12;m.h=38 end
  item={m=m,course={mechanisms={m},height=function()return 0 end}};demos[kind]=item
 end
 local m=item.m
 if kind=='lift' then m.elevation=(u or 0)*44 end
 if kind=='slider' then m.progress=u or 0 end
 local function project(a,b,z) return x+(a-b)*.9,y+(a+b)*.45-z*.65 end
 M.draw(item.course,t,project)
 local a,b=M.pose(m,t)
 return project(a,b,kind=='lift' and m.elevation or 0)
end
local function beltFrame(t,m)
 local axis=math.abs(math.cos(m.angle or 0))>.5 and 1 or 2
 local direction=axis==1 and math.cos(m.angle or 0) or math.sin(m.angle or 0)
 local frame=math.floor(t*(m.speed or 65)/8*direction)%8
 local key=axis*8+frame
 if not belt[key] then
  local im=g.image.new(64,64,g.kColorClear);g.pushContext(im);tex.belt:draw(0,0)
  g.setClipRect(5,5,54,54)
  local d=frame*8
  if axis==1 then tex.belt:draw(d-64,0);tex.belt:draw(d,0)
  else tex.belt:draw(0,d-64);tex.belt:draw(0,d) end
  g.clearClipRect();g.popContext();belt[key]=im
 end
 return belt[key],key
end
local function deck(m,t,x,y,angle,mat,frame,opened,depth)
 local animated=m.kind=='trap' or m.kind=='conveyor'
 local key=tostring(frame)..(opened and ':open' or ':closed')
 local cache=m.structureCache
 if animated then
  if not m.surfaceFrames or m.surfaceWidth~=m.w or m.surfaceHeight~=m.h then m.surfaceFrames={};m.surfaceWidth=m.w;m.surfaceHeight=m.h end
  cache=m.surfaceFrames[key]
 end
 -- A long rotating bridge can project wider at 45 degrees than at rest.
 local span=m.kind=='rotor' and math.sqrt(2*(m.w*m.w+m.h*m.h)) or m.w+m.h
 local width=math.ceil(span*.9)+8
 local top=math.ceil(span*.45/2)+4
 local height=top*2+depth+6
 if not cache or cache.a~=angle or cache.w~=m.w or cache.h~=m.h or cache.frame~=frame or cache.open~=opened or cache.depth~=depth then
  local im=cache and cache.image
  if not im or cache.width~=width or cache.height~=height then im=g.image.new(width,height,g.kColorClear) end
  g.pushContext(im);g.clear(g.kColorClear)
  local pts=M.corners(m,t);local cx,cy=M.pose(m,t);local p={}
  for _,v in ipairs(pts) do p[#p+1]=width/2+(v[1]-cx-v[2]+cy)*.9;p[#p+1]=top+(v[1]-cx+v[2]-cy)*.45 end
  if opened then
   -- Empty shaft, with only the outer rim remaining at walkable height.
   g.setColor(g.kColorBlack);g.fillPolygon(table.unpack(p))
   prism(p,depth,nil,tex.beam)
   -- Hinged leaves fold below the rim, so the open hole never looks walkable.
   local fold=(frame or 6)/6
   if fold<1 then
    local function point(u,v,drop)
     return p[1]+(p[3]-p[1])*u+(p[7]-p[1])*v,p[2]+(p[4]-p[2])*u+(p[8]-p[2])*v+drop
    end
    for _,side in ipairs({0,1}) do
     local inner=side==0 and (1-fold)*.5 or 1-(1-fold)*.5
     local a,b=point(side,0,3);local c,d=point(inner,0,4+fold*20)
     local e,f=point(inner,1,4+fold*20);local h,i=point(side,1,3)
     local leaf={a,b,c,d,e,f,h,i};panel(tex.hatch,leaf);outline(leaf)
    end
   end
   g.setColor(g.kColorWhite);g.setLineWidth(3);g.drawPolygon(table.unpack(p));g.setLineWidth(1);outline(p)
  else prism(p,depth,mat,tex.beam) end
  g.popContext()
  cache={image=im,width=width,height=height,top=top,a=angle,w=m.w,h=m.h,frame=frame,open=opened,depth=depth};m.structureCache=cache
  if animated then m.surfaceFrames[key]=cache end
 end
 cache.image:draw(x-cache.width/2,y-cache.top)
end
local function rail(c,m,project)
 local dx,dy=m.toX-m.x,m.toY-m.y;local length=math.sqrt(dx*dx+dy*dy)
 if length<1 then return end
 local nx,ny=-dy/length,dx/length
 local floor=c:height(m.x,m.y)-24
 local span=math.min(m.w,m.h)*.28
 local ax,ay=project(m.x,m.y,floor)
 if m.railCache then m.railCache.image:draw(ax+m.railCache.x,ay+m.railCache.y);return end
 local faces={};local x0,y0,x1,y1=math.huge,math.huge,-math.huge,-math.huge
 for _,sign in ipairs({-1,1}) do
  local ox,oy=nx*span*sign,ny*span*sign;local p={}
  for _,v in ipairs({{m.x+ox-nx*3,m.y+oy-ny*3},{m.toX+ox-nx*3,m.toY+oy-ny*3},{m.toX+ox+nx*3,m.toY+oy+ny*3},{m.x+ox+nx*3,m.y+oy+ny*3}}) do
   local a,b=project(v[1],v[2],floor);a=a-ax;b=b-ay;p[#p+1]=a;p[#p+1]=b
   x0=math.min(x0,a);y0=math.min(y0,b);x1=math.max(x1,a);y1=math.max(y1,b+4)
  end
  faces[#faces+1]=p
 end
 x0=math.floor(x0)-2;y0=math.floor(y0)-2
 local im=g.image.new(math.ceil(x1-x0)+3,math.ceil(y1-y0)+3,g.kColorClear)
 g.pushContext(im)
 for _,p in ipairs(faces) do for i=1,8,2 do p[i]=p[i]-x0;p[i+1]=p[i+1]-y0 end;prism(p,4,tex.rail,tex.beam) end
 g.popContext();m.railCache={image=im,x=x0,y=y0};im:draw(ax+x0,ay+y0)
end
local wallSets={}
local function wallFrame(m,pixels)
 local key=m.w..':'..m.h
 local frames=wallSets[key];if not frames then frames={};wallSets[key]=frames end
 if frames[pixels] then return frames[pixels] end
 local width=math.ceil((m.w+m.h)*.9)+8
 local top=math.ceil((m.w+m.h)*.225)+pixels+4
 local height=top+math.ceil((m.w+m.h)*.225)+8
 local im=g.image.new(width,height,g.kColorClear)
 g.pushContext(im)
 local p={}
 for _,v in ipairs({{-1,-1},{1,-1},{1,1},{-1,1}}) do
  local a,b=v[1]*m.w/2,v[2]*m.h/2;p[#p+1]=width/2+(a-b)*.9;p[#p+1]=top+(a+b)*.45-pixels
 end
 prism(p,math.max(3,pixels),tex.rail,tex.gate)
 g.popContext();local result={image=im,width=width,top=top};frames[pixels]=result;return result
end
local function wall(c,m,t,project,cx,cy)
 local h=c:height(cx,cy);local rise=m.kind=='gate' and M.wallHeight(m,t) or m.wallHeight or 80
 -- Only raster height is rounded to the nearest pixel; collision uses exact rise.
 local frame=wallFrame(m,math.floor(rise*.65+.5))
 local x,y=project(cx,cy,h)
 frame.image:draw(x-frame.width/2,y-frame.top)
 gearFrame(rise*4):draw(x-14,y-6)
end
function A.dial(x,y,angle)
 base('socket',x,y)
 MachineArt.handle(x,y-2,angle)
end
function M.draw(c,t,project)
 for _,m in ipairs(c.mechanisms or {}) do
  local cx,cy,a=M.pose(m,t);local h=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(cx,cy)
  local x,y=project(cx,cy,h);local extent=(m.w+m.h)*.64+65
  if x+extent>=-32 and x-extent<=432 and y+extent>=0 and y-extent-(m.wallHeight or 0)*.65<=240 then
   local kind=m.kind
   if kind=='gate' or kind=='sweeper' then
    wall(c,m,t,project,cx,cy)
   elseif kind=='fan' then
    base('small',x,y)
    A.fanImage=A.fanImage or g.image.new('machine-fan');A.fanImage:draw(x-26,y-43);MachineArt.fan(m,t,x,y)
   elseif kind=='bumper' then
    base('small',x,y)
    MachineArt.bumper(m,t,x,y)
   else
    if kind=='ferry' then
     rail(c,m,project)
     parts.bogie:draw(x-30,y+3)
     -- A housed axle turns with real carriage displacement, not a floating cog.
     if m.manual then gearFrame(((cx-m.x)+(cy-m.y))*3):draw(x+10,y+6) end
    elseif kind=='lift' then
     local _,foot=project(cx,cy,m.minHeight-48)
     parts.pillar:drawScaled(x-24,y+5,1,math.max(24,foot-y)/72)
     gearFrame((m.elevation or 0)*4):draw(x+13,y+4)
    elseif kind=='rotor' and not m.retract then
     base('bearing',x,y)
    elseif m.retract then
     base('rail',x,y)
    end
    local mat,frame=tex.deck,0
    local opened=kind=='trap' and M.open(m,t)
    if kind=='trap' then
     mat=tex.hatch
     if opened then
      local age=(t+(m.phase or 0))%m.period
      local remaining=m.period*(m.openFor or .45)-age
      frame=math.floor(math.min(1,age/.25,remaining/.25)*6+.5)
     end
    elseif kind=='conveyor' then mat,frame=beltFrame(t,m)
    elseif kind=='jet' then mat=tex.rail
    elseif kind=='magnet' then mat=tex.bearing
    elseif m.retract then mat=tex.rail end
    deck(m,t,x,y,a,mat,frame,opened,12)
    if kind=='trap' then
     -- Mechanism remains visible in its side pockets while the shaft is open.
     gearFrame(opened and t*100 or M.warning(m,t) and t*70 or 0):draw(x-14,y+8)
     if M.warning(m,t) then g.setColor(g.kColorWhite);g.fillCircleAtPoint(x,y+23,math.floor(t*8)%2+1) end
    elseif kind=='conveyor' then
     MachineArt.sprite('roller',x,y+18)
    elseif kind=='magnet' then
     MachineArt.sprite('magnet',x,y+4);g.setColor(g.kColorBlack)
     for i=1,2 do local r=18+(t*12+i*14)%30;g.drawArc(x,y-10,r,220,320) end
    elseif kind=='jet' then
     local active=(t+(m.phase or 0))%m.period<m.period*.4
     for i=-1,1 do
      local wx=cx+i*m.w/4;local px,py=project(wx,cy,h)
      MachineArt.sprite('nozzle',px,py+3)
      if active then
       local dx,dy=math.cos(m.angle or 0),math.sin(m.angle or 0);g.setColor(g.kColorBlack)
       for k=1,3 do local d=16+(t*48+k*13)%42;g.drawArc(px+(dx-dy)*.9*d,py+(dx+dy)*.45*d-17-k*2,3+k,210,345) end
      end
     end
    end
   end
  end
 end
end
local preparedCourse
function A.prepare(c)
 if preparedCourse and preparedCourse~=c then
  for _,m in ipairs(preparedCourse.mechanisms or {}) do m.structureCache=nil;m.railCache=nil;m.surfaceFrames=nil end
 end
 if preparedCourse~=c then wallSets={} end
 preparedCourse=c
 for i=0,15 do gearFrame(i*22.5) end
 local scratch=g.image.new(400,240,g.kColorClear)
 local view=setmetatable({mechanisms={}},{__index=c})
 for i,m in ipairs(c.mechanisms or {}) do
  view.mechanisms[1]=m
  local cx,cy=M.pose(m,0);local z=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(cx,cy)
  g.pushContext(scratch);g.clear(g.kColorClear)
  M.draw(view,0,function(a,b,h) return 200+(a-cx-b+cy)*.9,100+(a-cx+b-cy)*.45-(h-z)*.65 end)
  g.popContext()
  local progress=.66+.07*i/#c.mechanisms
  if m.kind=='gate' or m.kind=='sweeper' then
   local maximum=math.floor((m.wallHeight or 80)*.65+.5)
   for pixels=m.kind=='sweeper' and maximum or 0,maximum do
    wallFrame(m,pixels)
    if pixels%4==0 then Loading.checkpoint(progress,'WINDING THE MACHINES') end
   end
  elseif m.kind=='trap' or m.kind=='conveyor' then
   if m.kind=='trap' then
    g.pushContext(scratch);deck(m,0,200,100,0,tex.hatch,0,false,12);g.popContext()
   end
   for frame=0,m.kind=='trap' and 6 or 7 do
    g.pushContext(scratch);g.clear(g.kColorClear)
    if m.kind=='trap' then deck(m,0,200,100,0,tex.hatch,frame,true,12)
    else local mat,key=beltFrame((frame+.1)*8/(m.speed or 65),m);deck(m,0,200,100,0,mat,key,false,12) end
    g.popContext()
    Loading.checkpoint(progress,'WINDING THE MACHINES')
   end
  end
  if i%4==0 then Loading.checkpoint(progress,'WINDING THE MACHINES') end
 end
end
