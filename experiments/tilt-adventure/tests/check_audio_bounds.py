"""Hearing culling must preserve audible loops and event decisions."""
from check_audio_loading import lua

lua.execute('''
local S=MechanismAudio
local count=0
for _,c in ipairs(Courses) do
 S.reset(c)
 for _,s in ipairs(S.states) do
  local m=s.m
  for step=0,16 do
   local t=step/16*(m.period or 12)
   local x,y=Mechanisms.pose(m,t)
   local r=math.max(m.w,m.h)/2+219.9
   for _,d in ipairs({{r,0},{-r,0},{0,r},{0,-r}}) do
    assert(x+d[1]>=s.x0 and x+d[1]<=s.x1 and y+d[2]>=s.y0 and y+d[2]<=s.y1,'hearing bound excludes '..m.kind)
    count=count+1
   end
  end
  if m.region then
   local r=m.region
   assert(r[1]-r[3]/2>=s.x0 and r[1]+r[3]/2<=s.x1 and r[2]-r[4]/2>=s.y0 and r[2]+r[4]/2<=s.y1)
  end
 end
end
local function trace(c,unculled)
 S.reset(c);Dock.active=nil
 if unculled then for _,s in ipairs(S.states) do s.x0=-1e9;s.x1=1e9;s.y0=-1e9;s.y1=1e9 end end
 local out={}
 for frame=1,180 do
  local x=2128+frame*3
  if frame>=70 and frame<=90 then x=50000 end
  S.update(c,x,112,frame/30,1/30,true,false,0)
  for _,v in ipairs(S.loops) do out[#out+1]=v.want;out[#out+1]=v.volume end
  for _,name in ipairs({'gate_open','gate_close','trap_open','trap_close','jet_on','jet_off','stop','warning','magnet_contact','belt_contact'}) do
   out[#out+1]=S.shots[name].last
  end
 end
 return out
end
for _,c in ipairs(Courses) do
 local reference=trace(c,true);local filtered=trace(c,false)
 for i,v in ipairs(reference) do assert(math.abs(v-filtered[i])<.00001,'hearing changed audio in course '..c.name..' at '..i) end
end
print('PASS: '..count..' swept hearing-bound checks; '..#Courses..' course audio traces match unculled reference, including distant exit/re-entry')
''')
