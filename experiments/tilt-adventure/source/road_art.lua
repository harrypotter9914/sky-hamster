-- Project each material/slope combination once, then stamp it into terrain chunks.
RoadArt={}
local g=playdate.graphics
local source,cache={},{}
local function prepare(t,slope)
 if not playdate.geometry then return end
 local n=(t.x%4)+(t.y%4)*4
 local key=n..'/'..string.format('%.4f',slope)
 local entry=cache[key]
 if not entry then
  source[n]=source[n] or g.image.new('paving/'..n)
  local h=math.ceil(math.abs(.45-.65*slope)*32+14.4)+6
  local im=g.image.new(64,h,g.kColorWhite)
  local transform=playdate.geometry.affineTransform.new(.9,-.9,.45-.65*slope,.45,0,0)
  -- Clip the texture to its own top face, especially at inside road corners.
  local mask=g.image.new(64,h,g.kColorBlack);local poly={}
  for _,p in ipairs({{-16,-16},{16,-16},{16,16},{-16,16}}) do
   poly[#poly+1]=32+(p[1]-p[2])*.9;poly[#poly+1]=h/2+(p[1]+p[2])*.45-p[1]*slope*.65
  end
  g.pushContext(mask);g.setColor(g.kColorWhite);g.fillPolygon(table.unpack(poly));g.popContext()
  g.pushContext(im);source[n]:drawWithTransform(transform,32,h/2);g.popContext();im:setMaskImage(mask)
  entry={image=im,h=h};cache[key]=entry
 end
 return entry
end
function RoadArt.warm(c)
 if not playdate.geometry then return end
 for i,t in ipairs(c.tiles) do local _,s=c:height(t.x*32+16,t.y*32+16);prepare(t,s);if Loading and i%32==0 then Loading.checkpoint(.12+.17*i/#c.tiles,"GATHERING THE STONES") end end
end
function RoadArt.draw(t,slope,cx,cy)
 if not playdate.geometry then return end
 local entry=prepare(t,slope)
 g.setImageDrawMode(g.kDrawModeWhiteTransparent)
 entry.image:draw(math.floor(cx-32+.5),math.floor(cy-entry.h/2+.5))
 g.setImageDrawMode(g.kDrawModeCopy)
end
