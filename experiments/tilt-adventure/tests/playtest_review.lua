import 'CoreLibs/graphics'
import 'loading'
Loading.booting=true
import 'game'
Loading.booting=false
local g=playdate.graphics
local plan={{kind='settings',mode='screen'},{kind='settings',mode='road'}}
for _,mode in ipairs({'screen','road'}) do for _,t in ipairs({.9,2.4,3.9,5.4}) do plan[#plan+1]={kind='guide',mode=mode,t=t} end end
for _,n in ipairs({1,4,6,34,53}) do plan[#plan+1]={kind='world',n=n} end
local index,frames,waiting=1,0,false
function playdate.update()
 Awake.update()
 if Loading.busy then Loading.step(1/30);return end
 if index>#plan then return end
 local s=plan[index]
 if s.kind=='world' and not waiting then Review.begin(s.n);waiting=true;return end
 frames=frames+1
 if frames<3 then return end
 Tilt.mode=s.mode or 'screen';Tilt.ready=true;Tilt.calibrating=false;Tilt.power=0;Tilt.dx=0;Tilt.dy=0
 local im=g.image.new(400,240,g.kColorWhite)
 g.pushContext(im)
 if s.kind=='settings' then UI.settings(5,true,true,true)
 elseif s.kind=='guide' then UI.lesson('roll',s.t)
 else Review.render() end
 g.popContext();im:draw(0,0)
 local name='playtest-v0125-'..index..'.gif'
 playdate.datastore.writeImage(im,name)
 print('REVIEW '..index..' '..s.kind..' '..(s.mode or s.n))
 frames=0;waiting=false;index=index+1
 if index>#plan then playdate.datastore.write({complete=true,count=#plan},'playtest-review-v0125');print('BENCH COMPLETE') end
end
