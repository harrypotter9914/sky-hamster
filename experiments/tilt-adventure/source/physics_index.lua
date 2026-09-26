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
 view=setmetatable({physicsOwner=c,mechanisms={}},{__index=c});c.physicsView=view;c.physicsCells[key]=view
 view.ix,view.iy=ix,iy
 local list=view.mechanisms;for i=#list,1,-1 do list[i]=nil end
 local x0,x1,y0,y1=ix*128,(ix+1)*128,iy*128,(iy+1)*128
 for _,m in ipairs(c.mechanisms or {}) do
  local b=m.physicsBounds;if not b then b=bounds(m);m.physicsBounds=b end
  if b[1]<=x1 and b[2]>=x0 and b[3]<=y1 and b[4]>=y0 then list[#list+1]=m end
 end
 return view
end
local M,S=Mechanisms,Spatial
P.reference={support=M.support,collide=M.collide,wind=M.wind,sides=S.sides}
local epoch=0
local reset,update=Dock.reset,Dock.update
function Dock.reset(...) epoch=epoch+1;return reset(...) end
function Dock.update(...) epoch=epoch+1;return update(...) end
function M.support(c,x,y,t)
 local root=c.physicsOwner or c
 local memo=root.supportMemo
 if memo and memo.x==x and memo.y==y and memo.t==t and memo.epoch==epoch then return memo.ok,memo.m end
 local ok,m=P.reference.support(P.near(c,x,y),x,y,t)
 memo=memo or {};root.supportMemo=memo
 memo.x,memo.y,memo.t,memo.epoch,memo.ok,memo.m=x,y,t,epoch,ok,m
 return ok,m
end
function M.collide(c,x,y,vx,vy,z,t,dt) return P.reference.collide(P.near(c,x,y),x,y,vx,vy,z,t,dt) end
function M.wind(c,x,y,vx,vy,z,dt,t) return P.reference.wind(P.near(c,x,y),x,y,vx,vy,z,dt,t) end
function S.sides(c,x,y,vx,vy,z,t) return P.reference.sides(P.near(c,x,y),x,y,vx,vy,z,t) end
