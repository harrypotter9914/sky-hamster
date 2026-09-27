-- Solid illustrated props use their real alpha silhouette inside a 3D front
-- volume. Empty spring coils, muzzle margins and wind particles are not walls.
PropOcclusion={}
local O,g=PropOcclusion,playdate.graphics
local entries,count,active={},0,false
local ballX,ballY,ballZ,left,top
-- Native SDK stencil rows require at least 32 pixels, even for a 28px ball.
local stencil=g.image.new(32,32,g.kColorBlack)
local polygon={}
for i=1,8 do entries[i]={box={slope=0},mask=g.image.new(32,32,g.kColorWhite)} end
function O.begin(x,y,z,sx,sy)
 ballX,ballY,ballZ,left,top=x,y,z,math.floor(sx),math.floor(sy)
 count=0;active=true
end
function O.finish() active=false end
function O.add(im,sx,sy,x,y,w,h,a,bottom,roof,wholeSafe)
 if not active or roof<=ballZ then return end
 local iw,ih=im:getSize();sx,sy=math.floor(sx),math.floor(sy)
 if sx+iw<=left or sx>=left+28 or sy+ih<=top or sy>=top+28 then return end
 local c,s=math.cos(a or 0),math.sin(a or 0)
 if x+y+(math.abs(c+s)*w+math.abs(c-s)*h)/2<=ballX+ballY then return end
 count=count+1
 local item=entries[count]
 if not item then item={box={slope=0},mask=g.image.new(32,32,g.kColorWhite)};entries[count]=item end
 -- Only images whose full silhouette fits their model can bypass clipping.
 item.whole=wholeSafe and x+y-(math.abs(c+s)*w+math.abs(c-s)*h)/2>=ballX+ballY+.002
 item.image,item.sx,item.sy=im,sx-left,sy-top
 local b=item.box
 b.x,b.y,b.w,b.h,b.c,b.s,b.bottom,b.top=x,y,w,h,c,s,bottom,roof
end
function O.pending() return count>0 end
function O.apply(project)
 for i=1,count do
  local item=entries[i]
  if item.whole then
   g.setImageDrawMode(g.kDrawModeFillBlack)
   item.image:draw(item.sx,item.sy)
   g.setImageDrawMode(g.kDrawModeCopy)
  else
   local b=item.box
   local px,py=project(b.x,b.y,b.bottom);px,py=px-left,py-top
   local plane=ballX+ballY-b.x-b.y
   local roof=b.top-b.bottom
   local cache=item.cached
   if not cache or cache.im~=item.image or cache.sx~=item.sx or cache.sy~=item.sy or cache.px~=px or cache.py~=py or cache.plane~=plane or cache.w~=b.w or cache.h~=b.h or cache.c~=b.c or cache.s~=b.s or cache.roof~=roof then
    cache=cache or {};item.cached=cache
    cache.im,cache.sx,cache.sy,cache.px,cache.py,cache.plane=item.image,item.sx,item.sy,px,py,plane
    cache.w,cache.h,cache.c,cache.s,cache.roof=b.w,b.h,b.c,b.s,roof
    local p=Spatial.maskPolygon(b,ballX,ballY,project,left,top,polygon)
    g.pushContext(stencil);g.clear(g.kColorBlack)
    if p then g.setColor(g.kColorWhite);g.fillPolygon(table.unpack(p)) end
    g.popContext()
    g.pushContext(item.mask);g.clear(g.kColorWhite)
    g.setStencilImage(stencil);g.setImageDrawMode(g.kDrawModeFillBlack)
    item.image:draw(item.sx,item.sy)
    g.setImageDrawMode(g.kDrawModeCopy);g.clearStencil();g.popContext()
   end
   g.setImageDrawMode(g.kDrawModeWhiteTransparent);item.mask:draw(0,0)
   g.setImageDrawMode(g.kDrawModeCopy)
  end
 end
end
