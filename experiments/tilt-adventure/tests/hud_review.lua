-- Native 400x240 review: real font metrics, every course name, extreme readouts.
import 'game'
local g=playdate.graphics
local done=false
local function capture(name,draw)
 local im=g.image.new(400,240,g.kColorWhite)
 g.pushContext(im);draw();g.popContext()
 playdate.datastore.writeImage(im,'hud-'..name..'.gif')
end
function playdate.update()
 if done then return end
 Review.select(1);Tilt.calibrating=false;Tilt.ready=true
 local cases={
  {'idle',1,false,0,0,0,0,0},
  {'rolling',15,true,.65,0,87,3,128},
  {'recovering',27,true,1,0,5999,99,999},
  {'large',44,true,.3,0,6000,1234,1234}
 }
 for _,v in ipairs(cases) do
  Tilt.dx=.5;Tilt.dy=-.2;Tilt.cooldown=v[1]=='recovering' and .42 or 0;Dock.active=nil
  capture(v[1],function() Review.render();UI.hud(Courses[v[2]],table.unpack(v,2)) end)
 end
 for n,c in ipairs(Courses) do
  capture('course-'..n,function() UI.hud(c,n,true,.5,0,61,12,100) end)
 end
 for _,kind in ipairs({'cannon','lift','slider','fan','extend','switch','rotor'}) do
  Dock.active={kind=kind}
  capture('dock-'..kind,function() UI.hud(Courses[16],16,true,0,0,10,0,0) end)
 end
 playdate.datastore.write({complete=true,count=55},'hud-review')
 print('PASS: 55 native HUD exports complete')
 done=true
end
