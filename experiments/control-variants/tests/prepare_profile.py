"""Stage a diagnostic build; no production files are changed."""
from pathlib import Path
import shutil
import sys

root = Path(__file__).resolve().parents[1]
stage = root / 'builds' / 'profile-source'
stage.mkdir(parents=True, exist_ok=True)
for p in (root / 'source').iterdir():
    if p.is_file():
        shutil.copy2(p, stage / p.name)
    elif p.is_dir():
        shutil.copytree(p,stage / p.name,dirs_exist_ok=True)
s = (stage / 'main.lua').read_text(encoding='utf-8')
s = 'Profile={marks={}}\nfunction Profile.mark(i) Profile.marks[i]=playdate.getElapsedTime() end\n' + s
anchors = [
    ' camX=(x-y)*0.9;camY=(x+y)*0.45-ballHeight*0.65',
    " if state~='fall' and support(x,y) then",
    ' marker(course.start,',
    ' -- Rolling shell',
    ' local left,top=screenX-14,screenY-14',
    ' if #boxes>0 then',
    ' UI.hud(course,level,jumpEnabled,throttle,',
    ' if controls.flash>0 then',
]
for i, anchor in enumerate(anchors, 1):
    assert s.count(anchor) == 1, anchor
    s = s.replace(anchor, f' Profile.mark({i})\n'+anchor)
driver = (root / 'tests' / 'device_motion.lua').read_text()
driver = driver.replace("local modes={'image','chunks'}", "local modes={'default','spare'}")
driver = driver.replace('local cases={1,2,14}', 'local cases={14}')
driver = driver.replace('Build.terrainMode=modes[modeIndex];terrainCourse=nil', "Build.terrainMode='image';pd.setGCScaling(0,modeIndex==1 and 1 or 0);terrainCourse=nil")
driver = driver.replace('frame==180', 'frame==600')
driver = driver.replace('normalUpdate()\n local duration', "Profile.mark(0);local mem=collectgarbage('count')\n normalUpdate()\n local duration")
driver = driver.replace('if duration>33.33 then slow=slow+1 end', """if duration>33.33 then slow=slow+1 end
 if duration>40 then
  local parts=''
  for i=1,8 do parts=parts..string.format(' p%d=%.2f',i,(Profile.marks[i]-Profile.marks[i-1])*1000) end
  print(string.format('SPIKE mode=%s f=%d x=%.1f y=%.1f total=%.3f memoryDelta=%.1f%s',modes[modeIndex],frame,x,y,duration,collectgarbage('count')-mem,parts))
 end""")
if '--soak' in sys.argv:
    driver = (root / 'tests' / 'device_soak.lua').read_text()
    driver = driver.replace('normalUpdate()\n if scene', "Profile.mark(0);local mem=collectgarbage('count')\n normalUpdate()\n if scene")
    driver = driver.replace('frame=frame+1', """if duration>40 then
  local parts=''
  for i=1,8 do parts=parts..string.format(' p%d=%.2f',i,(Profile.marks[i]-Profile.marks[i-1])*1000) end
  print(string.format('SPIKE scene=%d f=%d state=%s x=%.1f y=%.1f z=%.1f total=%.3f memoryDelta=%.1f%s',scene,frame,state,x,y,jumpZ,duration,collectgarbage('count')-mem,parts))
 end
 frame=frame+1""")
(stage / 'main.lua').write_text(s+'\n'+driver, encoding='utf-8')
(stage / 'pdxinfo').write_text('name=Sky Hamster Performance Check\nbundleID=com.playdateworkshop.skyhamster.perf\nversion=0.5.7-test\nbuildNumber=13\n')
print(stage)
