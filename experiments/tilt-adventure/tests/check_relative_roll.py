"""Run the actual update: transport must not masquerade as surface rolling."""
from check_audio_bounds import lua

lua.execute('''
local tested={}
for n,c in ipairs(Courses) do
 for _,m in ipairs(c.mechanisms or {}) do
  if (m.kind=='ferry' or m.kind=='rotor') and not m.manual and not tested[m.kind] then
   selectReady(n);put('lesson',false);put('title',false)
   local t=(m.period or 10)*.28-(m.phase or 0)
   local cx,cy,a=Mechanisms.pose(m,t)
   local px,py=cx+8*math.cos(a),cy+8*math.sin(a)
   put('worldTime',t);put('x',px);put('y',py);put('vx',0);put('vy',0)
   put('ballHeight',Mechanisms.floor(c,px,py,t));put('airborne',false);put('rollAngle',1)
   Dock.active=nil;Dock.blocked=nil
   for i=1,8 do frame() end
   assert(get('state')=='play' and not get('airborne'),'ride fixture lost support')
   assert(math.abs(get('x')-px)+math.abs(get('y')-py)>1,'platform did not move')
   assert(math.abs(get('rollAngle')-1)<.000001,'carried ball rotated on '..m.kind)
   put('vx',25);frame()
   assert(math.abs(get('rollAngle')-1)>.01,'own motion failed to rotate ball on '..m.kind)
   tested[m.kind]=true
  end
 end
end
assert(tested.ferry and tested.rotor)
print('PASS: ferry and rotor move the ball without false rolling; motion relative to both surfaces still rolls')

local m={kind='rotor',manual=true,x=0,y=0,w=256,h=32,angle=0}
local c={mechanisms={m},height=function()return 0 end}
local project=function(x,y,z)return 200+(x-y)*.9,120+(x+y)*.45-z*.65 end
for i=0,72 do
 m.angle=i*math.pi/36;Mechanisms.draw(c,0,project)
 local image=m.structureCache
 for _,p in ipairs(Mechanisms.corners(m,0)) do
  assert(math.abs((p[1]-p[2])*.9)<image.width/2-1,'rotor clipped horizontally')
  assert(math.abs((p[1]+p[2])*.45)<image.top-1,'rotor clipped vertically')
 end
end
print('PASS: long bridge remains inside its raster bounds through 73 rotation samples')

-- The moving gate/hatch/belt must not allocate or project a new image per cycle.
local fixtures={
 {kind='gate',x=0,y=0,w=16,h=160,period=6,wallHeight=80},
 {kind='trap',x=0,y=0,w=64,h=160,period=7},
 {kind='conveyor',x=0,y=0,w=192,h=64,angle=0,speed=65}
}
local count=0
local create=playdate.graphics.image.new
playdate.graphics.image.new=function(...)count=count+1;return create(...)end
for _,m in ipairs(fixtures) do
 local c={mechanisms={m},height=function()return 0 end}
 Structures.prepare(c)
 local before=count
 for i=0,1080 do Mechanisms.draw(c,i/30,project) end
 assert(count==before,m.kind..' allocates image during animated cycles')
end
playdate.graphics.image.new=create
print('PASS: prepared gate, hatch and belt run 36-second animation cycles without new raster allocations')
''')
