"""360-degree active spring response and foreground-mask regression."""
from check_perf_detail import lua
lua.execute('''
local hits=0
for _,c in ipairs(Courses) do
 for _,m in ipairs(c.mechanisms or {}) do if m.kind=='bumper' then
  for angle=0,355,5 do for _,speed in ipairs({.1,5,60,200}) do for _,graze in ipairs({0,.995}) do
   local a=math.rad(angle);local nx,ny=math.cos(a),math.sin(a)
   local inward=math.sqrt(1-graze*graze)
   local vx,vy=(-nx*inward-ny*graze)*speed,(-ny*inward+nx*graze)*speed
   local x,y,ox,oy,hit=Mechanisms.collide(c,m.x+nx*26.9,m.y+ny*26.9,vx,vy,0,100+hits,.001)
   assert(hit,'missed contact '..angle)
   assert(ox*nx+oy*ny>=89.999,'weak radial rebound '..angle)
   assert(math.abs(ox*ny-oy*nx)<.0001,'spring kept sideways glancing drift')
   assert((x-m.x)^2+(y-m.y)^2>27^2,'not separated')
   local at=m.hitAt
   local xx,yy,ux,uy=Mechanisms.collide(c,x,y,ox,oy,0,101+hits,.001)
   assert(ux==ox and uy==oy and at==m.hitAt,'outgoing ball retriggered')
   hits=hits+1
  end end end
 end end
end
local c=Courses[14];local m=c.mechanisms[1]
local x,y,vx,vy=Mechanisms.collide(c,m.x,m.y,0,100,0,0,.001)
assert(y<m.y and vy<0 and math.abs(vx)<.001,'center fallback ignores incoming direction')
local _,_,vx2,vy2,hit=Mechanisms.collide(c,m.x-26,m.y,100,0,35,0,.001)
assert(not hit and vx2==100 and vy2==0,'clear jump changed')
-- Receding overlap must not turn back or synthesize a second hit.
m.hitAt=9
local _,_,ux,uy=Mechanisms.collide(c,m.x-26,m.y,-80,0,0,10,.001)
assert(ux==-80 and uy==0 and m.hitAt==9)
-- Deck skirts have the same twelve-pixel thickness as the rendered side face.
local deck={kind='ferry',x=0,y=0,toX=0,toY=0,w=64,h=64,period=8}
local fixture={profile={{0,0}},tiles={},mechanisms={deck},height=function() return 0 end}
local boxes=Spatial.occluders(fixture,0,function(x,y,z)return (x-y)*.9,(x+y)*.45-z*.65 end,-100,-100,200,200,-20)
assert(#boxes==1 and math.abs(boxes[1].bottom+Spatial.thickness)<.0001,'paper-thin moving deck mask')
-- The coarse screen bound must include the skirt, even below a rotated deck.
deck.kind='rotor';deck.angle=math.pi/4;deck.w=96;deck.h=16
local narrow=Spatial.occluders(fixture,0,function(x,y,z)return (x-y)*.9,(x+y)*.45-z*.65 end,-2,40,4,2,-30)
assert(#narrow==1,'rotated deck skirt rejected before precise overlap check')
local im={getSize=function()return 44,44 end}
PropOcclusion.begin(-20,-20,0,-14,-26)
PropOcclusion.add(im,-22,-36,0,0,36,36,0,0,55)
assert(PropOcclusion.pending(),'rear spring missing')
PropOcclusion.finish()
PropOcclusion.begin(40,40,0,-14,-26)
PropOcclusion.add(im,-22,-36,0,0,36,36,0,0,55)
assert(not PropOcclusion.pending(),'foreground ball hidden')
PropOcclusion.finish()
PropOcclusion.begin(-20,-20,60,-14,-26)
PropOcclusion.add(im,-22,-36,0,0,36,36,0,0,55)
assert(not PropOcclusion.pending(),'high airborne ball hidden')
PropOcclusion.finish()
print('PASS: '..hits..' spring hits across every campaign spring, 72 angles, slow/fast/head-on/grazing; outgoing and jump clearance; solid deck skirts; depth and height rejection')
local g=playdate.graphics
local fill,new=g.fillPolygon,g.image.new
local polygons,images=0,0
g.fillPolygon=function(...) polygons=polygons+1;return fill(...) end
g.image.new=function(...) images=images+1;return new(...) end
local sprite={getSize=function()return 44,44 end,draw=function()end}
local project=function(x,y,z)return (x-y)*.9,(x+y)*.45-z*.65 end
for i=1,100 do
 PropOcclusion.begin(-5,-5,0,-14,-26)
 PropOcclusion.add(sprite,-22,-36,0,0,36,36,0,0,55)
 PropOcclusion.apply(project);PropOcclusion.finish()
end
assert(polygons==1 and images==0,'stationary prop rebuilt or allocated every frame')
PropOcclusion.begin(-6,-5,0,-14,-26)
PropOcclusion.add(sprite,-22,-36,0,0,36,36,0,0,55)
PropOcclusion.apply(project);PropOcclusion.finish()
assert(polygons==2,'relative depth change reused stale mask')
local changedFrame={getSize=sprite.getSize,draw=sprite.draw}
PropOcclusion.begin(-6,-5,0,-14,-26)
PropOcclusion.add(changedFrame,-22,-36,0,0,36,36,0,0,55)
PropOcclusion.apply(project);PropOcclusion.finish()
assert(polygons==3,'animation frame change reused stale silhouette')
g.fillPolygon,g.image.new=fill,new
print('PASS: static masks reuse rasters without allocation; relative depth and animation changes invalidate')
''')
