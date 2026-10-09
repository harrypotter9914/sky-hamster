"""Native SDK checks for contextual system menu and temporary developer access."""
from pathlib import Path
import ast,re,shutil,subprocess
here=Path(__file__).resolve().parent;source=here.parent/'source';repo=here.parents[2]
qa=repo/'builds/menu-review-source';qa.mkdir(exist_ok=True)
shutil.copytree(source,qa,dirs_exist_ok=True)
tree=ast.parse((here/'check_context_menus.py').read_text())
body=next(n.args[0].value for n in ast.walk(tree) if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute) and n.func.attr=='execute' and n.args and isinstance(n.args[0],ast.Constant) and isinstance(n.args[0].value,str))
names=sorted(set(re.findall(r"(?:get|put)\('([^']+)'",body)))
engine=(source/'engine.lua').read_text()
engine+='\nfunction get(name)\n'+''.join(f" if name=='{n}' then return {n} end\n" for n in names)+" error('missing '..name)\nend\n"
engine+='function put(name,value)\n'+''.join(f" if name=='{n}' then {n}=value;return end\n" for n in names)+" error('missing '..name)\nend\n"
(qa/'engine.lua').write_text(engine,encoding='utf-8')
shutil.copy2(source/'main.lua',qa/'productionmain.lua')
prefix=r"""
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
 if name=='tilt-progress' then store.saved=value;nativeWrite(value,'menu-review-progress') else nativeWrite(value,name) end
end
local realMenu=playdate.getSystemMenu()
playdate.getSystemMenu=function() return {addMenuItem=function(_,name,fn) menu[name]=fn;return realMenu:addMenuItem(name,fn) end,removeAllMenuItems=function()menu={};realMenu:removeAllMenuItems()end} end
import 'productionmain'
local nativeUpdate=playdate.update
local report={version='0.12.11',complete=false,device=playdate.getStats()~=nil,scriptedInputs=true,frames=0,cpuMax=0,captures={}}
local preview,runner
function drainLoading() while Loading.busy do coroutine.yield() end end
function frame(p,h)
 pressed={};held={};for key,value in pairs(p or {}) do pressed[keys[key]]=value end
 for key,value in pairs(h or {}) do held[keys[key]]=value end
 coroutine.yield();pressed={};drainLoading()
end
function capture(name)
 playdate.datastore.writeImage(playdate.graphics.getWorkingImage(),'menus-'..name..'.gif')
 report.captures[#report.captures+1]=name
end
local co=coroutine.create(function()
 drainLoading();for i=1,60 do frame() end
"""
suffix=r"""
report.contextAssertions=true;report.complete=true;nativeWrite(report,'menu-review-report');print('MENU REVIEW COMPLETE')
end)
runner=function()
 local before=playdate.getCurrentTimeMilliseconds()
 local ok,err=pcall(function()
  nativeUpdate()
 end)
 report.frames=report.frames+1;report.cpuMax=math.max(report.cpuMax,playdate.getCurrentTimeMilliseconds()-before)
 if playdate.update~=runner then nativeUpdate=playdate.update;playdate.update=runner end
 if ok and coroutine.status(co)~='dead' then ok,err=coroutine.resume(co) end
 if not ok then report.error=tostring(err);nativeWrite(report,'menu-review-report');print('MENU REVIEW ERROR '..tostring(err));playdate.update=function()end end
end
playdate.update=runner
"""
(qa/'main.lua').write_text(prefix+body+suffix,encoding='utf-8')
out=repo/'builds/menu-review/sky-hamster-tilt.pdx';out.parent.mkdir(exist_ok=True)
sdk=Path('C:/Users/12063/Documents/PlaydateSDK')
subprocess.run([str(sdk/'bin/pdc.exe'),'-sdkpath',str(sdk),str(qa),str(out)],check=True)
print('Built',out)
