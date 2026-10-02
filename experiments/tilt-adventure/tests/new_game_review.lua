-- Native 400x240 rendering of every added menu state; never touches player saves.
import 'CoreLibs/graphics'
import 'loading'
Loading.booting=true
local read=playdate.datastore.read
playdate.datastore.read=function(name,...)
 if name=='tilt-progress' then return nil end
 return read(name,...)
end
playdate.datastore.write=function() end
import 'game'
Loading.booting=false
local g=playdate.graphics
local n=0
function playdate.update()
 n=n+1
 if n>4 then return end
 local im=g.image.new(400,240,g.kColorWhite)
 g.pushContext(im)
 if n<=2 then UI.settings(n==1 and 5 or 6,true,true,true)
 else UI.newGame(n-2) end
 g.popContext();im:draw(0,0)
 playdate.datastore.writeImage(im,'new-game-v0127-'..n..'.gif')
 if n==4 then print('NEW GAME REVIEW COMPLETE') end
end
