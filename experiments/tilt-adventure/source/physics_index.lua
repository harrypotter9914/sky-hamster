-- Conservative swept bounds: objects remain active anywhere they can travel.
-- Only collision/force queries use this view; rendering keeps the full course.
PhysicsIndex={}
local P=PhysicsIndex
local function bounds(m)
 local r=math.sqrt(m.w*m.w+m.h*m.h)/2+32
 local x0,x1,y0,y1=m.x-r,m.x+r,m.y-r,m.y+r
 if m.toX then x0=math.min(x0,m.toX-r);x1=math.max(x1,m.toX+r);y0=math.min(y0,m.toY-r);y1=math.max(y1,m.toY+r) end
 if m.range then y0=y0-m.range;y1=y1+m.range end
 if m.retract then x0=math.min(x0,m.anchor-32);x1=math.max(x1,m.anchor+m.maxWidth+32) end
 if m.kind=='magnet' then local d=(m.radius or 140)+32;x0,x1,y0,y1=m.x-d,m.x+d,m.y-d,m.y+d end
 if m.region then local a=m.region;x0=math.min(x0,a[1]-a[3]/2-32);x1=math.max(x1,a[1]+a[3]/2+32);y0=math.min(y0,a[2]-a[4]/2-32);y1=math.max(y1,a[2]+a[4]/2+32) end
 return {x0,x1,y0,y1}
end
function P.near(c,x,y)
 if c.physicsOwner then return c end
 local ix,iy=math.floor(x/128),math.floor(y/128)
 local view=c.physicsView
 if view and view.ix==ix and view.iy==iy then return view end
 c.physicsCells=c.physicsCells or {}
 local key=ix..','..iy
 view=c.physicsCells[key]
 if view then c.physicsView=view;return view end
 view=setmetatable({physicsOwner=c,mechanisms={},lifts={}},{__index=c});c.physicsView=view;c.physicsCells[key]=view
 -- A nearby spring cannot provide floor support or wind. Keep the original
 -- per-query order while excluding mechanism families that query never uses.
 view.supportView=setmetatable({mechanisms={},physicsOwner=c},{__index=view})
 view.collisionView=setmetatable({mechanisms={},physicsOwner=c},{__index=view})
 view.forceView=setmetatable({mechanisms={},physicsOwner=c},{__index=view})
 view.ix,view.iy=ix,iy
 local list=view.mechanisms;for i=#list,1,-1 do list[i]=nil end
 local x0,x1,y0,y1=ix*128,(ix+1)*128,iy*128,(iy+1)*128
 for _,m in ipairs(c.mechanisms or {}) do
  local b=m.physicsBounds;if not b then b=bounds(m);m.physicsBounds=b end
  if b[1]<=x1 and b[2]>=x0 and b[3]<=y1 and b[4]>=y0 then
   list[#list+1]=m
   if m.kind=='lift' then view.lifts[#view.lifts+1]=m end
   local kind=m.kind
   if kind=='lift' or kind=='ferry' or kind=='rotor' or kind=='trap' then local a=view.supportView.mechanisms;a[#a+1]=m end
   if kind=='gate' or kind=='sweeper' or kind=='bumper' then local a=view.collisionView.mechanisms;a[#a+1]=m end
   if kind=='fan' or kind=='conveyor' or kind=='jet' or kind=='magnet' then local a=view.forceView.mechanisms;a[#a+1]=m end
  end
 end
 return view
end
local M,S=Mechanisms,Spatial
P.reference={support=M.support,collide=M.collide,wind=M.wind,sides=S.sides,floor=M.floor}
local epoch=0
function M.floor(c,x,y,t)
 -- Only lifts can override course height. Other support types need no query here.
 local root=c.physicsOwner or c
 local memo=root.floorMemo
 if memo and memo.x==x and memo.y==y and memo.epoch==epoch then
  if not memo.lift then return memo.z end
  return memo.lift.elevation or memo.lift.minHeight
 end
 local lift
 for _,m in ipairs(P.near(c,x,y).lifts) do if M.contains(m,x,y,t) then lift=m;break end end
 local z=lift and (lift.elevation or lift.minHeight) or root:height(x,y)
 memo=memo or {};root.floorMemo=memo
 memo.x,memo.y,memo.epoch,memo.z,memo.lift=x,y,epoch,z,lift
 return z
end
local reset,update=Dock.reset,Dock.update
function Dock.reset(...) epoch=epoch+1;return reset(...) end
function Dock.update(...) epoch=epoch+1;return update(...) end
function M.support(c,x,y,t)
 local root=c.physicsOwner or c
 local memo=root.supportMemo
 if memo and memo.x==x and memo.y==y and memo.t==t and memo.epoch==epoch then return memo.ok,memo.m end
 local view=P.near(c,x,y)
 local ok,m
 -- Preserve the original two-pass priority: lifts first, then moving decks,
 -- closed trap floors, and finally terrain. Avoid traversing wrapper views.
 for _,item in ipairs(view.lifts) do if M.contains(item,x,y,t) then ok,m=true,item;break end end
 if not ok then
  for _,item in ipairs(view.supportView.mechanisms) do
   local kind=item.kind
   if (kind=='ferry' or kind=='rotor' or (kind=='trap' and not M.open(item,t))) and M.contains(item,x,y,t) then ok,m=true,item;break end
  end
 end
 if not ok then ok=root.lookup[math.floor(x/32)..','..math.floor(y/32)]==true end
 memo=memo or {};root.supportMemo=memo
 memo.x,memo.y,memo.t,memo.epoch,memo.ok,memo.m=x,y,t,epoch,ok,m
 return ok,m
end
function M.collide(c,x,y,vx,vy,z,t,dt)
 local view=P.near(c,x,y);view=view.collisionView or view
 if #view.mechanisms==0 then return x,y,vx,vy,false end
 return P.reference.collide(view,x,y,vx,vy,z,t,dt)
end
function M.wind(c,x,y,vx,vy,z,dt,t)
 local view=P.near(c,x,y);view=view.forceView or view
 if #view.mechanisms==0 then return vx,vy end
 return P.reference.wind(view,x,y,vx,vy,z,dt,t)
end
function S.sides(c,x,y,vx,vy,z,t)
 local view=P.near(c,x,y)
 return P.reference.sides(view.supportView or view,x,y,vx,vy,z,t)
end
