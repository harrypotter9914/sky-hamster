from pathlib import Path
root=Path(__file__).resolve().parents[1]
bootstrap=(root/'tests/run_checks.py').read_text().split("load('main')",1)[0]
for rule in ('reverse','track','lock','absolute'):
 env={'__file__':str(root/'tests/run_checks.py')};exec(bootstrap,env)
 lua,load=env['lua'],env['load'];load('build')
 lua.execute(f"Build.classroom=true;Build.variant='{rule}';angle=0;playdate.getCrankPosition=function() return angle end")
 load('main')
 lua.execute('''
 function state(name,value)
  for i=1,100 do local n,v=debug.getupvalue(playdate.update,i);if n==name then
   if value~=nil then debug.setupvalue(playdate.update,i,value) end;return v end end
  error(name)
 end
 frame({a=true});assert(not state('lesson'))
 c=Physics.newControls()
 ''')
 if rule=='absolute':
  lua.execute('''
  held={a=true};angle=90
  local dx,dy=Physics.controls(c,0,0,0,1/30)
  assert(dx>0 and dy<0 and math.abs(dx+dy)<0.001,'90 degrees points screen right')
  local vx,vy=0,0
  for i=1,30 do vx,vy=Physics.step(vx,vy,dx,dy,c.power,0,0,1/30) end
  local first=math.sqrt(vx*vx+vy*vy)
  for i=1,30 do vx,vy=Physics.step(vx,vy,dx,dy,c.power,0,0,1/30) end
  assert(math.sqrt(vx*vx+vy*vy)>first,'holding longer increases speed')
  held={};angle=270;dx,dy=Physics.controls(c,0,0,0,1/30)
  local before=vx;vx,vy=Physics.step(vx,vy,dx,dy,c.power,0,0,1/30)
  assert(vx>before*0.95 and vy<0,'release preserves velocity despite changing heading')
  local fresh=Physics.newControls();local x,y=Physics.controls(fresh,0,0,0,1/30)
  assert(x<0 and y>0,'absolute heading survives reset')
  frame({}, {a=true},0);frame();assert(state('vx')^2+state('vy')^2>0,'real update coasts')
  ''')
 elif rule=='reverse':
  lua.execute('''
  local dx,dy=Physics.controls(c,-360,1,0,1/30)
  local v=40;for i=1,120 do v=Physics.step(v,0,dx,dy,c.power,0,0,1/120) end
  assert(v<0,'reverse thrust passes through zero and moves backwards')
  Physics.controls(c,0,1,0,2);assert(c.power==0,'signed force decays')
  frame({}, {right=true},-90);assert(state('vx')<0,'real negative crank reaches controls')
  ''')
 elif rule=='lock':
  lua.execute('''
  Physics.controls(c,270,1,0,1/30)
  local dx,dy=Physics.controls(c,0,0,1,0.01)
  assert(dx==1 and dy==0 and c.power>0,'perpendicular turn locked')
  dx,dy=Physics.controls(c,0,-1,0,0.01);assert(dx==1,'reverse also locked')
  dx,dy=Physics.controls(c,0,0,1,2);assert(c.power==0 and dy==1,'zero unlocks heading')
  ''')
 else:
  lua.execute('''
  assert(#Courses==1);local course=Courses[1];local m=course.mechanisms[1]
  local _,_,a=Mechanisms.pose(m,0);local _,_,b=Mechanisms.pose(m,100)
  assert(a==b,'manual bridge never auto-rotates')
  assert(not Mechanisms.support(course,160,80,0),'initial gap blocks passage')
  ExtraVariants.context(course,48,80,0,0);held={a=true};Physics.controls(c,-90,0,0,1/30)
  assert(m.angle==a,'cannot rotate outside station')
  ExtraVariants.context(course,80,80,0,0);Physics.controls(c,-90,0,0,1/30)
  assert(math.abs(m.angle)<0.001,'station rotates bridge')
  for x=48,432,2 do assert(Mechanisms.support(course,x,80,0),'continuous connected route') end
  -- Actual input path can park, edit, coast across, and finish.
  state('x',80);state('y',80);frame({}, {a=true},90)
  frame({}, {a=true},-90)
  state('x',120);state('vx',100)
  for i=1,240 do frame({}, {right=true},10);if state('state')=='win' then break end end
  assert(state('state')=='win','manual bridge can be completed through real update')
  frame({b=true});assert(math.abs(m.angle-math.pi/2)<0.001,'retry resets bridge')
  ''')
 print('PASS:',rule)
