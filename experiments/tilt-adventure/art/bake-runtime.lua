import 'game'
local done=false
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(function()
  local total=0;local courses={}
  for n,c in ipairs(Courses) do
   Curriculum.ensure(c);BakeRoad(c)
   local rows={};local images={}
   for _,tile in ipairs(c.tiles) do
    local s=tile.surface;local id=images[s.image]
    if not id then total=total+1;id=total;images[s.image]=id;playdate.datastore.writeImage(s.image,'bake-surface-'..id..'.gif') end
    rows[#rows+1]={tile.x,tile.y,tile.renderCache,id,s.x,s.y}
   end
   playdate.datastore.write(rows,'road-'..c.id);courses[#courses+1]=c.id
   for _,tile in ipairs(c.tiles) do tile.surface=nil;tile.renderCache=nil end
   Curriculum.release(c);collectgarbage('collect')
   print('BAKED ROAD '..n)
  end
  playdate.datastore.writeImage(CannonModel.base(),'bake-cannon-1.gif')
  for n=1,61 do playdate.datastore.writeImage(CannonModel.raster(-math.pi/3+(n-1)*math.pi/90),'bake-cannon-'..(n+1)..'.gif') end
  MachineArt.warmFanViews()
  for n=0,71 do playdate.datastore.writeImage(BakeFanFrames()[n],'bake-fan-'..(n+1)..'.gif') end
  playdate.datastore.write({complete=true,courses=courses,surfaces=total},'bake-report')
  print('BAKE COMPLETE '..total..' road sprites')
 end)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err)},'bake-report');print(err) end
end
