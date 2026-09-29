-- Native SDK raster exports: identical artwork, prepared on the build machine.
RoadAssets={}
local atlas
function RoadAssets.apply(course)
 if Build.baking or not playdate.geometry or not playdate.datastore then return false end
 local data=playdate.datastore.read('road-cache/'..course.id)
 if not data or #data~=#course.tiles then return false end
 atlas=atlas or playdate.graphics.imagetable.new('road-cache/surfaces')
 if not atlas then return false end
 course.roadBaked=true
 -- Exported rows normally have the same deterministic tile order. Avoid a
 -- second string-keyed copy of every tile; retain lookup fallback for ties.
 local grid
 for i,row in ipairs(data) do
  local t=course.tiles[i]
  if not t or t.x~=row[1] or t.y~=row[2] then
   if not grid then
    grid={};for _,tile in ipairs(course.tiles) do grid[tile.x..','..tile.y]=tile end
   end
   t=grid[row[1]..','..row[2]]
  end
  assert(t,'stale road raster data: '..course.id)
  t.surface={image=atlas:getImage(row[3]),x=row[4],y=row[5]}
  if Loading and i%64==0 then Loading.checkpoint(.3+.35*i/#data,'UNPACKING STONE ROAD') end
 end
 return true
end
