from pathlib import Path
from check_physics_index import lua

lua.execute('NewTerrain=Terrain')
lua.execute((Path(__file__).parent / 'fixtures/terrain-v040.lua').read_text())
lua.execute('OldTerrain=Terrain;Terrain=NewTerrain')
lua.execute('''
local image=playdate.graphics.image
local original=image.new
local calls={}
image.new=function()
 local im={}
 function im:draw(x,y) calls[#calls+1]=self.key..':'..string.format('%.4f/%.4f',x,y) end
 return im
end
local render=function(im,tiles,x,y) im.key=x..'/'..y end
for _,n in ipairs({1,21,30,44}) do
 local c=Courses[n];local a,b=NewTerrain.new(c,render),OldTerrain.new(c,render)
 NewTerrain.warm(a,0,0);OldTerrain.warm(b,0,0)
 for frame=1,600 do
  local tile=c.tiles[1+(math.floor(frame/7)*17)%#c.tiles]
  local x=(tile.x-tile.y)*28.8+(frame%7)*2.31
  local y=(tile.x+tile.y)*14.4-c:height(tile.x*32,tile.y*32)*.65
  calls={};NewTerrain.draw(a,x,y);local expected=table.concat(calls,'|')
  calls={};OldTerrain.draw(b,x,y);assert(expected==table.concat(calls,'|'),'terrain draw mismatch at '..n..' frame '..frame)
  assert(a.misses==b.misses and a.count==b.count,'prefetch/eviction changed')
 end
end
image.new=original
print('PASS: 2400 terrain frames preserve drawn chunks, order, subpixel positions, cache misses and eviction counts')

for _,c in ipairs(Courses) do
 for ti=1,#c.tiles,7 do
  local tile=c.tiles[ti];local px,py=tile.x*32+16,tile.y*32+16
  local cx,cy=(px-py)*.9,(px+py)*.45-c:height(px,py)*.65
  local project=function(x,y,h) return 200+(x-y)*.9-cx,124+(x+y)*.45-(h or 0)*.65-cy end
  local view=RenderIndex.view(c,project);local included={}
  for _,m in ipairs(view.mechanisms) do included[m]=true end
  for _,m in ipairs(c.mechanisms or {}) do for _,t in ipairs({0,1.7,4.4,7.9}) do
   local x,y=Mechanisms.pose(m,t);local sx,sy=project(x,y,c:height(x,y))
   local ex=(m.w+m.h)*.64+40
   if sx+ex>=-32 and sx-ex<=432 and sy+ex>=12 and sy-ex-(m.wallHeight or 80)*.65-30<=236 then
    assert(included[m],'swept render bounds omitted '..m.kind..' in '..c.name)
   end
  end end
 end
end
print('PASS: render index includes original visible mechanisms across 44 courses, camera cells and movement phases')
for _,c in ipairs(Courses) do for _,m in ipairs(c.mechanisms or {}) do
 for _,t in ipairs({0,.01,1.7,4.4,7.9,19.7}) do
  local x,y,a=Pose.reference(m,t)
  for _,cached in ipairs({false,true}) do
   if cached then Pose.begin(t) end
   for i=1,3 do local px,py,pa=Mechanisms.pose(m,t);assert(px==x and py==y and pa==a,'pose changed') end
   Pose.finish()
  end
 end
end end
print('PASS: direct and render-cached poses equal the original wrapper chain exactly')
for _,c in ipairs(Courses) do
 Dock.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='lift' then m.elevation=(m.minHeight+m.maxHeight)/2 end
  for _,t in ipairs({0,2,6}) do
   local x,y=Mechanisms.pose(m,t)
   for dx=-48,48,16 do for dy=-48,48,16 do
    assert(Mechanisms.floor(c,x+dx,y+dy,t)==PhysicsIndex.reference.floor(c,x+dx,y+dy,t),'floor query changed')
   end end
  end
 end
end
print('PASS: lift-only height queries equal full support-based heights across machinery, boundaries and raised lifts')
''')
