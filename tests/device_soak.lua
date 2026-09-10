-- Append to a full production main.lua in a diagnostic build only.
local normalUpdate=pd.update
local fullCourses=Courses
local frame,scene,wait=0,0,90
local total,maximum,gapMax,slow,gaps,firstTime,lastTime=0,0,0,0,0,0,nil
local heldKey,crankAngle,pressA,pressB
pd.buttonIsPressed=function(k) return k==heldKey end
pd.buttonJustPressed=function(k) return (k==pd.kButtonA and pressA) or (k==pd.kButtonB and pressB) end
pd.getCrankChange=function() return crankAngle end
function pd.update()
 if wait>0 then wait=wait-1;return end
 if frame==0 then
  scene=scene+1
  if scene>3 then print('SOAK DONE');pd.update=function() end;return end
  Courses=fullCourses
  if scene==3 then if Audio then Audio.pause() end;Build.classroom=true;Classroom.apply();selectLevel(1)
  else selectLevel(scene==1 and 13 or 14);lesson=false end
  total,maximum,gapMax,slow,gaps,firstTime,lastTime=0,0,0,0,0,pd.getElapsedTime(),nil
 end
 local phase=frame%180
 heldKey=phase<100 and pd.kButtonRight or phase<150 and pd.kButtonDown or pd.kButtonLeft
 crankAngle=phase<90 and 8 or phase<120 and -8 or 0
 if scene==3 and frame==0 then crankAngle=90 end
 pressA=(scene==3 and frame==0) or phase==121
 pressB=frame>0 and frame%210==0
 local beforeX=x
 local began=pd.getElapsedTime()
 if lastTime then local gap=(began-lastTime)*1000;gapMax=math.max(gapMax,gap);if gap>40 then gaps=gaps+1 end end
 lastTime=began
 normalUpdate()
 if scene==3 and frame==0 then
  print(string.format('SOAK startInput moved=%s power=%.4f',tostring(x>beforeX),controls.power))
 end
 local duration=(pd.getElapsedTime()-began)*1000
 total=total+duration;maximum=math.max(maximum,duration);if duration>33.33 then slow=slow+1 end
 frame=frame+1
 if frame==450 then
  print(string.format('SOAK scene=%d avg=%.3f max=%.3f over33=%d gapMax=%.3f gapsOver40=%d fps=%.2f falls=%d',scene,total/frame,maximum,slow,gapMax,gaps,(frame-1)/(began-firstTime),falls))
  frame=0
 end
end
