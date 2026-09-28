"""Render geometry protects the actual airborne marble and its direction compass."""
from check_turntable import lua
lua.execute('''
-- Warm bitmap construction outside the screen-space draw audit.
for _,lane in ipairs({false,1,2}) do for _,ready in ipairs({false,true}) do
 Passage.begin();Passage.signal(200,140,ready,lane or nil)
end end
Passage.begin();UI.worldSign('ROUTE',20,60)
local reserve=Passage.reserve
local g=playdate.graphics;local line=g.drawLine;local circle=g.fillCircleAtPoint
local protected={};local boxes={};local cases=0;local fallbacks=0
local function overlap(x,y,w,h,r)
 return x<r[1]+r[3] and x+w>r[1] and y<r[2]+r[4] and y+h>r[2]
end
Passage.reserve=function(x,y,w,h)
 for _,r in ipairs(boxes) do assert(not overlap(x,y,w,h,r),'overlapping signs/ball/compass') end
 boxes[#boxes+1]={x,y,w,h};reserve(x,y,w,h)
end
g.drawLine=function(x,y,tx,ty)
 local n=math.max(1,math.ceil(math.max(math.abs(tx-x),math.abs(ty-y))*2))
 for step=0,n do
  local px,py=x+(tx-x)*step/n,y+(ty-y)*step/n
  for _,r in ipairs(protected) do
   assert(not overlap(px-.5,py-.5,1,1,r),'leader/icon cuts across ball or compass')
  end
 end
end
g.fillCircleAtPoint=function(x,y,r)
 if r==7 then fallbacks=fallbacks+1 end
 for _,box in ipairs(protected) do assert(not overlap(x-r,y-r,r*2,r*2,box),'fallback covers ball') end
end
for x=60,340,20 do for y=65,185,15 do for _,lane in ipairs({false,1,2}) do
 Passage.begin();boxes={};protected={{x-14,y-14,28,28},{x-14,y-43,29,29}}
 for _,r in ipairs(protected) do reserve(table.unpack(r));boxes[#boxes+1]=r end
 UI.worldSign('ROUTE',190,105,200,140)
 -- Dense labels force alternate slots and compact fallbacks.
 for _,p in ipairs({{200,140,true},{238,119,false},{176,156,true},{202,94,false}}) do
  Passage.signal(p[1],p[2],p[3],lane or nil)
 end
 cases=cases+1
end end end
assert(fallbacks>0,'compact path not exercised')
Passage.reserve=reserve;g.drawLine=line;g.fillCircleAtPoint=circle
for _,n in ipairs({40,41,44}) do
 local gates={};for _,m in ipairs(Courses[n].mechanisms) do if m.lane then gates[m.lane]=m end end
 assert(gates[1] and gates[2]);assert(gates[1].partner==gates[2])
 for phase=1,3 do
  for i,m in ipairs(gates) do m.isOpen=phase==i;m.transitionAt=nil end
  assert(Passage.state(gates[1],0)==(phase==1) and Passage.state(gates[2],0)==(phase==2),'lane signals not independent')
 end
 local a,b=gates[1],gates[2]
 a.isOpen=false;a.transitionAt=0;a.transitionFrom=0
 b.isOpen=true;b.transitionAt=0;b.transitionFrom=80
 assert(not Passage.state(a,.12) and not Passage.state(b,.12),'moving gates reported passable before fully clear')
 assert(not Passage.state(a,.3) and Passage.state(b,.3),'transition does not reach correct state')
end
print('PASS: '..cases..' crowded layouts protect ball/compass, '..fallbacks..' compact indicators, independent dual gates in 40/41/44')
''')
