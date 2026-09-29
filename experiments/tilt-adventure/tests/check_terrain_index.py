"""Analytic chunk bounds must contain every former corner-projection bucket."""
from pathlib import Path
f=Path(__file__).with_name('check_tilt.py');s=f.read_text();env={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0]+"load('engine')",str(f),'exec'),env)
env['lua'].execute('''
local count=0
for _,c in ipairs(Courses) do
 Curriculum.ensure(c);local cache=Terrain.new(c,function()end);local actual={}
 for key,b in pairs(cache.buckets) do for _,tile in ipairs(b.tiles) do actual[tile]=actual[tile] or {};actual[tile][key]=true end end
 for _,tile in ipairs(c.tiles) do
  local minX,minY,maxX,maxY=1e9,1e9,-1e9,-1e9
  local height,slope,sy=c:height(tile.x*32+16,tile.y*32+16)
  for dx=0,1 do for dy=0,1 do
   local x,y=(tile.x+dx)*32,(tile.y+dy)*32
   local z=height+(dx*32-16)*slope+(dy*32-16)*(sy or 0)
   local sx,py=200+(x-y)*.9,124+(x+y)*.45-z*.65
   local depth=c.terrainDepth and c.terrainDepth[tile.x..','..tile.y]
   minX,minY=math.min(minX,sx),math.min(minY,py);maxX,maxY=math.max(maxX,sx),math.max(maxY,py+(depth and depth*.65 or 12))
  end end
  for x=math.floor((minX-1)/256),math.floor((maxX+1)/256) do for y=math.floor((minY-1)/256),math.floor((maxY+1)/256) do
   assert(actual[tile][x..','..y],'analytic bounds lost a previous chunk')
  end end
  count=count+1
 end
 Curriculum.release(c)
end
print('PASS: '..count..' terrain tiles retain every original corner-projection chunk after analytic indexing')
''')
