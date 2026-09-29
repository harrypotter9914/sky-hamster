WindContact={gain=1.28}
local function axis(p,d,a,b,lo,hi)
 if math.abs(d)<.0000001 then if p<a or p>b then return 1,0 end;return lo,hi end
 local u,v=(a-p)/d,(b-p)/d;if u>v then u,v=v,u end
 return math.max(lo,u),math.min(hi,v)
end
-- Swept overlap catches fast entries without making a full-frame gust impulse.
function WindContact.fraction(r,x,y,vx,vy,dt)
 local margin=Footing.radius
 local lo,hi=axis(x,vx*dt,r[1]-r[3]/2-margin,r[1]+r[3]/2+margin,0,1)
 if hi<lo then return 0 end
 lo,hi=axis(y,vy*dt,r[2]-r[4]/2-margin,r[2]+r[4]/2+margin,lo,hi)
 return math.max(0,hi-lo)
end

-- Geometry preparation only; never scan road tiles during a physics substep.
function WindContact.prepare(c)
 if c.fieldsPrepared then return end
 c.fieldsPrepared=true
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='fan' and m.region then
   local r=m.region;local low,high=r[2]-r[4]/2,r[2]+r[4]/2
   for tx=math.floor((r[1]-r[3]/2)/32),math.floor((r[1]+r[3]/2-.001)/32) do
    local ty=math.floor(r[2]/32)
    if c.lookup[tx..','..ty] then
     local a,b=ty,ty
     while c.lookup[tx..','..(a-1)] do a=a-1 end
     while c.lookup[tx..','..(b+1)] do b=b+1 end
     low=math.min(low,a*32);high=math.max(high,(b+1)*32)
    end
   end
   r[2],r[4]=(low+high)/2,high-low
  elseif m.kind=='magnet' then m.fieldRadius=math.max(m.radius or 140,184) end
 end
end
function WindContact.circle(m,x,y,vx,vy,dt)
 local radius=(m.fieldRadius or math.max(m.radius or 140,184))+Footing.radius
 local px,py=x-m.x,y-m.y;local dx,dy=vx*dt,vy*dt
 local a=dx*dx+dy*dy;local c=px*px+py*py-radius*radius
 if a<.0000001 then if c<=0 then return 1,x,y end;return 0,x,y end
 local b=px*dx+py*dy;local disc=b*b-a*c
 if disc<0 then return 0,x,y end
 local root=math.sqrt(disc);local lo=math.max(0,(-b-root)/a);local hi=math.min(1,(-b+root)/a)
 if hi<=lo then return 0,x,y end
 local mid=(lo+hi)/2
 return hi-lo,x+dx*mid,y+dy*mid
end
function WindContact.magnet(m,x,y,vx,vy,dt)
 local fraction,px,py=WindContact.circle(m,x,y,vx,vy,dt)
 if fraction<=0 then return vx,vy end
 local dx,dy=m.x-px,m.y-py;local d=math.sqrt(dx*dx+dy*dy)
 if d<=10 then return vx,vy end
 local radius=m.fieldRadius or math.max(m.radius or 140,184)
 local edge=math.max(0,math.min(1,(radius+Footing.radius-d)/16))
 local strength=(m.force or 121)*(.6+.4*math.max(0,1-d/radius))*edge
 local impulse=strength*dt*fraction
 return vx+dx/d*impulse,vy+dy/d*impulse
end
for _,c in ipairs(Courses) do if not c.blueprint then WindContact.prepare(c) end end

function WindContact.assistReady(m)
 if not m.assistAngle then return nil end
 local forward=math.cos((m.angle or 0)-m.assistAngle)*(m.force or 65)*WindContact.gain
 return forward+Physics.tuning.drive-m.assistSlope*Physics.tuning.gravity>Physics.tuning.friction+16
end
-- Sparse ground arrows show the actual influence band without another HUD panel.
function WindContact.draw(c,t,project)
 local g=playdate.graphics
 local function arrow(x,y,dx,dy)
  if not c.lookup[math.floor(x/32)..','..math.floor(y/32)] then return end
  local z=c:height(x,y);local sx,sy=project(x,y,z)
  if sx<6 or sx>394 or sy<48 or sy>196 then return end
  local px,py=project(x+dx*10,y+dy*10,z);local ux,uy=px-sx,py-sy
  g.setColor(g.kColorBlack);g.drawLine(sx,sy,px,py)
  g.drawLine(px,py,px-ux*.4-uy*.35,py-uy*.4+ux*.35)
  g.drawLine(px,py,px-ux*.4+uy*.35,py-uy*.4-ux*.35)
 end
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='fan' and m.region then
   local r=m.region;local dx,dy=math.cos(m.angle or 0),math.sin(m.angle or 0)
   local phase=(t*14)%12-6
   for _,u in ipairs({-.28,.28}) do for _,v in ipairs({-.28,.28}) do
    arrow(r[1]+r[3]*u+dx*phase,r[2]+r[4]*v+dy*phase,dx,dy)
   end end
  elseif m.kind=='magnet' then
   local radius=(m.fieldRadius or 184)*.72
   for i=0,5 do
    local a=i*math.pi/3;local dx,dy=math.cos(a),math.sin(a);local d=radius-((t*18)%12)
    arrow(m.x+dx*d,m.y+dy*d,-dx,-dy)
   end
  end
 end
end
