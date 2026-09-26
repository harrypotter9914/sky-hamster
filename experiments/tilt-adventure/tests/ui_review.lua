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
  for _,button in ipairs({'A','B','up','down','left','right'}) do
   local cap=g.image.new(17,17,g.kColorClear);g.pushContext(cap);UI.keycap(button,0,0);g.popContext()
   local x0,y0,x1,y1=17,17,-1,-1
   for y=0,16 do for x=0,16 do if cap:sample(x,y)==g.kColorWhite then
    x0=math.min(x0,x);y0=math.min(y0,y);x1=math.max(x1,x);y1=math.max(y1,y)
   end end end
   assert(x0+x1==16 and y0+y1==16,'off-center keycap '..button)
  end
  print('PASS: all six keycaps have white glyph bounds centered at pixel (8,8)')
  clock=clock+100;UI.title(1);clock=clock+100
  export('v12-title',function() UI.title(1) end)
  export('v12-settings',function() UI.settings(3,true,false,true) end)
  export('v12-selector',function() UI.selector(3,{[1]=true}) end)
  export('v12-map',function() UI.map(Courses[14],784,176,0) end)
  export('v15-calibration',function() UI.calibration() end)
  export('v15-failure',function() UI.failure(3,true) end)
  export('v15-result',function() UI.result(63.7,3,58.2,false) end)
  export('v15-ending',function() UI.ending({[1]=true}) end)
  export('v16-goal',function() UI.goal(Courses[14],14,1) end)
  export('v16-machine',function() UI.goal(Courses[16],16,3) end)
  export('v19-locked',function() UI.hud(Courses[16],16,true,0,0,0,0,0);UI.dockStatus('LOCKED') end)
  export('v19-unlocked',function() UI.hud(Courses[16],16,true,0,0,0,0,0);UI.dockStatus('UNLOCKED') end)
  export('v16-help',function() Guide.enter(Courses[14],true);UI.lesson(Guide.key(),1) end)
  for i,t in ipairs({.9,2.4,3.9,5.4}) do export('v17-turn-'..i,function() UI.lesson('roll',t) end) end
  for _,kind in ipairs({'arrival','roll','jump','control','cannon','gate','trap','ferry','rotor','sweeper'}) do
   for i,t in ipairs({0,1,1.8,2.8,4,5.7}) do
    export('v15-'..kind..'-'..i,function() UI.lesson(kind,t) end)
   end
  end
  local worlds={{1,48,48},{5,120,80},{8,180,80},{9,145,80},{10,140,80},{11,180,176},{12,195,112},{15,112,80},{16,112,80}}
  export('v14-pointer',function() world(1,80,48);UI.tiltPointer(200,112,1,-1,.8) end)
  export('v14-pointer-neutral',function() world(1,80,48);UI.tiltPointer(200,112,0,0,0) end)
  for _,v in ipairs(worlds) do export(string.format('v12-world-%02d',v[1]),function() world(table.unpack(v)) end) end
  for _,v in ipairs({{'arrival',1,0},{'roll',1,.5},{'roll-back',1,2.5},{'jump',5,1.6},{'control',15,1},{'cannon',16,2.5},{'gate',8,1},{'trap',9,2.7},{'ferry',10,1.4},{'rotor',11,1.4},{'sweeper',12,1.1}}) do
   export('v12-guide-'..v[1],function() world(v[2]);UI.lesson(v[1]=='roll-back' and 'roll' or v[1],v[3]) end)
  end
  done=true
 end
 clock=clock+33;UI.title(1)
end
