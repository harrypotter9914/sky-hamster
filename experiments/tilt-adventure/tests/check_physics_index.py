from check_animation import lua
lua.execute('''
local P=PhysicsIndex
local function same(a,b) return a==b or (type(a)=='number' and type(b)=='number' and math.abs(a-b)<.00001) end
local function compare(f,g,c,x,y,...)
 local a,b={f(c,x,y,...)},{g(c,x,y,...)}
 for i=1,math.max(#a,#b) do assert(same(a[i],b[i]),'indexed query mismatch '..c.name..' at '..x..','..y..' result '..i) end
end
for _,c in ipairs(Courses) do
 Dock.reset(c)
 for _,m in ipairs(c.mechanisms or {}) do
  for _,t in ipairs({0,1.7,4.4,7.9}) do
   local mx,my=Mechanisms.pose(m,t)
   for _,offset in ipairs({{0,0},{-40,0},{40,0},{0,-90},{0,90},{200,0},{-200,0}}) do
    local x,y=mx+offset[1],my+offset[2]
    compare(Mechanisms.support,P.reference.support,c,x,y,t)
    compare(Mechanisms.collide,P.reference.collide,c,x,y,100,20,0,t,.01)
    compare(Mechanisms.wind,P.reference.wind,c,x,y,100,20,0,.01,t)
    compare(Spatial.sides,P.reference.sides,c,x,y,100,20,c:height(x,y)-10,t)
   end
  end
 end
end
print('PASS: nearby-physics queries match full-course reference across 44 routes, moving endpoints, phases and offset positions')
''')
