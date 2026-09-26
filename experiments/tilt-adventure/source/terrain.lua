Terrain={}
local T=Terrain
local size=128
function T.new(course,render)
 local cache={buckets={},images={},render=render,tick=0,misses=0,count=0}
 -- Index static geometry once; images are created only around the camera.
 for _,tile in ipairs(course.tiles) do
  local minX,minY,maxX,maxY=1e9,1e9,-1e9,-1e9
  for dx=0,1 do for dy=0,1 do
   local x,y=(tile.x+dx)*32,(tile.y+dy)*32
   local sx,sy=200+(x-y)*0.9,124+(x+y)*0.45-course:height(x,y)*0.65
   minX,minY=math.min(minX,sx),math.min(minY,sy);maxX,maxY=math.max(maxX,sx),math.max(maxY,sy+12)
  end end
  for x=math.floor((minX-1)/size),math.floor((maxX+1)/size) do for y=math.floor((minY-1)/size),math.floor((maxY+1)/size) do
   local key=x..','..y;local bucket=cache.buckets[key]
   if not bucket then bucket={x=x,y=y,tiles={}};cache.buckets[key]=bucket end
   bucket.tiles[#bucket.tiles+1]=tile
  end end
 end
 return cache
end
local function ensure(c,x,y)
 local key=x..','..y;local entry=c.images[key]
 if entry then entry.used=c.tick;return entry end
 local bucket=c.buckets[key];if not bucket then return nil end
 local image=playdate.graphics.image.new(size,size,playdate.graphics.kColorClear)
 c.render(image,bucket.tiles,x*size,y*size)
 entry={image=image,used=c.tick,x=x*size,y=y*size};c.images[key]=entry;c.count=c.count+1;return entry
end
function T.warm(c,x,y)
 for i=math.floor(x/size)-1,math.floor((x+400)/size)+1 do
  for j=math.floor((y+44)/size)-1,math.floor((y+204)/size)+1 do ensure(c,i,j) end
 end
end
function T.draw(c,x,y)
 c.tick=c.tick+1
 local x0,x1=math.floor(x/size),math.floor((x+400)/size)
 local y0,y1=math.floor((y+44)/size),math.floor((y+204)/size)
 local window=c.window
 if not window or window.x0~=x0 or window.x1~=x1 or window.y0~=y0 or window.y1~=y1 then
  window={x0=x0,x1=x1,y0=y0,y1=y1,visible={},retained={},pending={},next=1};c.window=window
  for i=x0,x1 do for j=y0,y1 do
   local key=i..','..j
   if c.buckets[key] and not c.images[key] then c.misses=c.misses+1 end
   local entry=ensure(c,i,j)
   if entry then window.visible[#window.visible+1]=entry end
  end end
  for i=x0-1,x1+1 do for j=y0-1,y1+1 do
   local key=i..','..j;local entry=c.images[key]
   if entry then window.retained[#window.retained+1]=entry
   elseif c.buckets[key] then window.pending[#window.pending+1]=c.buckets[key] end
  end end
 end
 -- Camera movement within the same chunk window needs no string keys or lookups.
 for _,entry in ipairs(window.visible) do entry.image:draw(entry.x-x,entry.y-y) end
 for _,entry in ipairs(window.retained) do entry.used=c.tick end
 local pending=window.pending[window.next]
 if pending then
  local entry=ensure(c,pending.x,pending.y)
  window.retained[#window.retained+1]=entry;window.next=window.next+1
 end
 -- Bound retained image memory, retaining the visible area and its margin.
 if c.count>40 then
  for key,entry in pairs(c.images) do
   if entry.used<c.tick-30 then c.images[key]=nil;c.count=c.count-1 end
  end
 end
end
