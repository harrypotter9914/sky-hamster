"""Use real tilt dynamics for the revised introductory roads and cannon landing."""
from pathlib import Path
f=Path(__file__).with_name('check_tilt.py');s=f.read_text(encoding='utf-8');env={'__file__':str(f)}
exec(compile(s.split("load('engine')")[0]+"load('engine')",str(f),'exec'),env)
lua=env['lua'];lua.execute('function get(name)'+s.split('function get(name)',1)[1].split('for i=1,40 do frame() end',1)[0])
lua.execute('''
local function begin(id)
 selectReady(Courses.indexById[id]);put('lesson',false);put('title',false);accel={0,0,1}
 Tilt.startCalibration();for i=1,40 do frame() end
 return Courses[Courses.indexById[id]]
end
local function steer(c,tx,ty)
 for i=1,1800 do
  if get('state')=='win' then return end
  local x,y,vx,vy=get('x'),get('y'),get('vx'),get('vy')
  local dx,dy=tx-x,ty-y;local d=math.sqrt(dx*dx+dy*dy)
  if d<3 and vx*vx+vy*vy<64 then return end
  local v=math.min(52,d*1.8);local _,sx,sy=c:height(x,y)
  local ax=(dx/math.max(d,.01)*v-vx)*5+sx*Physics.tuning.gravity
  local ay=(dy/math.max(d,.01)*v-vy)*5+sy*Physics.tuning.gravity
  local f=math.sqrt(ax*ax+ay*ay);local mag=math.min(.92,f/Physics.tuning.drive)*.4+.045
  accel={ax/math.max(f,.01)*mag,ay/math.max(f,.01)*mag,math.sqrt(1-mag*mag)};frame()
  assert((get('state')=='play' or get('state')=='win') and not get('airborne'),'introductory road requires a jump '..c.id..':'..x..','..y)
 end
 error('unreachable teaching waypoint '..c.id..':'..tx..','..ty)
end
local routes={
 {'legacy-1',{{112,48},{288,64},{288,144},{416,144},{416,48},{544,48}}},
 {'legacy-4',{{288,64},{352,64},{352,208},{560,208}}},
 {'switchback',{{528,48},{528,336},{144,336},{144,176},{400,176}}}
}
for _,r in ipairs(routes) do
 local c=begin(r[1]);for _,p in ipairs(r[2]) do steer(c,p[1],p[2]) end
 assert(get('state')=='win' and get('falls')==0,'incomplete revised teaching road '..c.id)
end
local c=begin('legacy-16');local p=c.pads[1]
steer(c,p.x,p.y);assert(Dock.active==p,'cannon teaching does not dock')
accel={0,0,1};frame(nil,nil,-math.deg(p.angle));frame({a=true});assert(get('airborne'))
for i=1,90 do if not get('airborne') then break end;frame() end
steer(c,c.goal[1],c.goal[2]);assert(get('state')=='win' and get('falls')==0)
print('PASS: revised first course, brake bend, terrace switchback and cannon lesson completed with accelerometer input and real inertia; no forced velocities')
''')
