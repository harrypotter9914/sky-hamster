import 'CoreLibs/graphics'
UI={};Tilt={mode='road'};CampaignAccess={developer=false}
import 'tilt_ui'
import 'awake'
playdate.display.setRefreshRate(30)
local shots={}
for _,on in ipairs({true,false}) do for i=1,5 do shots[#shots+1]={choice=i,on=on,mode='road',name=string.format('%02d-%s',i,on and 'on' or 'off')} end end
shots[#shots+1]={choice=5,on=true,mode='screen',name='05-screen'}
shots[#shots+1]={choice=5,on=false,mode='road',developer=true,name='05-developer'}
local report={version='0.12.12',complete=false,device=playdate.getStats()~=nil,captures={}}
local n=1;local frames=0
function playdate.update()
 Awake.update()
 local shot=shots[n] or shots[#shots]
 UI.motion=shot.on;Tilt.mode=shot.mode;CampaignAccess.developer=shot.developer==true
 local ok,err=pcall(UI.settings,shot.choice,shot.on,shot.on,shot.on)
 if not ok then report.error=tostring(err);playdate.datastore.write(report,'settings-layout-report');playdate.update=function()end;return end
 frames=frames+1
 if frames%2==0 and n<=#shots then
  playdate.datastore.writeImage(playdate.graphics.getWorkingImage(),'settings-layout-'..shot.name..'.gif')
  report.captures[#report.captures+1]=shot.name;n=n+1
  if n>#shots then report.complete=true;playdate.datastore.write(report,'settings-layout-report');print('SETTINGS LAYOUT COMPLETE') end
 end
end
