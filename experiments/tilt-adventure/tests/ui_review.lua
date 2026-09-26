import 'game'
local g=playdate.graphics
local update=playdate.update
local clock=playdate.getCurrentTimeMilliseconds()
playdate.getCurrentTimeMilliseconds=function() return clock end
local select=Review.select
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext();playdate.datastore.writeImage(im,name..'.gif')
end
local function world(n,x,y)
 select(n);Tilt.calibrating=false;Tilt.ready=true
 if x then Review.place(x,y) end
 Review.render()
end
local done=false
function playdate.update()
 if not done then
  clock=clock+100;UI.title(1);clock=clock+100
  export('v12-title',function() UI.title(1) end)
  export('v12-settings',function() UI.settings(3,true,false,true) end)
  export('v12-selector',function() UI.selector(3,{[1]=true}) end)
  export('v12-map',function() UI.map(Courses[14],784,176,0) end)
  local worlds={{1,48,48},{5,120,80},{8,180,80},{9,145,80},{10,140,80},{11,180,176},{12,195,112},{15,112,80},{16,112,80}}
  for _,v in ipairs(worlds) do export(string.format('v12-world-%02d',v[1]),function() world(table.unpack(v)) end) end
  for _,v in ipairs({{'arrival',1,0},{'roll',1,.5},{'roll-back',1,2.5},{'jump',5,1.6},{'control',15,1},{'cannon',16,2.5},{'gate',8,1},{'trap',9,2.7},{'ferry',10,1.4},{'rotor',11,1.4},{'sweeper',12,1.1}}) do
   export('v12-guide-'..v[1],function() world(v[2]);UI.lesson(v[1]=='roll-back' and 'roll' or v[1],v[3]) end)
  end
  done=true
 end
 clock=clock+33;UI.title(1)
end
