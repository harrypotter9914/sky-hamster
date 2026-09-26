import 'CoreLibs/graphics'
import 'loading'
playdate.display.setRefreshRate(30)
local g=playdate.graphics
local frame=0
function playdate.update()
 if frame<72 then
  Loading.time=frame/30;Loading.shown=frame/71;Loading.label=frame<36 and 'BUILDING STONE ROAD' or 'PAINTING THE VIEW'
  local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);Loading.draw();g.popContext()
  playdate.datastore.writeImage(im,string.format('loading-%02d.gif',frame))
  frame=frame+1
  if frame==72 then
   Loading.time=0;Loading.shown=0;Loading.label='WAKING UP THE SKY'
   local splash=g.image.new(400,240,g.kColorWhite);g.pushContext(splash);Loading.draw();g.popContext()
   playdate.datastore.writeImage(splash,'loading-splash.gif')
   print('PASS: native loading animation exports complete')
  end
 end
 Loading.time=Loading.time+1/30;Loading.draw()
end
