import 'CoreLibs/graphics'
import 'physics'
import 'courses'
import 'mechanisms'
import 'ui'
import 'tilt_ui'
Tilt={power=.65,dx=.7,dy=.7,cooldown=0,time=.6};Dock={}
local g=playdate.graphics
local pages={
 function() UI.title(1) end,
 function() UI.settings(3,true,false,true) end,
 function() UI.selector(3,{[1]=true,[2]=true}) end,
 function() UI.map(Courses[14],784,176,0) end,
 function() UI.lesson(true,'cannon') end,
 function() UI.calibration() end,
 function() UI.failure(3,true) end,
 function() UI.ending({[1]=true,[2]=true}) end,
 function() UI.hud(Courses[3],3,true,.65,0,72.4,2,123) end,
 function() UI.scene();UI.result(52.3,1,50.2,false) end,
 function() UI.selector(15,{}) end
}
local done=false
function playdate.update()
 if not done then
  for n,draw in ipairs(pages) do local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext();playdate.datastore.writeImage(im,string.format('ui-%02d.gif',n)) end
  done=true
 end
 UI.title(1)
end
