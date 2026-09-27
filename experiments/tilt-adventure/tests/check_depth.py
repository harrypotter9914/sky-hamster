"""Regression for near-bank compositing and one solid cannon/flight coordinate system."""
from check_joinery import lua

lua.execute('''
local checked,kinds=0,{}
for _,c in ipairs(Courses) do
 DepthOrder.prepare(c);Dock.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  kinds[m.retract and 'extend' or m.kind]=true
  if m.joinSpan or m.kind=='ferry' then
   for _,t in ipairs({0,3,4,5,7}) do
    local x0,x1,y0,y1=DepthOrder.bounds(m,t)
    -- Every axis-separated near-bank tile must be composited after the skirt.
    for _,tile in ipairs(c.tiles) do
     local a,b=tile.x*32,tile.y*32
     if a>=x1-.00001 and a<x1+32 and b+32>y0 and b<y1 then
      assert(DepthOrder.inFront(m,t,tile),'near bank not in front')
      local found=false;for _,candidate in ipairs(m.roadFrontCandidates) do if candidate==tile then found=true end end
      assert(found,'near bank missing from candidate index');checked=checked+1
     end
     if a+32<=x0+.00001 and b+32<=y1 then assert(not DepthOrder.inFront(m,t,tile),'far bank would erase deck') end
    end
   end
  elseif m.kind=='lift' then
   assert(m.landingPosts and #m.landingPosts==2)
   for _,post in ipairs(m.landingPosts) do assert(not Mechanisms.contains(m,post[1],post[2],0),'support post intersects lift travel') end
   for _,tile in ipairs(c.tiles) do assert(not c.terrainDepth or not c.terrainDepth[tile.x..','..tile.y],'unexpected full wall remains') end
  end
 end
end
local covers=0
for _,c in ipairs(Courses) do
 DepthOrder.prepare(c);Dock.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  for i=0,20 do
   local t=i*.4;local cx,cy=Mechanisms.pose(m,t)
   local h=m.kind=='lift' and m.elevation or c:height(cx,cy)
   local sx,sy=(cx-cy)*.9,(cx+cy)*.45-h*.65;local ex=(m.w+m.h)*.65+45
   local expected={}
   for _,tile in ipairs(m.roadFrontCandidates) do
    if DepthOrder.inFront(m,t,tile) and math.abs(tile.depthX-sx)<ex and tile.depthY-24<sy+ex*.5 and tile.depthY+36>sy-ex*.5 then expected[#expected+1]=tile end
   end
   local actual=DepthOrder.cover(c,m,t).tiles
   assert(#actual==#expected,'cover size changed')
   for j,tile in ipairs(expected) do assert(actual[j]==tile,'cover painter order changed') end
   covers=covers+1
  end
 end
end
print('PASS: '..covers..' cached terrain covers match uncached tile selection and painter order')
local angles=0
for angle=-60,60 do
 local a=math.rad(angle);local p={x=120,y=80,kind='cannon',angle=a}
 local c={height=function()return 96 end,pads={p}}
 local x,y,z=Dock.muzzle(c,p)
 local ax,ay,az=Dock.trajectory(c,p,0)
 assert(x==ax and y==ay and z==az,'arc does not start at mouth')
 Dock.active=p
 local shot=Dock.update(c,p.x,p.y,0,0,false,0,true,false)
 assert(math.abs(shot.x-x)<1e-8 and math.abs(shot.y-y)<1e-8 and math.abs(shot.z+CannonModel.ballCenter-z)<1e-8,'ball centre does not exit mouth')
 -- Offset flight preserves the former ballistic landing, rather than moving targets.
 for i=0,20 do
  local t=i*.04;local total=t+CannonModel.exitTime
  local tx,ty,tz=Dock.trajectory(c,p,t)
  assert(math.abs(tx-(p.x+210*math.cos(a)*total))<1e-7)
  assert(math.abs(ty-(p.y+210*math.sin(a)*total))<1e-7)
  assert(math.abs(tz-(96+CannonModel.ballCenter+150*total-150*total*total))<1e-7)
 end
 angles=angles+1
end
-- Foreshortening is geometric: forward-facing projected barrel is much shorter.
local function projectedLength(a)
 local x,y=CannonModel.direction(a);return math.sqrt(x*x+y*y)
end
assert(projectedLength(math.pi/4)<projectedLength(-math.pi/4)*.35)
local count=0;for _ in pairs(kinds) do count=count+1 end
print('PASS: '..checked..' near-bank samples, '..count..' mechanism types indexed; open lift supports; '..angles..' exact muzzle/trajectory/spawn and preserved landing checks; cannon foreshortening')
''')
