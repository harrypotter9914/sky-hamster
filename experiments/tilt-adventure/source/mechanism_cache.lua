-- Reuse the detailed metal deck/panel raster while its shape is unchanged.
-- World translation remains live. A moving shutter/rotating deck is redrawn.
local M,g=Mechanisms,playdate.graphics
local paint=M.draw
function M.draw(c,t,project)
 for _,m in ipairs(c.mechanisms or {}) do
  local x,y,a=M.pose(m,t);local floor=c:height(m.x,m.y)
  local sx,sy=project(x,y,floor);local ex=(m.w+m.h)*.64+40
  local wall=m.kind=='gate' or m.kind=='sweeper'
  local h=wall and (M.wallHeight and M.wallHeight(m,t) or m.wallHeight or 80) or 0
  if sx+ex>=-32 and sx-ex<=432 and sy+ex>=12 and sy-ex-h*.65-30<=236 then
   local opened=(m.kind=='gate' or m.kind=='trap') and M.open(m,t) or false
   local warning=m.kind=='trap' and M.warning(m,t) or false
   local entry=m.paintCache
   if not entry or entry.a~=a or entry.h~=h or entry.w~=m.w or entry.open~=opened or entry.warning~=warning then
    local size=(m.maxWidth or m.w)+m.h
    local w=math.ceil(size*.9)+84
    local y0=math.ceil(size*.225+(wall and (m.wallHeight or 80) or 0)*.65)+36
    local height=y0+math.ceil(size*.225)+20
    local im=entry and entry.image
    if not im or entry.width~=w or entry.height~=height then im=g.image.new(w,height,g.kColorClear) end
    local view=m.paintView;if not view then view=setmetatable({mechanisms={m}},{__index=c});m.paintView=view end
    g.pushContext(im);g.clear(g.kColorClear)
    paint(view,t,function(px,py,z) return w/2+(px-x-py+y)*.9,y0+(px-x+py-y)*.45-(z-floor)*.65 end)
    g.popContext()
    entry={image=im,a=a,h=h,w=m.w,open=opened,warning=warning,width=w,height=height,y0=y0};m.paintCache=entry
   end
   entry.image:draw(sx-entry.width/2,sy-entry.y0)
  end
 end
end
