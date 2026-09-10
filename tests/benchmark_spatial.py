"""Compare host Lua CPU time, not device FPS. Baseline is released v0.5.3."""
from pathlib import Path
import subprocess
from time import perf_counter
from lupa.lua54 import LuaRuntime
root=Path(__file__).resolve().parents[1]
old=subprocess.check_output(['git','show','v0.5.3:source/spatial.lua'],cwd=root,text=True,encoding='utf-8')
new=(root/'source/spatial.lua').read_text(encoding='utf-8')
verify=LuaRuntime()
for file in ['courses.lua','mechanisms.lua']:
    verify.execute((root/'source'/file).read_text(encoding='utf-8'))
verify.execute(old);verify.execute('Reference=Spatial');verify.execute(new)
verify.execute('''
local points={{14,48,176,72},{8,222,80,0},{8,270,80,0},{5,187,80,-5},{11,256,176,0},{3,300,80,45}}
for _,p in ipairs(points) do for _,time in ipairs({0,3,5,7}) do
 local course,x,y,z=Courses[p[1]],p[2],p[3],p[4]
 local project=function(a,b,h) return 200+(a-b-x+y)*0.9,124+(a+b-x-y)*0.45-h*0.65 end
 local before=Reference.occluders(course,time,project,186,98-z*0.65,28,28)
 local after=Spatial.occluders(course,time,project,186,98-z*0.65,28,28,z)
 local polys={}
 for _,box in ipairs(after) do local poly=Spatial.maskPolygon(box,x,y,project,186,98-z*0.65);if poly then polys[#polys+1]=poly end end
 for row=-11,11 do for col=-11,11 do
  local expected=Reference.visible(before,x,y,z,col,row)
  assert(expected==Spatial.visible(after,x,y,z,col,row),'occlusion changed')
  local covered,border=false,false
  for _,poly in ipairs(polys) do
   local inside=true
   for i=1,#poly,2 do
    local j=(i+1)%#poly+1
    local cross=(poly[j]-poly[i])*(row+14-poly[i+1])-(poly[j+1]-poly[i+1])*(col+14-poly[i])
    if math.abs(cross)<0.0001 then border=true end
    if cross < -0.0001 then inside=false end
   end
   covered=covered or inside
  end
  if not border then assert(expected==not covered,'polygon mask differs from ray test') end
 end end
end end
print('PASS: old/new mask decisions match across flat, slope, wall, jump and rotor scenarios')
''')
for name,code in [('v0.5.3',old),('current',new)]:
    lua=LuaRuntime()
    for file in ['courses.lua','mechanisms.lua']:
        lua.execute((root/'source'/file).read_text(encoding='utf-8'))
    lua.execute(code)
    fn=lua.eval('''function(n,level,x,y,z)
      local course=Courses[level]
      local project=function(a,b,h) return 200+(a-b-x+y)*0.9,124+(a+b-x-y)*0.45-h*0.65 end
      local sum=0
      for i=1,n do
        local boxes=Spatial.occluders(course,0,project,186,98-z*0.65,28,28,z)
        if Spatial.maskPolygon then
          for _,box in ipairs(boxes) do local poly=Spatial.maskPolygon(box,x,y,project,186,98-z*0.65);if poly then sum=sum+#poly end end
        elseif #boxes>0 then for row=-11,11 do for col=-11,11 do
          if Spatial.visible(boxes,x,y,z,col,row) then sum=sum+1 end
        end end end
      end
      return sum
    end''')
    for label,args in [('flat long course',(14,48,176,72)),('behind gate',(8,222,80,0)),('low jump at lip',(5,187,80,-5))]:
        start=perf_counter();fn(300,*args);ms=(perf_counter()-start)*1000/300
        print(f'{name}: {label}: {ms:.3f} ms/frame (host Lua)')
