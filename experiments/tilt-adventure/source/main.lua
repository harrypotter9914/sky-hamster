import "CoreLibs/graphics"
import "loading"
-- The SDK only permits imports during initial pdz loading. The launch image
-- matches frame zero; resource preparation starts after the first display frame.
Loading.booting=true
import "engine"
Loading.booting=false
local gameUpdate=playdate.update
Loading.begin(function()
 for i=1,8 do Loading.preload(i);Loading.checkpoint(i/8*.15,'WAKING UP THE SKY') end
 Audio.init(not Build.classroom)
 MechanismAudio.init(not Build.classroom)
 Loading.checkpoint(1,'READY')
end,'WAKING UP THE SKY',function()
 playdate.update=gameUpdate
 print('READY: startup loading complete')
end)
playdate.update=function() Loading.step(1/30) end
