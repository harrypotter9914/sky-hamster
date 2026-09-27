"""Real course geometry: no dock overlap, flush usable seams and visible aiming."""
from check_relative_roll import lua

lua.execute('''
local overlaps,samples,seams,lifts=0,0,0,0
local function overlapsTile(m,x,y,a,tile)
 local dx,dy=tile.x*32+16-x,tile.y*32+16-y
 local c,s=math.cos(a),math.sin(a);local ac,as=math.abs(c),math.abs(s)
 local e=.00001
 return math.abs(dx)<16+m.w/2*ac+m.h/2*as-e and math.abs(dy)<16+m.w/2*as+m.h/2*ac-e
  and math.abs(dx*c+dy*s)<m.w/2+16*(ac+as)-e and math.abs(-dx*s+dy*c)<m.h/2+16*(ac+as)-e
end
for n,course in ipairs(Courses) do
 Dock.reset(course)
 for _,m in ipairs(course.mechanisms or {}) do
  if m.kind=='ferry' or (m.kind=='rotor' and not m.retract) then
   for step=0,180 do
    local t=step/180*(m.period or 10)
    if m.manual then if m.kind=='ferry' then m.progress=step/180 else m.angle=step/180*math.pi*2 end end
    local x,y,a=Mechanisms.pose(m,t)
    for _,tile in ipairs(course.tiles) do
     assert(not overlapsTile(m,x,y,a,tile),'road overlap: course '..n..' '..m.kind..' at step '..step..' tile '..tile.x..','..tile.y)
    end
    samples=samples+1
   end
   for _,side in ipairs({0,1}) do
    if m.manual then m.progress=side;m.angle=0 end
    local t=m.kind=='ferry' and side*(m.period or 10)*.5 or 0
    local x,y,a=Mechanisms.pose(m,t)
    local edge=m.kind=='ferry' and (side==0 and x-m.w/2 or x+m.w/2) or (side==0 and m.dockLeft or m.dockRight)
    for _,oy in ipairs({-m.h/2+9,0,m.h/2-9}) do
     for _,epsilon in ipairs({-.01,0,.01}) do
      assert(Mechanisms.support(course,edge+epsilon,y+oy,t),'unsupported dock seam '..n..' '..m.kind)
      seams=seams+1
     end
    end
   end
  elseif m.kind=='lift' then
   local back=m.y-m.h/2
   for _,height in ipairs({m.minHeight,m.maxHeight}) do
    m.elevation=height
    for _,eps in ipairs({-.01,0,.01}) do
     local x,y=height==m.minHeight and m.x-m.w/2+eps or m.x,height==m.minHeight and m.y or back+eps
     assert(Mechanisms.support(course,x,y,0),'lift seam lacks support')
     assert(math.abs(Mechanisms.floor(course,x,y,0)-height)<.001,'lift seam changes height')
    end
   end
   -- A continuous supported upper route must reconnect to the existing road.
   local y=back-16
   for x=m.x,m.x+128,4 do assert(Mechanisms.support(course,x,y,0),'upper ledge disconnected') end
   lifts=lifts+1
  end
 end
end
for i=-60,60 do
 local a=math.rad(i);local dx,dy=Dock.projectedDirection(a)
 local step=.000001
 local px=(210*math.cos(a)-210*math.sin(a))*.9*step
 local py=(210*math.cos(a)+210*math.sin(a))*.45*step-CannonModel.vertical*.65*step
 assert(math.abs(dx*py-dy*px)<1e-9,'muzzle misses launch tangent')
 assert(Dock.cannonFrame(a)>=1 and Dock.cannonFrame(a)<=61)
end
assert(Dock.cannonFrame(-math.pi/3)==1 and Dock.cannonFrame(math.pi/3)==61)
print('PASS: '..samples..' moving poses without road intersections; '..seams..' flush seam samples; '..lifts..' lift side-exits; 121 muzzle/tangent samples')
''')
