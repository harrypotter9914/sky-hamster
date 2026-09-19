ExtraVariants={}
local E=ExtraVariants
E.rules={
 reverse={'Variation 6','CW: forward. CCW: reverse thrust.','D-pad: axis. B: retry.', 'Reverse thrust slows, then backs up.','Stop cranking and thrust fades.'},
 track={'Variation 7','At CONTROL: hold A + turn crank.','Else: CW thrust / D-pad. B: retry.','Stop on CONTROL and rotate the bridge.','Release A, then roll across to GOAL.'},
 lock={'Variation 8','CW: thrust. Stop until bar is zero.','Direction locked above zero. B: retry.','Choose a direction before adding thrust.','Wait for zero before changing direction.'},
 absolute={'Variation 9','Crank position: direction. Hold A: push.','Hold longer: faster. Release A: coast.','Crank position sets thrust direction.','Hold A to accelerate; release to coast.'}
}
function E.context(course,x,y,vx,vy)
 E.course=course
 E.station=course.station and (x-course.station[1])^2+(y-course.station[2])^2<=22^2 and vx*vx+vy*vy<225
end
function E.apply(id)
 E.active=id
 local rule=E.rules[id]
 local new,control,step,hud=Physics.newControls,Physics.controls,Physics.step,UI.hud
 local current
 if id=='track' then
  local original=Classroom.apply
  function Classroom.apply()
   original();local c=Courses[1]
   c.name='01 / MANUAL BRIDGE';c.shortName='Manual bridge';c.tiles={};c.lookup={}
   c.start={48,80};c.station={80,80};c.goal={432,80};c.profile={{0,0},{600,0}}
   c:rect(0,3,1,3);c:rect(11,14,1,3)
   c.mechanisms={{kind='rotor',manual=true,angle=math.pi/2,x=240,y=80,w=240,h=64}}
   Courses={c}
  end
  local pose=Mechanisms.pose
  function Mechanisms.pose(m,t) if m.manual then return m.x,m.y,m.angle end return pose(m,t) end
 end
 function Physics.newControls()
  local c=new();c.signed=0;c.lockX=0;c.lockY=0;c.heading=0;current=c
  if id=='track' then for _,course in ipairs(Courses) do for _,m in ipairs(course.mechanisms or {}) do if m.manual then m.angle=math.pi/2 end end end end
  return c
 end
 function Physics.controls(c,crank,dx,dy,dt)
  current=c;c.flash=0;c.charge=0
  local n=math.sqrt(dx*dx+dy*dy);if n>0 then dx,dy=dx/n,dy/n end
  if id=='reverse' then
   if crank~=0 then c.signed=math.max(-1,math.min(1,c.signed+crank/360))
   else c.signed=(c.signed<0 and -1 or 1)*math.max(0,math.abs(c.signed)-1.4*dt) end
   c.power=math.abs(c.signed);if c.signed<0 then dx,dy=-dx,-dy end
  elseif id=='lock' then
   if c.power<=0.00001 then c.lockX,c.lockY=dx,dy end
   c.lastX,c.lastY=c.lockX,c.lockY
   control(c,math.max(0,crank),c.lockX,c.lockY,dt);c.charge=0
   if c.power<=0.00001 then c.lockX,c.lockY=dx,dy end
   dx,dy=c.lockX,c.lockY
  elseif id=='absolute' then
   local a=math.rad(playdate.getCrankPosition())
   -- Physical 0=up, 90=right; invert the isometric screen projection.
   local sx,sy=math.sin(a),-math.cos(a)
   dx,dy=sx/1.8+sy/0.9,-sx/1.8+sy/0.9
   n=math.sqrt(dx*dx+dy*dy);dx,dy=dx/n,dy/n
   c.heading=math.deg(math.atan(dy,dx));c.power=playdate.buttonIsPressed(playdate.kButtonA) and 1 or 0
  else
   c.editing=E.station and playdate.buttonIsPressed(playdate.kButtonA)
   if c.editing then
    for _,m in ipairs(E.course.mechanisms) do m.angle=(m.angle+math.rad(crank))%(math.pi*2) end
    c.power=0;return 0,0
   end
   c.lastX,c.lastY=dx,dy;control(c,math.max(0,crank),dx,dy,dt);c.charge=0
  end
  return dx,dy
 end
 function Physics.step(vx,vy,dx,dy,p,sx,sy,dt)
  if id=='absolute' then
   return step(vx,vy,dx,dy,p,sx,sy,dt)
  end
  if id=='track' and current and current.editing then return 0,0,false end
  return step(vx,vy,dx,dy,p,sx,sy,dt)
 end
 function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
  hud(course,level,false,power,0,elapsed,falls,speed)
  local g=playdate.graphics
  g.setColor(g.kColorWhite);g.fillRect(0,0,260,21);g.fillRect(0,22,281,22);g.fillRect(0,204,400,36)
  g.setColor(g.kColorBlack);g.drawText(rule[1],5,2);g.drawText('POWER',7,25)
  g.drawRect(67,28,86,8);g.fillRect(68,29,math.floor(power*84),6)
  if id=='absolute' and current then
   local a=math.rad(current.heading);local dx,dy=math.cos(a),math.sin(a)
   local x,y=212+14*(dx-dy),33+7*(dx+dy);g.drawLine(212,33,x,y);g.fillCircleAtPoint(x,y,2)
  elseif id=='reverse' and current then g.drawText(current.signed<0 and 'REVERSE' or 'FORWARD',165,25)
  elseif id=='lock' then g.drawText(power>0 and 'LOCKED' or 'FREE',165,25)
  elseif id=='track' then g.drawText(current and current.editing and 'ROTATING' or E.station and 'HOLD A' or 'ROLL',165,25) end
  g.drawText(rule[2],5,204);g.drawText(rule[3],5,222)
 end
 function UI.lesson()
  UI.header(rule[1],id=='track' and 'Park, connect the bridge, cross.' or 'Control rule experiment')
  local g=playdate.graphics
  g.drawText(rule[4],10,80);g.drawText(rule[5],10,112);g.drawText('A: start    B: level select',10,214)
 end
 local g=playdate.graphics;UI.powerHint=g.image.new(226,24,g.kColorWhite)
 g.pushContext(UI.powerHint);g.setColor(g.kColorBlack);g.drawRect(0,0,226,24)
 g.drawText(id=='absolute' and 'Hold A for POWER' or 'Turn crank for POWER',5,3);g.popContext()
end
