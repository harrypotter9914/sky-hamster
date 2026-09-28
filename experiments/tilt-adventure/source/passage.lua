-- Landing signals measure the same footprint as physics, without snapping poses.
Passage={gap=16}
local P=Passage
local occupied,used={},0
local laneOffsets={-9,0,9}
function P.begin() used=0 end
function P.reserve(x,y,w,h)
 used=used+1;local r=occupied[used] or {};occupied[used]=r;r[1],r[2],r[3],r[4]=x,y,w,h
end
function P.ports(m)
 if m.ports then return m.ports end
 if m.passagePorts then return m.passagePorts end
 local ports={}
 if m.kind=='lift' then
  ports={{x=m.x-m.w/2,y=m.y,dx=-1,dy=0,z=m.minHeight},
   {x=m.x,y=m.y-m.h/2,dx=0,dy=-1,z=m.maxHeight}}
 elseif m.dockLeft and m.dockRight then
  ports={{x=m.dockLeft,y=m.y,dx=-1,dy=0},
   {x=m.dockRight,y=m.toY or m.y,dx=1,dy=0}}
 elseif m.retract then
  ports={{x=m.anchor,y=m.y,dx=-1,dy=0},
   {x=m.anchor+m.maxWidth,y=m.y,dx=1,dy=0}}
 end
 m.passagePorts=ports;return ports
end
function P.ready(c,m,p,t)
 if not Footing.solid(m,t) then return false end
 local cx,cy,a=Mechanisms.pose(m,t)
 local z=m.kind=='lift' and (m.elevation or m.minHeight) or 0
 local memo=p.readyMemo
 if memo and memo.x==cx and memo.y==cy and memo.a==a and memo.w==m.w and memo.z==z then return memo.ready end
 -- A whole marble-wide lane must reach real road at the same height.
 -- The 2-unit margin makes GO conservative near the support cutoff.
 local ready=true
 for _,offset in ipairs(laneOffsets) do
  local x,y=p.x-p.dy*offset,p.y+p.dx*offset
  local bx,by=x+p.dx*.1,y+p.dy*.1
  if not c.lookup[math.floor(bx/32)..','..math.floor(by/32)] then ready=false;break end
  local d,px,py=Footing.nearest(m,x,y,t)
  local deck=m.kind=='lift' and (m.elevation or m.minHeight) or c:height(px,py)
  if d>P.gap^2 or math.abs(deck-c:height(bx,by))>1 then ready=false;break end
 end
 memo=memo or {};p.readyMemo=memo
 memo.x,memo.y,memo.a,memo.w,memo.z,memo.ready=cx,cy,a,m.w,z,ready
 return ready
end
function P.state(m,t)
 if m.kind=='gate' then return Mechanisms.open(m,t) end
 if m.kind=='trap' then return not Mechanisms.open(m,t) and not Mechanisms.warning(m,t) end
 if m.kind=='jet' then return (t+(m.phase or 0))%m.period>=m.period*.4 end
end
local images={}
local function badge(ready,lane)
 local key=(lane and lane..': ' or '')..(ready and 'GO' or 'WAIT')
 if images[key] then return images[key] end
 local w=lane and 80 or 64
 local g=playdate.graphics;local im=g.image.new(w,18,g.kColorClear)
 g.pushContext(im)
 g.setColor(g.kColorBlack);g.fillRoundRect(0,0,w-1,17,4)
 g.setColor(g.kColorWhite);g.drawRoundRect(1,1,w-3,15,3)
 g.setLineWidth(2)
 if ready then g.drawLine(5,8,8,11);g.drawLine(8,11,13,5)
 else g.drawLine(5,5,12,12);g.drawLine(12,5,5,12) end
 g.setLineWidth(1)
 g.setImageDrawMode(g.kDrawModeFillWhite);g.drawTextAligned(key,(w+14)/2,1,kTextAlignment.center);g.setImageDrawMode(g.kDrawModeCopy)
 g.popContext();images[key]=im;return im
end
function P.lanes(c,m)
 if m.passageLanes then return m.passageLanes end
 local low,high=math.huge,-math.huge
 local tx=math.floor(m.x/32)
 for j=math.floor((m.y-m.range-m.h/2)/32),math.floor((m.y+m.range+m.h/2)/32) do
  if c.lookup[tx..','..j] and c.lookup[(tx-1)..','..j] and c.lookup[(tx+1)..','..j] then
   low=math.min(low,j*32);high=math.max(high,(j+1)*32)
  end
 end
 m.passageLanes={}
 if high-low>=32 then m.passageLanes={low+12,high-12} end
 return m.passageLanes
end
function P.laneReady(c,m,y,t)
 local _,cy=Mechanisms.pose(m,t)
 if math.abs(y-cy)<m.h/2+Footing.radius+1 then return false end
 local h=c:height(m.x,y)
 for _,x in ipairs({m.x-m.w/2-12,m.x,m.x+m.w/2+12}) do
  for _,dy in ipairs(laneOffsets) do
   if not c.lookup[math.floor(x/32)..','..math.floor((y+dy)/32)] or math.abs(c:height(x,y+dy)-h)>1 then return false end
  end
 end
 return true
end
local offsets={{-.5,-27},{0,-27},{-1,-27},{-.5,5},{0,5},{-1,5},{-.5,-46}}
local nearOffsets={{-1,5},{-1,-27},{-.5,5},{0,5},{-.5,-27},{0,-27},{-.5,-46}}
local farOffsets={{0,-27},{0,5},{-.5,-27},{-1,-27},{-.5,5},{-1,5},{-.5,-46}}
local function clearRect(x,y,w,h)
 if x<3 or x+w>397 or y<46 or y+h>202 then return false end
 for i=1,used do local r=occupied[i]
  if x<r[1]+r[3]+2 and x+w+2>r[1] and y<r[2]+r[4]+2 and y+h+2>r[2] then return false end
 end
 return true
end
-- Clip leader segments around the ball, compass and every already placed sign.
-- Reuse interval storage so dense machinery does not create per-frame garbage.
local cuts={}
local function leader(x,y,tx,ty)
 local dx,dy=tx-x,ty-y;local count=0
 for i=1,used do
  local r=occupied[i];local a,b=0,1
  if dx==0 then if x<r[1]-2 or x>r[1]+r[3]+2 then b=-1 end
  else
   local u,v=(r[1]-2-x)/dx,(r[1]+r[3]+2-x)/dx;if u>v then u,v=v,u end
   a,b=math.max(a,u),math.min(b,v)
  end
  if dy==0 then if y<r[2]-2 or y>r[2]+r[4]+2 then b=-1 end
  else
   local u,v=(r[2]-2-y)/dy,(r[2]+r[4]+2-y)/dy;if u>v then u,v=v,u end
   a,b=math.max(a,u),math.min(b,v)
  end
  if a<=b then
   count=count+1;local c=cuts[count] or {};cuts[count]=c;c[1],c[2]=a,b
  end
 end
 local start=0
 while start<1 do
  local a,b=1,1
  for i=1,count do local c=cuts[i]
   if c[2]>start and c[1]<a then a,b=math.max(start,c[1]),c[2] end
  end
  if a>start then playdate.graphics.drawLine(x+dx*start,y+dy*start,x+dx*a,y+dy*a) end
  start=b
 end
end
P.leader=leader
local labelOffsets={{0,0},{0,-29},{0,29},{-86,0},{86,0},{-86,-29},{86,-29},{-86,29},{86,29}}
function P.labelPosition(x,y,w,h)
 for _,off in ipairs(labelOffsets) do
  local a,b=math.max(3,math.min(397-w,x+off[1])),math.max(46,math.min(202-h,y+off[2]))
  if clearRect(a,b,w,h) then return a,b end
 end
end
function P.signal(sx,sy,ready,lane)
 local g=playdate.graphics
 local w=lane and 80 or 64
 local positions=lane==1 and farOffsets or lane==2 and nearOffsets or offsets
 local ax,ay=math.floor(sx),math.floor(sy)
 -- A numbered socket identifies the lane even when the marble hides its leader.
 if lane and clearRect(ax-8,ay-8,16,16) then
  g.setColor(g.kColorBlack);g.fillCircleAtPoint(ax,ay,8)
  g.setColor(g.kColorWhite);g.drawCircleAtPoint(ax,ay,7)
  g.setImageDrawMode(g.kDrawModeFillWhite);g.drawTextAligned(tostring(lane),ax,ay-7,kTextAlignment.center);g.setImageDrawMode(g.kDrawModeCopy)
  P.reserve(ax-8,ay-8,16,16)
 end
 for _,off in ipairs(positions) do
  local x,y=math.floor(sx+off[1]*w+(off[1]==0 and 10 or off[1]==-1 and -10 or 0)),math.floor(sy+off[2])
  if clearRect(x,y,w,18) then
   g.setColor(g.kColorBlack);leader(sx,sy,math.max(x+4,math.min(x+w-4,sx)),y>sy and y or y+17)
   badge(ready,lane):draw(x,y);P.reserve(x,y,w,18);return
  end
 end
 -- Never force a fallback onto the marble or another lane's label.
 for _,off in ipairs(positions) do
  local x,y=math.floor(sx+off[1]*24),math.floor(sy+off[2])
  if clearRect(x-7,y-7,14,14) then
   g.setColor(g.kColorBlack);leader(sx,sy,x,y)
   g.setColor(g.kColorWhite);g.fillCircleAtPoint(x,y,7)
   g.setColor(g.kColorBlack);g.drawCircleAtPoint(x,y,7)
   if ready then g.drawLine(x-4,y,x-1,y+3);g.drawLine(x-1,y+3,x+4,y-3)
   else g.drawLine(x-3,y-3,x+3,y+3);g.drawLine(x+3,y-3,x-3,y+3) end
   P.reserve(x-7,y-7,14,14);return
  end
 end
end
function P.draw(c,t,project)
 local g=playdate.graphics
 for _,m in ipairs(c.mechanisms or {}) do
  local ports=P.ports(m)
  for _,p in ipairs(ports) do
   local h=c:height(p.x+p.dx*.1,p.y+p.dy*.1)
   local sx,sy=project(p.x+p.dx*14,p.y+p.dy*14,h)
   if sx>34 and sx<366 and sy>45 and sy<193 then
    P.signal(sx,sy,P.ready(c,m,p,t))
   end
  end
  local state=P.state(m,t)
  if state~=nil and not (m.hideLabel and m.openFor==0) then
   -- Signals sit beside the crossing, not on the moving/vanishing surface.
   local sx,sy=project(m.x-m.w/2-12,m.lane and m.y or m.y-m.h/2,c:height(m.x,m.y))
   if sx>24 and sx<376 and sy>70 and sy<193 then
    P.signal(sx,sy,state,m.lane)
   end
  end
  if m.kind=='sweeper' then for _,y in ipairs(P.lanes(c,m)) do
   local sx,sy=project(m.x-m.w/2-22,y,c:height(m.x,y))
   if sx>34 and sx<366 and sy>70 and sy<193 then
    P.signal(sx,sy,P.laneReady(c,m,y,t))
   end
  end end
 end
end
