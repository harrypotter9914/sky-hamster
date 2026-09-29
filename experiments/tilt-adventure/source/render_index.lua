-- Index conservative swept screen-space bounds, without freezing offscreen time.
RenderIndex={}
local R=RenderIndex
local function heights(c,x0,x1)
 local a,b=c:height(x0,0),c:height(x1,0)
 local low,high=math.min(a,b),math.max(a,b)
 for _,p in ipairs(c.profile) do if p[1]>=x0 and p[1]<=x1 then low=math.min(low,p[2]);high=math.max(high,p[2]) end end
 for _,p in ipairs(c.upperLips or {}) do if p[1]<=x1 and p[2]>=x0 then low=math.min(low,p[5]);high=math.max(high,p[5]) end end
 return low,high
end
local function extent(c,m,low,high)
 local r=math.sqrt((m.maxWidth or m.w)^2+m.h^2)/2
 local x0,x1,y0,y1=m.x-r,m.x+r,m.y-r,m.y+r
 if m.retract then x0=math.min(x0,m.anchor-r);x1=math.max(x1,m.anchor+m.maxWidth+r) end
 if m.toX then x0=math.min(x0,m.toX-r);x1=math.max(x1,m.toX+r);y0=math.min(y0,m.toY-r);y1=math.max(y1,m.toY+r) end
 if m.range then y0=y0-m.range;y1=y1+m.range end
 low,high=heights(c,x0,x1)
 low=math.min(low,m.minHeight or low);high=math.max(high,m.maxHeight or high)+(m.wallHeight or 80)
 -- Includes signs, gear/handle overhang, steam, wind trails and the full turn.
 local margin=160
 return {(x0-y1)*.9-margin,(x1-y0)*.9+margin,(x0+y0)*.45-high*.65-margin,(x1+y1)*.45-low*.65+margin}
end
local function prepare(c)
 local low,high=1e9,-1e9
 for _,p in ipairs(c.profile) do low=math.min(low,p[2]);high=math.max(high,p[2]) end
 local entries={}
 for _,m in ipairs(c.mechanisms or {}) do entries[#entries+1]={m,extent(c,m,low,high)} end
 local pads={}
 for _,p in ipairs(c.pads or {}) do
  local m=p.target
  local x0,x1,y0,y1=p.x,p.x,p.y,p.y
  if m and (p.onboard or p.kind=='slider') then
   x0=math.min(x0,m.x,m.toX or m.x);x1=math.max(x1,m.x,m.toX or m.x)
   y0=math.min(y0,m.y,m.toY or m.y);y1=math.max(y1,m.y,m.toY or m.y)
  end
  pads[#pads+1]={p,{(x0-y1)*.9-160,(x1-y0)*.9+160,(x0+y0)*.45-high*.65-180,(x1+y1)*.45-low*.65+180}}
 end
 c.renderIndex={entries=entries,pads=pads,views={}}
end
function R.view(c,project)
 if c.renderOwner then return c end
 if not c.renderIndex then prepare(c) end
 local ox,oy=project(0,0,0)
 local ix,iy=math.floor(-ox/128),math.floor(-oy/128)
 local index=c.renderIndex
 if index.ix==ix and index.iy==iy then return index.current end
 local key=ix..','..iy;local view=index.views[key]
 if not view then
  local x0,x1,y0,y1=ix*128,(ix+1)*128+400,iy*128,(iy+1)*128+240
  view=setmetatable({renderOwner=c,mechanisms={},pads={},workshopView=false,legacyView=false,artMechanisms=false},{__index=c})
  for _,entry in ipairs(index.entries) do
   local b=entry[2]
   if b[1]<=x1 and b[2]>=x0 and b[3]<=y1 and b[4]>=y0 then view.mechanisms[#view.mechanisms+1]=entry[1] end
  end
  for _,entry in ipairs(index.pads) do
   local b=entry[2]
   if b[1]<=x1 and b[2]>=x0 and b[3]<=y1 and b[4]>=y0 then view.pads[#view.pads+1]=entry[1] end
  end
  index.views[key]=view
 end
 index.ix,index.iy,index.current=ix,iy,view
 return view
end
