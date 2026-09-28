-- Ground support follows the marble footprint, not only its centre pixel.
Footing={radius=9}
local F=Footing
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
function F.solid(m,t)
 return m.kind=='lift' or m.kind=='ferry' or m.kind=='rotor' or (m.kind=='trap' and not Mechanisms.open(m,t))
end
function F.nearest(m,x,y,t)
 local cx,cy,a=Mechanisms.pose(m,t);local dx,dy=x-cx,y-cy
 local co,si,u,v=1,0,dx,dy
 if a~=0 then co,si=math.cos(a),math.sin(a);u,v=dx*co+dy*si,-dx*si+dy*co end
 local hw,hh=m.w/2,m.h/2
 if u>=-hw and u<=hw and v>=-hh and v<=hh then return 0,x,y end
 local pu=u<-hw and -hw or u>hw and hw or u
 local pv=v<-hh and -hh or v>hh and hh or v
 return (u-pu)^2+(v-pv)^2,cx+pu*co-pv*si,cy+pu*si+pv*co
end
function F.query(c,x,y,t)
 local list=c.mechanisms or {}
 local best,bm,bx,by=F.radius^2+.0001,nil,nil,nil
 -- Centre support has priority over the small overhang allowance.
 for pass=1,2 do for _,m in ipairs(list) do
  if (pass==1 and m.kind=='lift') or (pass==2 and m.kind~='lift' and F.solid(m,t)) then
   local d,px,py=F.nearest(m,x,y,t)
   if d<.00000001 then return true,m,m.kind=='lift' and (m.elevation or m.minHeight or 0) or c:height(px,py) end
   if d<best then best,bm,bx,by=d,m,px,py end
  end
 end end
 local tx,ty=math.floor(x/32),math.floor(y/32)
 if c.lookup and c.lookup[tx..','..ty] then return true,nil,c:height(x,y) end
 for i=tx-1,tx+1 do for j=ty-1,ty+1 do
  if c.lookup and c.lookup[i..','..j] then
   local px,py=clamp(x,i*32,(i+1)*32-.000001),clamp(y,j*32,(j+1)*32-.000001)
   local d=(x-px)^2+(y-py)^2
   if d<best then best,bm,bx,by=d,nil,px,py end
  end
 end end
 if bx then return true,bm,bm and bm.kind=='lift' and (bm.elevation or bm.minHeight or 0) or c:height(bx,by) end
 return false,nil,c:height(x,y)
end
