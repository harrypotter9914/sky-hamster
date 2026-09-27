MachineArt={time=0}
local A=MachineArt
local g=playdate.graphics
local images,gears,blades,springs={},{},{},{}
function A.prepare()
 if images.roller then return end
 for _,name in ipairs({'roller','nozzle','winch','switch','magnet','gear','blade'}) do images[name]=g.image.new('detail-'..name) end
 for i=0,15 do
  local im=g.image.new(26,26,g.kColorClear);g.pushContext(im);images.gear:drawRotated(13,13,i*22.5);g.popContext();gears[i]=im
 end
 for i=0,7 do
  local im=g.image.new(28,28,g.kColorClear);g.pushContext(im);images.blade:drawRotated(14,14,i*15);g.popContext();blades[i]=im
 end
 local spring=g.image.new('machine-bumper')
 for i=0,7 do local sy=1-i*.045;local im=g.image.new(44,44,g.kColorClear);g.pushContext(im);spring:drawScaled(0,44-44*sy,1,sy);g.popContext();springs[i]=im end
end
function A.sprite(name,x,y) local im=images[name];local w,h=im:getSize();im:draw(math.floor(x-w/2),math.floor(y-h)) end
function A.gear(x,y,angle) gears[math.floor((angle or 0)/22.5)%16]:draw(x-13,y-13) end
function A.handle(x,y,angle)
 local a=math.rad(angle or 0);local px,py=x+math.cos(a)*10,y+math.sin(a)*5
 g.setColor(g.kColorBlack);g.setLineWidth(3);g.drawLine(x,y,px,py);g.setLineWidth(1)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(px,py,3);g.setColor(g.kColorBlack);g.drawCircleAtPoint(px,py,3)
end
function A.bumper(m,t,x,y)
 local age=m.hitAt and t-m.hitAt or 10
 local squash=age>=0 and age<.5 and math.max(0,math.sin(age/.5*math.pi*3)*math.exp(-age*4)) or 0
 springs[math.floor(squash*7+.5)]:draw(x-22,y-36)
end
function A.fan(m,t,x,y)
 g.setColor(g.kColorBlack);g.fillCircleAtPoint(x+2,y-25,14)
 blades[math.floor(t*18)%8]:draw(x-12,y-39)
 g.setColor(g.kColorWhite);g.drawCircleAtPoint(x+2,y-25,14);g.setColor(g.kColorBlack);g.drawCircleAtPoint(x+2,y-25,15)
 local dx,dy=math.cos(m.angle or 0),math.sin(m.angle or 0);local ux,uy=(dx-dy)*.9,(dx+dy)*.45
 for lane=-1,1 do
  local d=18+(t*36+lane*19)%72;local px,py=x+ux*d-lane*uy*7,y+uy*d-16+lane*ux*7
  for j=1,5 do local nx,ny=x+ux*(d+j*3)-lane*uy*7,y+uy*(d+j*3)-16+lane*ux*7+math.sin(t*4+j*.8+lane)*2;g.drawLine(px,py,nx,ny);px,py=nx,ny end
 end
end
local M,D=Mechanisms,Dock
local previousOpen=M.open
local function ease(v) v=math.max(0,math.min(1,v));return v*v*(3-2*v) end
function M.wallHeight(m,t)
 local full=m.wallHeight or 80
 if m.kind~='gate' then return full end
 if m.switchGate then
  local target=m.isOpen and 0 or full
  if not m.transitionAt then return target end
  return (m.transitionFrom or target)+(target-(m.transitionFrom or target))*ease((t-m.transitionAt)/.24)
 end
 local u=((t+(m.phase or 0))%m.period)/m.period;local window=m.openFor or .45
 if window==0 then return full end
 if u<window then return 0 end
 return full*math.min(ease((u-window)/.06),ease((1-u)/.06))
end
function M.open(m,t) if m.kind=='gate' then return M.wallHeight(m,t)<=.5 end return previousOpen(m,t) end
local reset,update,draw=D.reset,D.update,M.draw
function D.reset(c)
 reset(c)
 for _,p in ipairs(c.pads or {}) do p.spin=0;p.fireAt=nil end
 for _,m in ipairs(c.mechanisms or {}) do m.spin=0;m.hitAt=nil;m.transitionAt=nil end
end
function D.update(c,x,y,vx,vy,airborne,crank,a,b)
 local previous=D.active
 local candidate=previous
 if not candidate and not airborne and vx*vx+vy*vy<35^2 then for _,p in ipairs(c.pads or {}) do if p.kind=='switch' and p~=D.blocked and (x-p.x)^2+(y-p.y)^2<17^2 then candidate=p;break end end end
 local gate=candidate and candidate.kind=='switch' and candidate.target
 local oldState=gate and gate.isOpen
 local oldHeight=gate and M.wallHeight(gate,A.time)
 local partnerHeight=gate and M.wallHeight(gate.partner,A.time)
 local result=update(c,x,y,vx,vy,airborne,crank,a,b)
 local p=D.active
 if p and result and result.locked then
  p.spin=(p.spin or 0)+crank
  if p.target then p.target.spin=p.spin end
 end
 if previous and result and result.launch then previous.fireAt=A.time end
 if gate and gate.isOpen~=oldState then
  gate.transitionAt=A.time;gate.transitionFrom=oldHeight
  gate.partner.transitionAt=A.time;gate.partner.transitionFrom=partnerHeight
 end
 return result
end
function M.draw(c,t,project)
 draw(c,t,project)
 for _,m in ipairs(c.mechanisms or {}) do
  local cx,cy,angle=M.pose(m,t);local h=m.kind=='lift' and m.elevation or c:height(cx,cy)
  local x,y=project(cx,cy,h)
  if x>-100 and x<500 and y>-80 and y<290 then
   if m.kind=='lift' then A.gear(x-33,y-22,m.spin);A.handle(x-33,y-22,m.spin)
   elseif m.kind=='ferry' then A.gear(x+20,y-23,m.manual and m.spin or ((cx-m.x)+(cy-m.y))*2)
   elseif m.kind=='rotor' and not m.retract then A.gear(x,y-3,math.deg(angle))
   elseif m.kind=='sweeper' then A.gear(x,y-(m.wallHeight or 80)*.65+2,(cy-m.y)*3)
   elseif m.kind=='gate' then A.gear(x-15,y-8,M.wallHeight(m,t)*3)
   elseif m.kind=='trap' then
    local warning=M.warning(m,t);g.setColor(g.kColorBlack)
    if warning then for i=-1,1 do g.fillCircleAtPoint(x+i*8,y-8,((math.floor(t*8)+i)%2)+1) end end
   end
  end
 end
end
local drawStations=D.draw
function D.draw(c,project)
 drawStations(c,project)
 local t=A.time
 for _,p in ipairs(c.pads or {}) do
  local roughX,roughY=project(p.x,p.y,c:height(p.x,p.y))
  if roughX>-80 and roughX<480 and roughY>-140 and roughY<410 then
  local x,y=project(p.x,p.y,M.floor(c,p.x,p.y,t))
  if x>-70 and x<470 and y>25 and y<255 then
   if p.kind=='extend' then A.sprite('winch',x-22,y-3);A.gear(x-25,y-27,p.spin);A.handle(x-25,y-27,p.spin)
   elseif p.kind=='switch' then A.sprite('switch',x-22,y-3);A.handle(x-24,y-33,p.spin)
   end
   local age=p.fireAt and t-p.fireAt or 10
   if p.kind=='cannon' and age>=0 and age<.35 then
    local dx,dy=math.cos(p.angle or 0),math.sin(p.angle or 0)
    local ux,uy=(dx-dy)*.9,(dx+dy)*.45-.75;local length=math.sqrt(ux*ux+uy*uy)
    g.setColor(g.kColorBlack);for i=1,3 do local d=28+i*6+age*35;g.drawCircleAtPoint(x+ux/length*d,y-47+uy/length*d,2+age*10) end
   end
  end
  end
 end
end
A.prepare()
