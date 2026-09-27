-- Temporary native-device audit. No production preferences are read or written.
local resumeWorkload=playdate.update
local report={samples={},complete=false}
local entries={}
for name,player in pairs(Audio.players) do
 entries[#entries+1]={name='game/'..name,player=player,loop=name=='roll' or name=='music'}
end
for name,s in pairs(MechanismAudio.shots) do entries[#entries+1]={name='event/'..name,player=s.player} end
for _,s in ipairs(MechanismAudio.loops) do entries[#entries+1]={name='loop/'..s.name,player=s.player,loop=true} end
table.sort(entries,function(a,b) return a.name<b.name end)
entries[#entries+1]={name='roll/slow',player=Audio.players.roll,loop=true,rate=.55}
entries[#entries+1]={name='roll/fast',player=Audio.players.roll,loop=true,rate=1.65}
local index,frame=0,0
local startup=playdate.getCurrentTimeMilliseconds()
local function quiet()
 for _,v in ipairs(entries) do v.player:stop() end
end
quiet()
local function audit()
 local g=playdate.graphics
 g.clear(g.kColorWhite);g.setColor(g.kColorBlack)
 if playdate.getCurrentTimeMilliseconds()-startup<5000 then g.drawText('Audio checks starting...',30,95);return end
 if frame==0 then
  index=index+1
  if index>#entries then
   quiet();report.complete=true;AudioAuditWrite(report,'audio-device-report')
   print('AUDIO COMPLETE',#report.samples)
   Audio.players.roll:setRate(1)
   Audio.players.music:setVolume(.16);Audio.players.music:play(0)
   MechanismAudio.reset(Courses[1]);playdate.update=resumeWorkload;return
  end
  local e=entries[index]
  e.player:setPaused(false);e.player:setRate(e.rate or 1);e.player:setVolume(.25)
  e.player:play(e.loop and 0 or 1)
  assert(e.player:isPlaying(),'did not start: '..e.name)
  frame=1
 else
  frame=frame+1
  local e=entries[index]
  if frame>=24 then
   if e.loop then assert(e.player:isPlaying(),'loop stopped: '..e.name) end
   e.player:stop();assert(not e.player:isPlaying(),'did not stop: '..e.name)
   report.samples[#report.samples+1]={name=e.name,start=true,stop=true,loop=e.loop or false}
   print('AUDIO PASS',e.name)
   frame=0
  end
 end
 g.drawText('Audio '..index..' / '..#entries,30,80)
 g.drawText(entries[index].name,30,110)
end
playdate.update=function()
 local ok,err=pcall(audit)
 if not ok then
  quiet();report.error=tostring(err);AudioAuditWrite(report,'audio-device-report')
  print('AUDIO ERROR',err);playdate.update=resumeWorkload
 end
end
