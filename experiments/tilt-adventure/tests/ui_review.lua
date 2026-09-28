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
  for _,kind in ipairs({'lift','slider','fan','windcontrol','bumper'}) do
   for i,t in ipairs({0,1.8,4.5}) do export('v20-'..kind..'-'..i,function() UI.lesson(kind,t) end) end
  end
  for _,n in ipairs({14,19,20,21,22,23,24,27,28,32,33}) do
   export('v20-map-'..n,function() UI.map(Courses[n],Courses[n].start[1],Courses[n].start[2],0) end)
  end
  for _,v in ipairs({{14,224,112},{19,224,96},{22,184,80},{24,144,112},{27,560,144},{33,224,80}}) do
   export('v20-world-'..v[1],function() world(table.unpack(v)) end)
  end
  export('v20-lift-top',function() world(19,224,96);Dock.update(Courses[19],224,96,0,0,false,384,false,false);Review.place(224,96);Review.render() end)
  export('v20-slider-end',function() world(22,184,80);Dock.update(Courses[22],184,80,0,0,false,540,false,false);Review.place(488,80);Review.render() end)
  print('PASS: v20 campaign and machinery visual exports complete')
  for _,kind in ipairs({'conveyor','jet','extend','switch','magnet'}) do for i,t in ipairs({0,2,4}) do export('v30-'..kind..'-'..i,function() UI.lesson(kind,t) end) end end
  for _,v in ipairs({{34,304,112},{36,304,112},{38,144,112},{40,240,112},{42,272,112},{44,4800,240}}) do export('v30-world-'..v[1],function() world(table.unpack(v)) end) end
  export('v30-extended',function() world(38,144,112);Dock.update(Courses[38],144,112,0,0,false,400,false,false);Review.render() end)
  export('v30-map',function() UI.map(Courses[44],48,80,0) end)
  for _,v in ipairs({{14,208,112},{19,224,96},{24,144,112},{34,304,112},{36,304,112},{38,144,112},{40,240,112},{42,272,112}}) do
   for i,t in ipairs({0,.12,.3,.65}) do export('v40-'..v[1]..'-'..i,function() world(table.unpack(v));Review.animate(t,i*50);Review.render() end) end
  end
  export('v40-road',function() world(1,176,48) end)
  for i,angle in ipairs({-math.pi/3,-math.pi/6,0,math.pi/6,math.pi/3}) do
   export('v108-cannon-'..i,function()
    world(27,560,144);Courses[27].pads[2].angle=angle;Review.render()
   end)
  end
  for i,crank in ipairs({0,192,384}) do
   export('v108-lift-'..i,function() world(19,224,96);Review.animate(0,crank);Review.render() end)
  end
  for i,crank in ipairs({0,270,540}) do
   export('v108-slider-'..i,function() world(22,200,80);Review.animate(0,crank);local m=Courses[22].mechanisms[1];local x,y=Mechanisms.pose(m,0);Review.place(x,y);Review.render() end)
  end
  for i,t in ipairs({0,3.1,4,5,7}) do
   export('v108-rotor-'..i,function() world(12,256,176);Review.animate(t);Review.render() end)
  end
  world(44,1392,80)
  local rotorArt=Structures.reviewArt()
  assert(rotorArt['rotor-160']==180 and rotorArt['rotor-192']==180,'missing baked rotor frame tables')
  playdate.datastore.write({rotors=rotorArt,complete=true},'v108-native-review')
  world(27,560,144)
  for i=0,60 do
   Courses[27].pads[2].angle=-math.pi/3+i*math.pi/90
   export(string.format('v108-aim-%02d',i),function() Review.render() end)
  end
  for i=0,89 do
   export(string.format('v108-crank-%02d',i),function() UI.lesson('control',i/15) end)
  end
  for _,kind in ipairs({'ferry','slider','lift','rotor','trap','gate','sweeper','conveyor'}) do
   for i,t in ipairs({0,.1,.3,2.8,4.8}) do
    export('v106-machine-'..kind..'-'..i,function()
     g.clear(g.kColorWhite);g.drawText(kind,14,12)
     Structures.demo(kind,200,142,t,t/5)
    end)
   end
  end
  local audited={}
  for n,c in ipairs(Courses) do
   for _,m in ipairs(c.mechanisms or {}) do
    local kind=m.retract and 'extend' or m.kind
    if not audited[kind] then
     audited[kind]=n
     for i,t in ipairs({0,2.9,4.2}) do
      export('v108-audit-'..kind..'-'..i,function()
       world(n,m.x,m.y);if m.kind~='lift' and m.kind~='ferry' and m.kind~='rotor' then Review.place(m.x-45,m.y+28) end;Review.animate(t,m.manual and 90 or nil);Review.render()
      end)
     end
    end
   end
  end
  for i,a in ipairs({-135,-90,-45,0,45,90,135,180}) do
   export('v108-fan-'..i,function() world(24,144,112);Courses[24].mechanisms[1].angle=math.rad(a);Review.render() end)
  end
  playdate.datastore.write({complete=true,kinds=audited},'v108-audit')
  print('PASS: v40 native animation exports complete')
  done=true
 end
 clock=clock+33;UI.title(1)
end
