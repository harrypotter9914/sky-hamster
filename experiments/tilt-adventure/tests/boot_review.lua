local ok,err=pcall(function() import 'bootstrap' end)
if not ok then
 playdate.datastore.write({error=tostring(err),phase='static imports'},'loading-report')
 playdate.update=function() end
 return
end
local current=playdate.update
local frames,phase=0,'boot'
local report={bootFrames=0,courseFrames=0,progress={}}
local wrapper
wrapper=function()
 local ok,err=pcall(current)
 if not ok then
  report.error=tostring(err);playdate.datastore.write(report,'loading-report')
  playdate.update=function() end;return
 end
 if playdate.update~=wrapper then current=playdate.update;playdate.update=wrapper end
 frames=frames+1
 if Loading.busy then report.progress[#report.progress+1]=Loading.shown end
 if not Loading.busy then
  if phase=='boot' then
   report.bootFrames=frames;phase='course';frames=0
   ReviewLoadCourse(44)
  else
   report.courseFrames=frames;report.complete=true
   playdate.datastore.write(report,'loading-report')
   playdate.update=function() end
  end
 end
end
playdate.update=wrapper
