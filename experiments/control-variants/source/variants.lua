-- Newly reconstructed comparison prototypes, not original historical releases.
Variants={}
Variants.rules={
 speed={'01 SPEED DIAL','CW: raise speed. CCW: lower speed.','D-pad: direction. B: retry.',
  'Set a target speed with the crank.','The dial stays where you leave it.','Steering approaches the target velocity.'},
 throttle={'02 HELD THROTTLE','CW: more thrust. CCW: less thrust.','D-pad: push / reverse brake. B: retry.',
  'Set thrust; it remains after you stop.','Gravity still works with zero thrust.','Opposite direction adds strong braking.'},
 brake={'03 REVERSE BRAKE','CW: thrust. CCW: active brake.','D-pad: thrust direction. B: retry.',
  'Keep cranking clockwise to add thrust.','Stop cranking and thrust fades.','Crank backwards to slow without reversing.'},
 steering={'04 CRANK STEERING','Crank: turn heading. Hold A: thrust.','Release A: coast. B: retry.',
  'The crank turns your thrust heading.','Hold A to push; release A to coast.','The arrow shows direction on the track.'},
 latch={'05 POWER LATCH','CW: thrust. Stop: thrust fades.','D-pad: direction. B: retry.',
  'Keep cranking clockwise to add thrust.','High-power reversal clears the meter.','Crank again to build thrust; no brake boost.'}
}
function Variants.apply(id)
 local rule=assert(Variants.rules[id],'Unknown comparison rule')
 local baseStep,baseControls,baseNew=Physics.step,Physics.controls,Physics.newControls
 local active
 local function reduce(vx,vy,amount)
  local s=math.sqrt(vx*vx+vy*vy)
  if s==0 then return 0,0 end
  local f=math.max(0,s-amount)/s
  return vx*f,vy*f
 end
 function Physics.newControls()
  local c=baseNew();c.heading=0;c.brake=0;active=c;return c
 end
 function Physics.controls(c,crank,dx,dy,dt)
  active=c;c.brake=0
  if id=='latch' then
   local a,b=baseControls(c,math.max(0,crank),dx,dy,dt);c.charge=0;return a,b
  end
  local n=math.sqrt(dx*dx+dy*dy);if n>0 then dx,dy=dx/n,dy/n end
  c.flash=0;c.charge=0
  if id=='speed' or id=='throttle' then
   c.power=math.max(0,math.min(1,c.power+crank/540))
  elseif id=='steering' then
   c.heading=(c.heading+crank)%360
   c.power=playdate.buttonIsPressed(playdate.kButtonA) and 1 or 0
   dx,dy=math.cos(math.rad(c.heading)),math.sin(math.rad(c.heading))
  else
   -- No latch in this alternative. Braking is angle-driven, independent of FPS.
   c.lastX,c.lastY=dx,dy
   baseControls(c,math.max(0,crank),dx,dy,dt);c.charge=0
   if crank<0 then c.power=0;c.brake=math.min(300,-crank/math.max(dt,0.001)*0.6) end
  end
  return dx,dy
 end
 function Physics.step(vx,vy,dx,dy,p,sx,sy,dt)
  if id=='speed' then
   local n=math.sqrt(dx*dx+dy*dy)
   if n>0 then
    local ax,ay=dx/n*p*85-vx,dy/n*p*85-vy
    local len=math.sqrt(ax*ax+ay*ay)
    if len>0 then local f=math.min(1,80*dt/len);vx,vy=vx+ax*f,vy+ay*f end
   else vx,vy=reduce(vx,vy,9*dt) end
   return vx,vy,false
  end
  local braking=false
  if id=='throttle' and vx*dx+vy*dy<0 then
   vx,vy=reduce(vx,vy,240*dt);braking=true
  elseif id=='brake' and active and active.brake>0 then
   vx,vy=reduce(vx,vy,active.brake*dt);braking=true
  end
  local x,y,b=baseStep(vx,vy,dx,dy,p,sx,sy,dt)
  return x,y,braking or b
 end
 local baseHUD=UI.hud
 function UI.hud(course,level,jump,power,charge,elapsed,falls,speed)
  baseHUD(course,level,false,power,0,elapsed,falls,speed)
  local g=playdate.graphics
  g.setColor(g.kColorWhite);g.fillRect(0,0,260,21);g.fillRect(0,22,281,22);g.fillRect(0,204,400,36)
  g.setColor(g.kColorBlack);g.drawText(rule[1],5,2)
  g.drawText(id=='speed' and 'SPEED' or 'POWER',7,25);g.drawRect(67,28,86,8);g.fillRect(68,29,math.floor(power*84),6)
  if id=='latch' then g.drawLine(118,24,118,39)
  elseif id=='brake' and active and active.brake>0 then g.drawText('BRAKE',165,25)
  elseif id=='steering' and active then
   -- Use the same isometric projection as the track, not a screen-space compass.
   local a=math.rad(active.heading);local dx,dy=math.cos(a),math.sin(a)
   local ex,ey=212+14*(dx-dy),33+7*(dx+dy)
   g.drawLine(212,33,ex,ey);g.fillCircleAtPoint(ex,ey,2)
  end
  g.drawText(rule[2],5,204);g.drawText(rule[3],5,222)
 end
 function UI.lesson()
  UI.header(rule[1],'Same tracks. Different control rule.')
  local g=playdate.graphics
  for i=4,6 do g.drawText(rule[i],10,72+(i-4)*30) end
  g.drawText('A: start    B: level select',10,214)
 end
 -- Shared HUD creates this lazily. Pre-create an accurate variant-specific hint.
 local g=playdate.graphics
 UI.powerHint=g.image.new(226,24,g.kColorWhite)
 g.pushContext(UI.powerHint);g.setColor(g.kColorBlack);g.drawRect(0,0,226,24)
 g.drawText(id=='steering' and 'Hold A for POWER' or id=='speed' and 'Turn clockwise for SPEED' or 'Turn clockwise for POWER',5,3);g.popContext()
end
