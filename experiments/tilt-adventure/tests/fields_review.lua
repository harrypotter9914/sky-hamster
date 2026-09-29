import 'game'
local g=playdate.graphics;local done=false;local files={}
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext()
 local name='fields14-'..name..'.gif';playdate.datastore.writeImage(im,name);files[#files+1]=name
end
local function run()
 for _,id in ipairs({'crosswind','wind-dial','magnet-school','homeward-voyage'}) do
  local n=Courses.indexById[id];Review.select(n);Tilt.calibrating=false;Tilt.ready=true;local c=Courses[n]
  local count=0
  for i,m in ipairs(c.mechanisms or {}) do if m.kind=='fan' or m.kind=='magnet' then
   count=count+1
   for _,a in ipairs({0,math.pi/2,math.pi}) do
    if m.kind=='fan' then m.angle=a end
    Review.animate(2.5);Review.place(m.region and m.region[1] or m.x+64,m.region and m.region[2] or (m.y>80 and m.y-80 or m.y+80));Dock.active=nil
    export(n..'-'..i..'-'..math.floor(a*100),Review.render)
    if m.kind=='magnet' then break end
   end
   if m.assistAngle then
    Review.place(m.x-48,80);Dock.active=nil;for _,p in ipairs(c.pads) do if p.target==m then Dock.active=p;break end end;export(n..'-dial',Review.render);Dock.active=nil
   end
  end end
  UI.mapSection=nil;export(n..'-map',function()UI.map(c,c.start[1],c.start[2],0)end)
 end
 for _,key in ipairs({'fan','windcontrol','magnet'}) do for _,time in ipairs({0,1,2,3,4.5}) do export('guide-'..key..'-'..time,function()UI.lesson(key,time)end) end end
 playdate.datastore.write({complete=true,count=#files,files=files},'fields-review-v0.12.4')
 print('PASS: '..#files..' field and uphill wind native views')
end
function playdate.update()
 if done then return end;done=true;local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err)},'fields-review-v0.12.4');print(err)end
end
