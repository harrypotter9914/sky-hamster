-- Native-size bitmap and animation-frame review with an isolated datastore.
import 'CoreLibs/graphics'
import 'loading'
Loading.booting=true
local read,write=playdate.datastore.read,playdate.datastore.write
playdate.datastore.read=function(name,...) if name=='tilt-progress' then return nil end;return read(name,...) end
playdate.datastore.write=function() end
import 'game'
Loading.booting=false
local g=playdate.graphics
local plan={}
local function add(kind,choice,t,variant) plan[#plan+1]={kind=kind,choice=choice,time=t,variant=variant} end
for choice=1,2 do
 for direction=0,3 do for _,phase in ipairs({.1,.35,.7,1.3,1.9}) do add('steering',choice,direction*2+phase) end end
 add('start',choice);add('new',choice)
end
for _,choice in ipairs({5,6}) do add('settings',choice) end
for _,variant in ipairs({'fresh','progress','developer'}) do for _,n in ipairs({1,4,53}) do add('selector',n,0,variant) end end
add('steering',2,0,'onboarding');add('saved',1,0,'screen');add('saved',2,0,'road')
for i=0,239 do add('steering',1,i/30,'animation') end
local report={complete=false,frames={}}
local index=1
function playdate.update()
 if index>#plan then return end
 local ok,err=pcall(function()
  local s=plan[index];local im=g.image.new(400,240,g.kColorWhite)
  CampaignAccess.frontier=s.variant=='progress' and 5 or 1
  CampaignAccess.developer=s.variant=='developer'
  g.pushContext(im);g.setFont(UI.bodyFont)
  if s.kind=='steering' then UI.steering(s.choice,s.time,s.variant=='onboarding' and 'road' or 'screen',s.variant=='onboarding')
  elseif s.kind=='saved' then UI.steeringSaved(s.variant)
  elseif s.kind=='start' then UI.startMenu(s.choice,12)
  elseif s.kind=='new' then UI.newGame(s.choice)
  elseif s.kind=='settings' then UI.settings(s.choice,true,true,true)
  else UI.selector(s.choice,s.variant=='progress' and {[1]=true,[2]=true,[3]=true,[4]=true} or {},nil,CampaignAccess.developer) end
  g.popContext();im:draw(0,0)
  s.file='release-menu-'..index..'.gif';playdate.datastore.writeImage(im,s.file)
  report.frames[#report.frames+1]=s;index=index+1
  if index>#plan then report.complete=true;write(report,'release-menu-report');print('RELEASE MENU REVIEW COMPLETE '..#report.frames) end
 end)
 if not ok then report.error=tostring(err);write(report,'release-menu-report');print('RELEASE MENU ERROR '..tostring(err));index=#plan+1 end
end
