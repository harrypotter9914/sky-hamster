-- Flatten the historical pose wrappers and share one exact pose during rendering.
Pose={reference=Mechanisms.pose}
local P,M=Pose,Mechanisms
local active,time,epoch=false,0,0
function P.begin(t) active=true;time=t;epoch=epoch+1 end
function P.finish() active=false end
local function calculate(m,t)
 if m.retract then return m.anchor+m.w/2,m.y,0 end
 if m.kind=='lift' then return m.x,m.y,0 end
 if m.kind=='ferry' and m.manual then local u=m.progress or 0;return m.x+(m.toX-m.x)*u,m.y+(m.toY-m.y)*u,0 end
 if m.manual then return m.x,m.y,m.angle or 0 end
 if m.kind=='ferry' then local u=M.travel(t,m.period or 10,m.phase);return m.x+(m.toX-m.x)*u,m.y+(m.toY-m.y)*u,0 end
 if m.kind=='rotor' then return m.x,m.y,(m.angle or 0)+M.travel(t,m.period or 10,m.phase)*math.pi end
 if m.kind=='sweeper' then return m.x,m.y+math.sin((t+(m.phase or 0))*math.pi*2/m.period)*m.range,0 end
 return m.x,m.y,0
end
function M.pose(m,t)
 if not active or t~=time then
  local x,y,a=calculate(m,t)
  if m.joinSpan or m.turnSquare then m.w=Joinery.width(m,a) end
  return x,y,a
 end
 if m.poseEpoch~=epoch then
  m.poseX,m.poseY,m.poseAngle=calculate(m,t);m.poseEpoch=epoch
  if m.joinSpan or m.turnSquare then m.w=Joinery.width(m,m.poseAngle) end
 end
 return m.poseX,m.poseY,m.poseAngle
end
