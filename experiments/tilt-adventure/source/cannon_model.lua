-- A small orthographic solid, rasterized once per aim angle, not a spun sprite.
CannonModel={speed=210,exitTime=.16,gravity=300,initialV=150,ballCenter=12/.65}
local C,g=CannonModel,playdate.graphics
C.forward=C.speed*C.exitTime
C.bottom=C.initialV*C.exitTime-C.gravity*C.exitTime*C.exitTime/2
C.vertical=C.initialV-C.gravity*C.exitTime
C.pitch=C.vertical/C.speed
C.pivot=C.bottom+C.ballCenter-C.forward*C.pitch
function C.muzzle(angle)
 return C.forward*math.cos(angle),C.forward*math.sin(angle),C.bottom+C.ballCenter
end
function C.project(x,y,z) return (x-y)*.9,(x+y)*.45-z*.65 end
function C.direction(angle) return C.project(math.cos(angle),math.sin(angle),C.pitch) end
local function poly(points,color)
 g.setColor(color);g.fillPolygon(table.unpack(points))
end
local function ring(angle,along,radius)
 local c,s=math.cos(angle),math.sin(angle)
 local norm=math.sqrt(1+C.pitch*C.pitch)
 local p={}
 for i=0,23 do
  local a=i*math.pi/12;local side=radius*math.cos(a);local up=radius*math.sin(a)/norm
  local x,y,z=along*c-side*s-up*C.pitch*c,along*s+side*c-up*C.pitch*s,C.pivot+along*C.pitch+up
  local sx,sy=C.project(x,y,z)
  p[#p+1]=sx+64;p[#p+1]=sy+78
 end
 return p
end
local function disk(p,color) poly(p,color);g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(p)) end
local function tube(angle,back,front,r0,r1)
 local a,b=ring(angle,back,r0),ring(angle,front,r1)
 -- Cylinder strips have their own surface normals; only camera-facing sides draw.
 for i=0,23 do
  local theta=(i+.5)*math.pi/12;local c,s=math.cos(angle),math.sin(angle)
  local side,up=math.cos(theta),math.sin(theta)/math.sqrt(1+C.pitch*C.pitch)
  local nx,ny,nz=-s*side-c*C.pitch*up,c*side-s*C.pitch*up,up
  if nx+ny+nz*18/13>0 then
   local j=(i+1)%24;local u,v=i*2+1,j*2+1
   local p={a[u],a[u+1],a[v],a[v+1],b[v],b[v+1],b[u],b[u+1]}
   poly(p,nz>.15 and g.kColorWhite or g.kColorBlack)
   if nz>.65 then g.setColor(g.kColorBlack);g.drawLine(a[u],a[u+1],b[u],b[u+1]) end
  end
 end
 g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(a));g.drawPolygon(table.unpack(b))
end
local function baseRing(radius,z)
 local p={};for i=0,31 do local a=i*math.pi/16;local x,y=C.project(radius*math.cos(a),radius*math.sin(a),z);p[#p+1]=64+x;p[#p+1]=78+y end;return p
end
function C.base()
 local im=g.image.new(128,128,g.kColorClear);g.pushContext(im)
 -- Low circular pedestal and bearing stay in the same place at every angle.
 disk(baseRing(25,0),g.kColorBlack);disk(baseRing(25,4),g.kColorWhite)
 disk(baseRing(20,5),g.kColorBlack);disk(baseRing(18,12),g.kColorWhite)
 for i=0,7 do local a=i*math.pi/4;local x,y=C.project(22*math.cos(a),22*math.sin(a),4);g.setColor(g.kColorBlack);g.fillCircleAtPoint(64+x,78+y,1) end
 g.popContext();return im
end
function C.raster(angle)
 local im=g.image.new(128,128,g.kColorClear);g.pushContext(im)
 -- A rear cap, tapered body, steel reinforcement bands and a hollow flared mouth.
 disk(ring(angle,-10,12),g.kColorBlack)
 tube(angle,-10,C.forward-4,12,14)
 tube(angle,-8,-4,14,14)
 tube(angle,C.forward-7,C.forward-3,16,16)
 tube(angle,C.forward-3,C.forward,16,16)
 disk(ring(angle,C.forward,16),g.kColorWhite)
 disk(ring(angle,C.forward+.05,12.5),g.kColorBlack)
 -- Front rim highlight, following the projected circular ring rather than the screen.
 local rim=ring(angle,C.forward+.1,14.5)
 g.setColor(g.kColorBlack);g.drawPolygon(table.unpack(rim))
 -- Trunnion pins project in the same world space as the cylinder.
 local c,s=math.cos(angle),math.sin(angle)
 local sign=(-s+c)>0 and 1 or -1
 local x,y=C.project(-s*12*sign,c*12*sign,C.pivot)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(64+x,78+y,4)
 g.setColor(g.kColorBlack);g.drawCircleAtPoint(64+x,78+y,4);g.fillCircleAtPoint(64+x,78+y,1)
 g.popContext();return im
end
