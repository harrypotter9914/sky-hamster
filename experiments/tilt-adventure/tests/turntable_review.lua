import 'game'
local g=playdate.graphics
local done=false;local count=0
UI.tiltPointer=function()end
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext()
 playdate.datastore.writeImage(im,'turn11-'..name..'.gif');count=count+1
end
local function run()
 for _,n in ipairs({45,46,47,48}) do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local p;for _,pad in ipairs(Courses[n].pads) do if pad.onboard then p=pad;break end end
  Review.place(p.x,p.y)
  assert(Structures.reviewArt()['turn-192']==180,'missing baked turntable views')
  for _,angle in ipairs({0,-35,-62,-87,-90,-93}) do
   p.angle=math.rad(angle);p.target.angle=p.angle
   Review.animate(0,0)
   export(n..'-'..angle,Review.render)
  end
 end
 for _,n in ipairs({9,10,11,12,13,19,22,36,38,40}) do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local m=Courses[n].mechanisms[1];local x,y=Mechanisms.pose(m,0)
  Review.place(x-38,y);Dock.active=nil
  for _,t in ipairs({0,2.5,4.7}) do
   if m.kind=='lift' then m.elevation=t==0 and m.minHeight or t==2.5 and m.maxHeight*.5 or m.maxHeight end
   Review.animate(t)
   export('signal-'..n..'-'..t,Review.render)
  end
 end
 for _,t in ipairs({0,.8,1.7,2.5,3.7,4.7,5.5}) do
  export('lesson-'..t,function()UI.lesson('onboard',t)end)
 end
 for _,spec in ipairs({{1,272,48},{1,272,176},{1,400,176},{4,336,80},{4,336,208},{46,336,176},{48,704,416}}) do
  Review.select(spec[1]);Tilt.calibrating=false;Tilt.ready=true;Review.place(spec[2],spec[3]);Dock.active=nil
  export('corner-'..spec[1]..'-'..spec[2]..'-'..spec[3],Review.render)
 end
 for _,n in ipairs({1,4,19,45,46,48}) do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  export('map-'..n,function()UI.map(Courses[n],Courses[n].start[1],Courses[n].start[2],0)end)
 end
 playdate.datastore.write({complete=true,count=count},'turntable-review-v0.11.0')
 print('PASS: '..count..' native turntable, passage, lift and tutorial frames')
end
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err),count=count},'turntable-review-v0.11.0');print('REVIEW ERROR: '..tostring(err)) end
end
