"""Check partial chunk jobs, fast/reverse travel and checkpoint teleports."""
from pathlib import Path
fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
scope={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0]+"load('engine')",str(fixture),'exec'),scope)
scope['lua'].execute('''
local c=Courses[53];Curriculum.ensure(c)
local original=playdate.graphics.image.new
local drawn=0
playdate.graphics.image.new=function()
 return {draw=function(im)
  assert(im.finished,'partially prepared road became visible')
  drawn=drawn+1
 end}
end
local cache=Terrain.new(c,function(im,tiles,ox,oy,first,last)
 assert((im.next or 1)==first,'chunk repeated or skipped a slice')
 im.next=last+1;im.finished=last==#tiles
 -- Artificial cost ensures a background batch cannot process the whole road.
 clock=clock+(last-first+1)*.3
end)
local function camera(wx)
 return (wx-80)*.9,(wx+80)*.45-c:height(wx,80)*.65
end
Terrain.prepare(cache,camera(48))
local initial=cache.count;local maximum=cache.count
for pass=1,2 do
 local first,last,step=48,c.goal[1],8
 if pass==2 then first,last,step=c.goal[1],48,-8 end
 for wx=first,last,step do
  clock=clock+1000/30
  Terrain.draw(cache,camera(wx))
  maximum=math.max(maximum,cache.count)
 end
end
assert(cache.misses==0,'240 units/sec travel outran predictive preparation')
for _,point in ipairs(c.checkpoints) do
 clock=clock+1000/30;Terrain.draw(cache,camera(point[1]))
end
assert(cache.misses>0,'teleport did not exercise immediate completion fallback')
assert(maximum<=48 and initial<=35,'road image cache is not bounded')
playdate.graphics.image.new=original
print('PASS: 240 units/sec forward/reverse road preparation, complete visible images, checkpoint teleport fallback; initial '..initial..', peak '..maximum..' chunks, '..drawn..' complete draws')
''')
