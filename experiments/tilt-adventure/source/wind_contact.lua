WindContact={gain=1.08}
local function axis(p,d,a,b,lo,hi)
 if math.abs(d)<.0000001 then if p<a or p>b then return 1,0 end;return lo,hi end
 local u,v=(a-p)/d,(b-p)/d;if u>v then u,v=v,u end
 return math.max(lo,u),math.min(hi,v)
end
-- Swept overlap catches fast entries without making a full-frame gust impulse.
function WindContact.fraction(r,x,y,vx,vy,dt)
 local margin=Footing.radius*.5
 local lo,hi=axis(x,vx*dt,r[1]-r[3]/2-margin,r[1]+r[3]/2+margin,0,1)
 if hi<lo then return 0 end
 lo,hi=axis(y,vy*dt,r[2]-r[4]/2-margin,r[2]+r[4]/2+margin,lo,hi)
 return math.max(0,hi-lo)
end
