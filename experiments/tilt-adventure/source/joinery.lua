-- Dock faces are measured from the road, not from a visually convenient overlap.
Joinery={}
local J=Joinery
local function banks(rows,x,y,half)
 local left,right=-math.huge,math.huge
 for j=math.floor((y-half+.01)/32),math.ceil((y+half-.01)/32)-1 do
  local row=rows[j]
  if row then
   local lo,hi=1,#row+1
   while lo<hi do local mid=(lo+hi)//2;if (row[mid]+1)*32<=x+.01 then lo=mid+1 else hi=mid end end
   if lo>1 then left=math.max(left,(row[lo-1]+1)*32) end
   lo,hi=1,#row+1
   while lo<hi do local mid=(lo+hi)//2;if row[mid]*32<x-.01 then lo=mid+1 else hi=mid end end
   if lo<=#row then right=math.min(right,row[lo]*32) end
  end
 end
 return left,right
end
function J.prepare(c)
 local lifts={}
 for _,m in ipairs(c.mechanisms or {}) do if m.kind=='lift' then lifts[#lifts+1]=m end end
 if #lifts>0 then
  c.upperLips={}
  for _,m in ipairs(lifts) do
   -- Put the upper landing on the rear/right side in the fixed isometric view.
   -- Keep the lower entrance on the left and reconnect to the existing route.
   m.y=math.floor(m.y/32)*32+32
   for _,p in ipairs(c.pads or {}) do if p.target==m then p.y=m.y end end
   local back=m.y-m.h/2
   local lip={m.x-m.w/2,m.x+m.w/2,back-32,back,m.maxHeight}
   c.upperLips[#c.upperLips+1]=lip
   local kept={}
   for index,tile in ipairs(c.tiles) do
    local x0,y0=tile.x*32,tile.y*32
    if x0>=lip[2] and x0<lip[2]+64 and y0>=back and y0<back+m.h then c.lookup[tile.x..','..tile.y]=nil
    else kept[#kept+1]=tile end
    if Loading and index%128==0 then Loading.checkpoint(.05,'FITTING THE LANDINGS') end
   end
   c.tiles=kept
   c:rect(math.floor(lip[1]/32),math.floor(lip[2]/32)-1,math.floor(lip[3]/32),math.floor(lip[4]/32)-1)
  end
  local bounds={math.huge,-math.huge,math.huge,-math.huge}
  for _,lip in ipairs(c.upperLips) do
   bounds[1]=math.min(bounds[1],lip[1]);bounds[2]=math.max(bounds[2],lip[2])
   bounds[3]=math.min(bounds[3],lip[3]);bounds[4]=math.max(bounds[4],lip[4])
  end
  c.upperLipBounds=bounds
  table.sort(c.tiles,function(a,b)return a.x+a.y<b.x+b.y end)
 end
 local rows={}
 for index,tile in ipairs(c.tiles) do
  local row=rows[tile.y];if not row then row={};rows[tile.y]=row end;row[#row+1]=tile.x
  if Loading and index%128==0 then Loading.checkpoint(.05,'FITTING THE LANDINGS') end
 end
 for _,row in pairs(rows) do table.sort(row) end
 for _,m in ipairs(c.mechanisms or {}) do
  if m.kind=='ferry' then
   local left=banks(rows,m.x,m.y,m.h/2)
   local _,right=banks(rows,m.toX,m.toY,m.h/2)
   if left>-math.huge and right<math.huge and m.toX>m.x then
    m.x=left+m.w/2;m.toX=right-m.w/2;m.dockLeft=left;m.dockRight=right
    for _,p in ipairs(c.pads or {}) do if p.target==m then p.x=m.x;p.y=m.y end end
   end
  elseif m.kind=='rotor' and not m.retract and not m.turnSquare then
   local left,right=banks(rows,m.x,m.y,m.h/2)
   if left>-math.huge and right<math.huge and right-left>m.h then
    m.x=(left+right)/2;m.joinSpan=right-left;m.w=m.joinSpan;m.maxWidth=m.joinSpan
    m.dockLeft=left;m.dockRight=right
   end
  elseif m.kind=='lift' then
   -- The landing is an open trestle, not a full-height wall behind the carriage.
   -- Its walking surface and normal slab collision thickness stay unchanged.
   local back=m.y-m.h/2
   m.landingPosts={{m.x-m.w/2+5,back-26},{m.x+m.w/2+26,back-26}}
  end
 end
end
for _,c in ipairs(Courses) do if not c.blueprint then J.prepare(c) end end
function J.width(m,angle)
 if m.turnSquare then
  local co,si=math.abs(math.cos(angle)),math.abs(math.sin(angle));local w=m.turnSquare
  if co>.00001 then w=math.min(w,(m.turnSquare-m.h*si)/co) end
  if si>.00001 then w=math.min(w,(m.turnSquare-m.h*co)/si) end
  return math.max(m.h,w)
 end
 if not m.joinSpan then return m.w end
 -- Sliding end shoes retract just enough to clear both banks while turning.
 -- At alignment the full rectangular end face closes exactly against the road.
 local cosine=math.abs(math.cos(angle))
 if math.abs(math.sin(angle))<.0000001 then return m.joinSpan end
 if cosine<.00001 then return m.joinSpan end
 return math.min(m.joinSpan,math.max(m.h,(m.joinSpan-m.h*math.abs(math.sin(angle)))/cosine))
end
