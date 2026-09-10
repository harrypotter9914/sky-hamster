-- Append to main.lua in an ignored diagnostic staging directory only.
local normalUpdate=pd.update
local modes={'image','chunks'}
local cases={1,2,14}
local caseIndex,modeIndex,frame=1,1,0
local total,maximum,slow,intervalMax,previous=0,0,0,0,nil
local wait=90
pd.buttonJustPressed=function() return false end
pd.buttonIsPressed=function(k) return k==pd.kButtonRight end
pd.getCrankChange=function() return 6 end
function pd.update()
 if wait>0 then wait=wait-1;return end
 if frame==0 then
  Build.terrainMode=modes[modeIndex];terrainCourse=nil
  selectLevel(cases[caseIndex]);lesson=false
  total,maximum,slow,intervalMax,previous=0,0,0,0,nil
 end
 -- Sweep tile centres to exercise changing camera, slopes and occlusion.
 -- This measures render/update cost, not human completion of a course.
 local tile=course.tiles[math.floor(frame/3)%#course.tiles+1]
 x,y=tile.x*32+16,tile.y*32+16;vx,vy=30,0
 state='play';airborne=false;ballHeight=course:height(x,y)
 local start=pd.getElapsedTime()
 if previous then intervalMax=math.max(intervalMax,(start-previous)*1000) end
 previous=start
 normalUpdate()
 local duration=(pd.getElapsedTime()-start)*1000
 total=total+duration;maximum=math.max(maximum,duration)
 if duration>33.33 then slow=slow+1 end
 frame=frame+1
 if frame==180 then
  print(string.format('MOTION mode=%s level=%d avg=%.3f max=%.3f over33=%d intervalMax=%.3f misses=%d',modes[modeIndex],cases[caseIndex],total/frame,maximum,slow,intervalMax,terrainChunks and terrainChunks.misses or 0))
  frame=0;caseIndex=caseIndex+1
  if caseIndex>#cases then caseIndex=1;modeIndex=modeIndex+1 end
  if modeIndex>#modes then print('MOTION DONE');pd.update=function() end end
 end
end
