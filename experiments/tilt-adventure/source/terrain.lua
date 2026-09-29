Terrain={}
local T=Terrain
local size=256
function T.new(course,render)
 local cache={buckets={},images={},render=render,tick=0,misses=0,count=0,preparedLimit=course.preparedChunkLimit or 64,stream=course.blueprint~=nil,jobs={}}
 -- Index static geometry once; images are created only around the camera.
 for index,tile in ipairs(course.tiles) do
  local height,slope,sy=course:height(tile.x*32+16,tile.y*32+16)
  -- Exact affine half-extents replace four corner projections per tile. The
  -- 0.01px margin makes floating-point boundary rounding conservative.
  local cx=200+(tile.x-tile.y)*32*.9
  local cy=124+(tile.x+tile.y+1)*32*.45-height*.65
  local ey=(math.abs(.45-.65*slope)+math.abs(.45-.65*(sy or 0)))*16
  local depth=course.terrainDepth and course.terrainDepth[tile.x..','..tile.y]
  local minX,maxX,minY,maxY=cx-28.8,cx+28.8,cy-ey,cy+ey+(depth and depth*.65 or 12)
  for x=math.floor((minX-1.01)/size),math.floor((maxX+1.01)/size) do for y=math.floor((minY-1.01)/size),math.floor((maxY+1.01)/size) do
   local key=x..','..y;local bucket=cache.buckets[key]
   if not bucket then bucket={x=x,y=y,tiles={}};cache.buckets[key]=bucket end
   bucket.tiles[#bucket.tiles+1]=tile
  end end
  if Loading and index%32==0 then Loading.checkpoint(.76+.09*index/#course.tiles,"FINDING THE WAY") end
 end
 return cache
end
local function ensure(c,x,y)
 local key=x..','..y;local entry=c.images[key]
 if entry then entry.used=c.tick;return entry end
 local bucket=c.buckets[key];if not bucket then return nil end
 local job=c.jobs and c.jobs[key]
 local image=job and job.image or playdate.graphics.image.new(size,size,playdate.graphics.kColorClear)
 c.render(image,bucket.tiles,x*size,y*size,job and job.next or 1,#bucket.tiles)
 if c.jobs then c.jobs[key]=nil end
 entry={image=image,used=c.tick,x=x*size,y=y*size};c.images[key]=entry;c.count=c.count+1;return entry
end
function T.warm(c,x,y)
 for i=math.floor(x/size)-1,math.floor((x+400)/size)+1 do
  for j=math.floor((y+44)/size)-1,math.floor((y+204)/size)+1 do ensure(c,i,j);if Loading then Loading.checkpoint(.9,"ALMOST THERE") end end
 end
end
function T.prepare(c,x,y)
 if c.stream then
  -- Only imagery streams; the entire collision map already exists. Two chunks
  -- of margin cover high-speed travel, with a synchronous visual fallback on
  -- teleports so an unprepared image can never become a hole in the track.
  for i=math.floor(x/size)-2,math.floor((x+400)/size)+2 do
   for j=math.floor((y+44)/size)-2,math.floor((y+204)/size)+2 do
    ensure(c,i,j);if Loading then Loading.checkpoint(.9,'PREPARING THE START') end
   end
  end
  return
 end
 -- Larger chunks reduce native bitmap calls. Prepare up to 1 MB of sparse
 -- monochrome image/mask data during loading, not on a moving frame.
 -- Drawing still touches only the viewport; larger future maps retain streaming.
 local count=0;for _ in pairs(c.buckets) do count=count+1 end
 if count>(c.preparedLimit or 64) then T.warm(c,x,y);return end
 c.keepAll=true
 local ready=0
 for _,bucket in pairs(c.buckets) do
  ensure(c,bucket.x,bucket.y);ready=ready+1
  if Loading then Loading.checkpoint(.9+.09*ready/math.max(1,count),'PACKING THE ROAD') end
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
  local margin=c.stream and 2 or 1
  for i=x0-margin,x1+margin do for j=y0-margin,y1+margin do
   local key=i..','..j;local entry=c.images[key]
   if entry then window.retained[#window.retained+1]=entry
   elseif c.buckets[key] then window.pending[#window.pending+1]=c.buckets[key] end
  end end
 end
 -- Camera movement within the same chunk window needs no string keys or lookups.
 for _,entry in ipairs(window.visible) do entry.image:draw(entry.x-x,entry.y-y) end
 if c.keepAll then return end -- Prepared maps have no eviction/prefetch bookkeeping.
 for _,entry in ipairs(window.retained) do entry.used=c.tick end
 local pending=window.pending[window.next]
 if pending and c.stream then
  local started=playdate.getCurrentTimeMilliseconds()
  for batch=1,8 do
   pending=window.pending[window.next];if not pending then break end
   local key=pending.x..','..pending.y
   local job=c.jobs[key]
   if not job then job={image=playdate.graphics.image.new(size,size,playdate.graphics.kColorClear),next=1};c.jobs[key]=job end
   local last=math.min(#pending.tiles,job.next+3)
   c.render(job.image,pending.tiles,pending.x*size,pending.y*size,job.next,last);job.next=last+1
   if job.next>#pending.tiles then
    local entry={image=job.image,used=c.tick,x=pending.x*size,y=pending.y*size}
    c.images[key]=entry;c.jobs[key]=nil;c.count=c.count+1
    window.retained[#window.retained+1]=entry;window.next=window.next+1
   end
   if playdate.getCurrentTimeMilliseconds()-started>=2 then break end
  end
 elseif pending then
  local entry=ensure(c,pending.x,pending.y)
  window.retained[#window.retained+1]=entry;window.next=window.next+1
 end
 -- Bound retained image memory, retaining the visible area and its margin.
 if not c.keepAll and c.count>40 then
  for key,entry in pairs(c.images) do
   if entry.used<c.tick-30 then c.images[key]=nil;c.count=c.count-1 end
  end
 end
 if c.stream then
  for key,job in pairs(c.jobs) do
   local b=c.buckets[key]
   if b.x<x0-2 or b.x>x1+2 or b.y<y0-2 or b.y>y1+2 then c.jobs[key]=nil end
  end
 end
end
