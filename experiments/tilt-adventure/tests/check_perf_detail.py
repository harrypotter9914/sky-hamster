"""Prepared static structures must not allocate new raster images while moving."""
from check_depth import lua

lua.execute('''
local heightChecks=0
for _,c in ipairs(Courses) do
 local reference=HeightIndex.reference[c]
 local function check(x,y)
  local a,b,d=reference(c,x,y);local e,f,h=c:height(x,y)
  assert(a==e and b==f and d==h,'indexed height changed profile or lip')
  heightChecks=heightChecks+1
 end
 for _,tile in ipairs(c.tiles) do
  for _,dx in ipairs({0,.001,16,31.999,32}) do
   for _,dy in ipairs({0,16,32}) do check(tile.x*32+dx,tile.y*32+dy) end
  end
 end
 for _,p in ipairs(c.profile) do for _,dx in ipairs({-.001,0,.001}) do check(p[1]+dx,-1000) end end
 check(-10000,0);check(100000,0)
end
print('PASS: '..heightChecks..' indexed height samples exactly match original slopes, step boundaries and lift lips')
selectReady(20);put('lesson',false);put('title',false)
local c=Courses[20]
local lift=c.mechanisms[1]
local originalElevation=lift.elevation
assert(Mechanisms.floor(c,lift.x,lift.y,0)==lift.elevation)
lift.elevation=lift.elevation+7
assert(Mechanisms.floor(c,lift.x,lift.y,0)==lift.elevation,'floor memo froze lift elevation')
lift.elevation=originalElevation
Dock.reset(c)
assert(Mechanisms.floor(c,lift.x,lift.y,0)==lift.minHeight,'floor memo survived a reset')
print('PASS: repeated floor queries retain live lift elevation and reset invalidation')
for _,m in ipairs(c.mechanisms) do assert(m.postCache,'lift supports were not prepared') end
local make=playdate.graphics.image.new
playdate.graphics.image.new=function() error('unexpected lift support image allocation during play') end
for i=0,120 do
 for _,m in ipairs(c.mechanisms) do m.elevation=m.minHeight+(m.maxHeight-m.minHeight)*i/120 end
 Structures.drawUnder(c,i/30,function(x,y,z)return 200+(x-y)*.9,124+(x+y)*.45-z*.65 end)
end
playdate.graphics.image.new=make
selectReady(24)
for _,m in ipairs(c.mechanisms) do assert(m.postCache==nil,'old lift support bitmap retained after course change') end
assert(MachineArt.fansReady)
playdate.graphics.image.new=function() error('unexpected fan heading image allocation during play') end
for i=0,143 do MachineArt.fan({angle=i*math.pi/72},i/30,200,124) end
playdate.graphics.image.new=make
print('PASS: prepared lift supports and every fan heading allocate no new images during motion; old course supports released')
local drawn={}
local function render(image,tiles,ox,oy)
 image.draw=function(self,x,y)drawn[#drawn+1]=ox..','..oy..':'..x..','..y end
end
local checks,maximum=0,0
for _,course in ipairs(Courses) do
 local streamed=Terrain.new(course,render);local prepared=Terrain.new(course,render)
 Terrain.prepare(prepared,0,0);assert(prepared.keepAll and prepared.count<=64)
 maximum=math.max(maximum,prepared.count)
 for _,tile in ipairs(course.tiles) do
  local x,y=tile.x*32+16,tile.y*32+16
  local cx,cy=(x-y)*.9,(x+y)*.45-course:height(x,y)*.65
  drawn={};Terrain.draw(streamed,cx,cy);local expected=table.concat(drawn,';')
  drawn={};Terrain.draw(prepared,cx,cy)
  assert(table.concat(drawn,';')==expected,'prepared terrain changed viewport/order/position')
  assert(prepared.misses==0,'prepared map created a visible chunk while moving')
  checks=checks+1
 end
end
local large={buckets={},images={},render=render,tick=0,misses=0,count=0}
for i=0,64 do large.buckets[i..',0']={x=i,y=0,tiles={}} end
Terrain.prepare(large,0,0);assert(not large.keepAll and large.count<64,'large future map must use bounded streaming')
print('PASS: '..checks..' prepared terrain views match streaming; zero visible misses; maximum '..maximum..' chunks; larger-map fallback retained')
selectReady(33);put('lesson',false);put('title',false);frame()
local old=Courses[33];local tiles=#old.tiles
assert(old.physicsCells and old.renderIndex and old.occlusionCache)
selectReady(1)
assert(not old.physicsCells and not old.physicsView and not old.floorMemo and not old.renderIndex and not old.occlusionCache and not old.occlusionBuckets)
for _,tile in ipairs(old.tiles) do assert(not tile.surface and not tile.renderCache) end
assert(#old.tiles==tiles and old.lookup and old.checkpoints,'course data lost during cache cleanup')
selectReady(33);put('lesson',false);frame()
assert(old.physicsCells and old.renderIndex and old.occlusionCache,'re-entered course failed to rebuild')
print('PASS: leaving releases derived course caches; returning rebuilds them without losing level data')
''')
