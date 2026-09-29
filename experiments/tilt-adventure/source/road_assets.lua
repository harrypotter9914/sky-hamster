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
 local grid={}
 for _,t in ipairs(course.tiles) do grid[t.x..','..t.y]=t end
 for i,row in ipairs(data) do
  local t=grid[row[1]..','..row[2]]
  assert(t,'stale road raster data: '..course.id)
  t.surface={image=atlas:getImage(row[3]),x=row[4],y=row[5]}
  if Loading and i%64==0 then Loading.checkpoint(.3+.35*i/#data,'UNPACKING STONE ROAD') end
 end
 return true
end
