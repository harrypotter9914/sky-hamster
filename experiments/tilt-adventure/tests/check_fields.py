"""Real force response, fast/edge contact and a purposeful wind-dial traversal."""
from pathlib import Path
f=Path(__file__).with_name('check_tilt.py');s=f.read_text();env={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0]+"load('engine')",str(f),'exec'),env)
lua=env['lua'];lua.execute('function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute("""
local fans,magnets,edges=0,0,0
for _,c in ipairs(Courses) do
 Curriculum.ensure(c)
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='fan' then
   fans=fans+1;local r=m.region
   for _,tile in ipairs(c.tiles) do
    if math.abs(tile.x*32+16-r[1])<16 then
     local y=tile.y*32+16
     if math.abs(y-r[2])<160 then
      assert(WindContact.fraction(r,r[1],y,300,0,1/120)>0,'edge lane misses fan');edges=edges+1
     end
    end
   end
  elseif m.kind=='magnet' then
   magnets=magnets+1
   for _,tile in ipairs(c.tiles) do if math.abs(tile.x*32+16-m.x)<17 then
    local x,y=tile.x*32+16,tile.y*32+16;local d=((x-m.x)^2+(y-m.y)^2)^.5
    if d>10 and d<=184 then local a,b=WindContact.magnet(m,x,y,0,0,1/120)
     assert((a*a+b*b)^.5>25/120,'outer-road magnet too weak');edges=edges+1
    end
   end end
  end
 end
end
local m={x=0,y=0,radius=140}
local a,b=WindContact.magnet(m,-220,30,900,0,.5)
assert(a~=900 or b~=0,'whole-field fast sweep missed')
a,b=WindContact.magnet(m,210,0,0,0,.01);assert(a==0 and b==0,'force beyond field')
a,b=WindContact.magnet(m,183,0,0,0,1/120);assert(a<-.2 and b==0,'edge contact delayed')
assert(math.abs(a)<=121/120,'field entry caused an impulse instead of bounded acceleration')
local c=Courses[Courses.indexById['wind-dial']];local fan=c.mechanisms[1]
local function climb(speed,enabled,offset)
 Dock.reset(c);fan.angle=offset or 0;local x,y=224,80;local vx,vy=speed,0
 for i=1,1800 do
  if enabled then vx,vy=Mechanisms.wind(c,x,y,vx,vy,0,1/120,0) end
  local _,sx,sy=c:height(x,y);vx,vy=Physics.step(vx,vy,1,0,1,sx,sy,1/120)
  x,y=x+vx/120,y+vy/120
  if x>=480 then return true end
  if vx<=0 or y<41 or y>119 then return false end
 end
 return false
end
for _,v in ipairs({0,90,150,180}) do assert(not climb(v,false),'normal approach bypasses the wind climb');assert(climb(v,true),'tailwind cannot carry a normal approach') end
fan.angle=0;assert(WindContact.assistReady(fan));fan.angle=math.pi/2;assert(not WindContact.assistReady(fan));fan.angle=math.pi;assert(not WindContact.assistReady(fan))
-- Small crosswind acceleration remains counterable by normal tilt.
local vx,vy=0,0
for i=1,120 do vx,vy=Mechanisms.wind(c,300,80,vx,vy,0,1/120,0);vx,vy=Physics.step(vx,vy,-1,0,1,0,0,1/120) end
assert(vx<0,'player cannot counter the fan')
local saved={campaignRevision=4,level=53,completed={[53]=true},best={['2']=17,['34']=18,['53']=19},guides={jump=true,windcontrol=true,magnet=true},options={music=false}}
Courses.migrate(saved);assert(saved.campaignRevision==5 and saved.level==53 and saved.completed[53] and saved.options.music==false and saved.guides.jump)
assert(not saved.guides.windcontrol and not saved.guides.magnet and saved.best['2']==17 and not saved.best['53'])
local older={campaignRevision=3,level=53,completed={[53]=true},best={['2']=17,['21']=18,['48']=19},guides={jump=true,windcontrol=true,magnet=true},options={music=false}}
Courses.migrate(older);assert(older.campaignRevision==5 and older.level==53 and older.completed[53] and older.options.music==false)
assert(older.best['2']==17 and not older.best['21'] and not older.best['48'] and older.guides.jump and not older.guides.windcontrol)
print('PASS: '..fans..' wind zones, '..magnets..' magnets, '..edges..' road samples; fast sweep and immediate edge forces, bounded acceleration, counter-steering, purposeful ramp and save migration')
""")

lua.execute("""
local n=Courses.indexById['wind-dial'];selectReady(n);put('lesson',false);put('title',false);accel={0,0,1}
Tilt.startCalibration();for i=1,40 do frame() end
local c=Courses[n];local p=c.pads[1]
local function steer(tx,ty,want)
 for i=1,1800 do
  if get('state')=='win' then return end
  if want and Dock.active==want then return end
  local x,y,vx,vy=get('x'),get('y'),get('vx'),get('vy');local dx,dy=tx-x,ty-y;local d=(dx*dx+dy*dy)^.5
  if d<3 and vx*vx+vy*vy<64 then return end
  local speed=math.min(want and 24 or 55,d*1.8)
  local _,sx,sy=c:height(x,y);local fx,fy=Mechanisms.wind(c,x,y,0,0,0,.01,get('worldTime'))
  local ax=(dx/math.max(d,.01)*speed-vx)*5+sx*Physics.tuning.gravity-fx*100
  local ay=(dy/math.max(d,.01)*speed-vy)*5+sy*Physics.tuning.gravity-fy*100
  local f=(ax*ax+ay*ay)^.5;local mag=math.min(.98,f/Physics.tuning.drive)*.4+.045
  accel={ax/math.max(f,.01)*mag,ay/math.max(f,.01)*mag,math.sqrt(1-mag*mag)};frame()
  assert((get('state')=='play' or get('state')=='win') and not get('airborne'),'wind lesson fell or jumped')
 end
 error('wind lesson cannot reach '..tx..','..ty)
end
steer(p.x,p.y,p);assert(Dock.active==p)
accel={0,0,1};frame(nil,nil,-math.deg(p.angle));frame({b=true})
steer(544,80);steer(848,80)
assert(get('state')=='win' and get('falls')==0)
print('PASS: actual tilt, crank dial and B release complete the wind-climb lesson without forced velocity or jumping')
""")
