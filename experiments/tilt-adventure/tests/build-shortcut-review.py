"""Native SDK review of shortcut practice and generated tutorial pages.

Only the isolated package overrides input and save paths. Production is unchanged.
"""
from pathlib import Path
import ast,re,shutil,subprocess

here=Path(__file__).resolve().parent;source=here.parent/'source';repo=here.parents[2]
qa=repo/'builds/shortcut-review-source';qa.mkdir(exist_ok=True)
shutil.copytree(source,qa,dirs_exist_ok=True)
tree=ast.parse((here/'check_shortcut_lessons.py').read_text())
body=next(n.args[0].value for n in ast.walk(tree) if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute) and n.func.attr=='execute' and n.args and isinstance(n.args[0],ast.Constant) and isinstance(n.args[0].value,str))
names=sorted(set(re.findall(r"(?:get|put)\('([^']+)'",body)))
engine=(source/'engine.lua').read_text()
engine+='\nfunction get(name)\n'+''.join(f" if name=='{n}' then return {n} end\n" for n in names)+" error('missing '..name)\nend\n"
engine+='function put(name,value)\n'+''.join(f" if name=='{n}' then {n}=value;return end\n" for n in names)+" error('missing '..name)\nend\n"
(qa/'engine.lua').write_text(engine,encoding='utf-8')
shutil.copy2(source/'main.lua',qa/'productionmain.lua')
body=body.replace("local x,y,t,w=", "capture('map-card');local x,y,t,w=")
body=body.replace("assert(get('overview') and Guide.trying=='map')", "assert(get('overview') and Guide.trying=='map');capture('map-real')")
body=body.replace("assert(Guide.manual and Guide.trying=='help' and Guide.key()=='roll')", "assert(Guide.manual and Guide.trying=='help' and Guide.key()=='roll');capture('help-real')")
body=body.replace("assert(get('briefing') and Guide.trying=='goal')", "assert(get('briefing') and Guide.trying=='goal');capture('goal-real')")
body=body.replace("frame({down=true});assert(Tilt.calibrating)", "frame({down=true});assert(Tilt.calibrating);capture('recenter-real')")
prefix=r'''
local nativeWrite=playdate.datastore.write
local pressed,held={},{}
local keys={a=playdate.kButtonA,b=playdate.kButtonB,left=playdate.kButtonLeft,right=playdate.kButtonRight,up=playdate.kButtonUp,down=playdate.kButtonDown}
accel={0,0,1};menu={}
playdate.readAccelerometer=function() return table.unpack(accel) end
playdate.buttonJustPressed=function(k) return pressed[k] or false end
playdate.buttonIsPressed=function(k) return held[k] or false end
playdate.getCrankChange=function() return 0 end
store={}
playdate.datastore.read=function(name) if name=='tilt-progress' then return nil end end
playdate.datastore.write=function(value,name)
 if name=='tilt-progress' then store.saved=value;nativeWrite(value,'shortcut-review-progress') else nativeWrite(value,name) end
end
local realMenu=playdate.getSystemMenu()
playdate.getSystemMenu=function() return {addMenuItem=function(_,name,fn) menu[name]=fn;return realMenu:addMenuItem(name,fn) end,removeAllMenuItems=function()menu={};realMenu:removeAllMenuItems()end} end
import 'productionmain'
local nativeUpdate=playdate.update
local report={version='0.12.10',complete=false,device=playdate.getStats()~=nil,scriptedInputs=true,frames=0,cpuMax=0,captures={}}
local preview,runner
function drainLoading() while Loading.busy do coroutine.yield() end end
function frame(p,h)
 pressed={};held={};for key,value in pairs(p or {}) do pressed[keys[key]]=value end
 for key,value in pairs(h or {}) do held[keys[key]]=value end
 coroutine.yield();pressed={};drainLoading()
end
function capture(name)
 playdate.datastore.writeImage(playdate.graphics.getWorkingImage(),'shortcuts-'..name..'.gif')
 report.captures[#report.captures+1]=name
end
local co=coroutine.create(function()
 drainLoading();for i=1,60 do frame() end
'''
suffix=r'''
report.practiceAssertions=true
for _,key in ipairs({'map','help','goal','recenter'}) do
 for _,done in ipairs({false,true}) do
  Guide.done[key]=done;preview={key=key,time=.4};frame();capture(key..(done and '-tried' or '-intro'))
 end
end
for _,t in ipairs({.4,1.4,3.4,4.4}) do preview={key='jump',time=t};frame();capture('jump-'..t) end
preview=nil;report.complete=true;nativeWrite(report,'shortcut-review-report');print('SHORTCUT REVIEW COMPLETE')
end)
runner=function()
 local before=playdate.getCurrentTimeMilliseconds()
 local ok,err=pcall(function()
  if preview then playdate.graphics.clear(playdate.graphics.kColorWhite);UI.lesson(preview.key,preview.time)
  else nativeUpdate() end
 end)
 report.frames=report.frames+1;report.cpuMax=math.max(report.cpuMax,playdate.getCurrentTimeMilliseconds()-before)
 if playdate.update~=runner then nativeUpdate=playdate.update;playdate.update=runner end
 if ok and coroutine.status(co)~='dead' then ok,err=coroutine.resume(co) end
 if not ok then report.error=tostring(err);nativeWrite(report,'shortcut-review-report');print('SHORTCUT REVIEW ERROR '..tostring(err));playdate.update=function()end end
end
playdate.update=runner
'''
(qa/'main.lua').write_text(prefix+body+suffix,encoding='utf-8')
out=repo/'builds/shortcut-review/sky-hamster-tilt.pdx';out.parent.mkdir(exist_ok=True)
sdk=Path('C:/Users/12063/Documents/PlaydateSDK')
subprocess.run([str(sdk/'bin/pdc.exe'),'-sdkpath',str(sdk),str(qa),str(out)],check=True)
print('Built',out)
