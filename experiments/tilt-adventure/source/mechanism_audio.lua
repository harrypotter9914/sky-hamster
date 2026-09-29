-- Event sounds follow real state changes; a bounded mixer handles nearby machines.
MechanismAudio={clock=0,states={},loops={},shots={},byName={},fresh=true,enabled=false}
local S,M,D=MechanismAudio,Mechanisms,Dock
local durations={connect=.13,release=.14,crank=.07,stop=.12,spring=.38,cannon=.34,
 gate_open=.23,gate_close=.22,trap_open=.19,trap_close=.14,warning=.09,switch=.11,
 jet_on=.17,jet_off=.12,magnet_contact=.20,belt_contact=.12}
local families={'fan','ferry','rotor','belt','jet','magnet','sweeper','lift','slider','bridge','winch','cannon_aim','fan_aim'}
local controlFamily={lift='lift',slider='slider',bridge='bridge',extend='winch',cannon='cannon_aim',fan='fan_aim'}
local function active() return S.enabled and Audio.enabled and Audio.effects and not Build.classroom end
function S.init(enabled)
 S.enabled=enabled;if not enabled then return end
 local loaded=0
 for name,duration in pairs(durations) do
  local p=assert(playdate.sound.sampleplayer.new('audio/machines/'..name),'Missing machine sound '..name)
  S.shots[name]={player=p,duration=duration,untilAt=0,last=-10}
  loaded=loaded+1;if Loading then Loading.checkpoint(.43+loaded/16*.27,'WINDING THE MACHINES') end
 end
 for i,name in ipairs(families) do S.loops[i]={name=name,player=assert(playdate.sound.sampleplayer.new('audio/machines/'..name)),want=0,volume=0,rate=1}
  S.byName[name]=S.loops[i]
  if Loading then Loading.checkpoint(.70+i/#families*.27,'WINDING THE MACHINES') end
 end
end
function S.play(name,volume,priority)
 if not active() then return end
 local shot=S.shots[name];if not shot or S.clock-shot.last<.10 then return end
 local count=0;local weakest
 for _,v in pairs(S.shots) do if v.untilAt>S.clock then
  count=count+1;if not weakest or (v.priority or 0)<(weakest.priority or 0) then weakest=v end
 end end
 if shot.untilAt<=S.clock and count>=4 then
  if (priority or 1)<=(weakest.priority or 0) then return end
  weakest.player:stop();weakest.untilAt=0
 end
 shot.player:stop();shot.player:setVolume(math.min(.5,volume or .28));shot.player:play(1)
 shot.last=S.clock;shot.untilAt=S.clock+shot.duration;shot.priority=priority or 1
 shot.volume=math.min(.5,volume or .28)
 local total=0;for _,v in pairs(S.shots) do if v.untilAt>S.clock then total=total+(v.volume or 0) end end
 local scale=math.min(1,.65/math.max(.001,total))
 for _,v in pairs(S.shots) do if v.untilAt>S.clock then v.player:setVolume((v.volume or 0)*scale) end end
end
function S.quiet()
 for _,v in ipairs(S.loops) do if v.volume>0 then v.player:stop() end;v.volume=0;v.want=0 end
 for _,v in pairs(S.shots) do if v.untilAt>0 then v.player:stop() end;v.untilAt=0 end
 S.command=nil;S.fresh=true
end
local function snapshot(s,t)
 local m=s.m;s.x,s.y,s.angle=M.pose(m,t)
 s.height=m.kind=='gate' and M.wallHeight(m,t) or m.elevation or 0
 s.width=m.w;s.open=m.kind=='trap' and M.open(m,t) or false
 s.warning=m.kind=='trap' and M.warning(m,t) or false
 s.jet=m.kind=='jet' and (t+(m.phase or 0))%m.period<m.period*.4 or false
 s.hit=m.hitAt;s.moving=false;s.contact=false;s.seen=t
end
-- Conservative hearing bounds include the complete travel range and fan region.
-- Remote machinery still uses world time when it returns; its animation never freezes.
local function hearingBounds(m)
 local r=math.max(m.maxWidth or m.w or 0,m.h or 0)/2+220
 local x0,x1,y0,y1=m.x-r,m.x+r,m.y-r,m.y+r
 if m.toX then x0=math.min(x0,m.toX-r);x1=math.max(x1,m.toX+r);y0=math.min(y0,m.toY-r);y1=math.max(y1,m.toY+r) end
 if m.range then y0=y0-m.range;y1=y1+m.range end
 if m.retract then x0=math.min(x0,m.anchor-r);x1=math.max(x1,m.anchor+(m.maxWidth or m.w)+r) end
 if m.region then local a=m.region;x0=math.min(x0,a[1]-a[3]/2);x1=math.max(x1,a[1]+a[3]/2);y0=math.min(y0,a[2]-a[4]/2);y1=math.max(y1,a[2]+a[4]/2) end
 return x0,x1,y0,y1
end
function S.reset(course)
 S.quiet();S.course=course;S.states={};S.clock=0;S.cells={};S.near=nil;S.cellX=nil;S.cellY=nil
 S.wasDriven=nil;S.commandUntil=nil
 for _,v in pairs(S.shots) do v.last=-10 end
 for _,m in ipairs(course.mechanisms or {}) do local s={m=m};s.x0,s.x1,s.y0,s.y1=hearingBounds(m);snapshot(s,0);S.states[#S.states+1]=s end
end
local function nearby(x,y)
 local ix,iy=math.floor(x/128),math.floor(y/128)
 if ix==S.cellX and iy==S.cellY then return S.near end
 -- Departing states must lose contact history even though they will no longer
 -- be visited. On return snapshot the current world time, never replay old cues.
 local key=ix..','..iy;local list=S.cells[key]
 if not list then
  list={};S.cells[key]=list
  for _,s in ipairs(S.states) do
   if s.x0<=(ix+1)*128 and s.x1>=ix*128 and s.y0<=(iy+1)*128 and s.y1>=iy*128 then list[#list+1]=s end
  end
 end
 local stamp={}
 for _,s in ipairs(list) do s.nearStamp=stamp end
 for _,s in ipairs(S.near or {}) do
  if s.nearStamp~=stamp then s.audible=false;s.contact=false;s.skipped=true end
 end
 S.cellX,S.cellY,S.near=ix,iy,list
 return list
end
local function want(name,volume,rate)
 local v=S.byName[name];if v and volume>v.want then v.want=volume;v.rate=rate or 1 end
end
local function controlValue(p)
 if p.kind=='lift' then return p.target.elevation or p.target.minHeight
 elseif p.kind=='slider' then return p.target.progress or 0
 elseif p.kind=='extend' then return p.target.w
 elseif p.kind=='switch' then return p.target.isOpen and 1 or 0
 else return p.angle or 0 end
end
local reset,update=D.reset,D.update
function D.reset(c) reset(c);S.reset(c) end
function D.update(c,x,y,vx,vy,airborne,crank,a,b)
 local previous=D.active;local before=previous and controlValue(previous)
 local result=update(c,x,y,vx,vy,airborne,crank,a,b)
 local p=D.active
 if p and p~=previous then S.play('connect',.32,3) end
 if result and result.launch then S.play('cannon',.48,4);S.command=nil
 elseif result and result.exit then S.play('release',.30,3);S.command=nil end
 if p then
  local value=controlValue(p);local changed=before and p==previous and math.abs(value-before)>.00001
  if p.kind=='switch' then
   if changed then S.play('switch',.36,3) end
  elseif changed then
   local family=controlFamily[p.kind]
   S.command=family;S.commandUntil=S.clock+.09;S.commandRate=math.min(1.5,.8+math.abs(crank)/30)
   if p.kind=='cannon' or p.kind=='fan' or p.kind=='bridge' then S.play('crank',.17,1) end
   S.wasDriven=p
  elseif math.abs(crank)>0 and S.wasDriven==p then
   S.play('stop',.27,2);S.wasDriven=nil;S.command=nil
  end
 end
 return result
end
function S.update(c,x,y,t,dt,playing,airborne,z)
 S.clock=S.clock+dt
 if not playing or not active() then S.quiet();return end
 if S.course~=c then S.reset(c) end
 for _,v in ipairs(S.loops) do v.want=0 end
 for _,s in ipairs(nearby(x,y)) do
  if x<s.x0 or x>s.x1 or y<s.y0 or y>s.y1 then
   s.audible=false;s.contact=false;s.skipped=true
  else
  if s.skipped then snapshot(s,t-dt);s.skipped=false end
  local m=s.m;local mx,my,angle=M.pose(m,t)
  local radius=math.max(m.w or 0,m.h or 0)/2
  local dx,dy=x-mx,y-my;local distance=math.sqrt(dx*dx+dy*dy)
  local gain=math.max(0,1-math.max(0,distance-radius)/220)^2
  if m.kind=='fan' and m.region then
   local r=m.region;if math.abs(x-r[1])<r[3]/2 and math.abs(y-r[2])<r[4]/2 then gain=math.max(gain,.65) end
  end
  local h=m.kind=='gate' and M.wallHeight(m,t) or m.elevation or 0
  local opened=m.kind=='trap' and M.open(m,t) or false
  local warning=m.kind=='trap' and M.warning(m,t) or false
  local jet=m.kind=='jet' and (t+(m.phase or 0))%m.period<m.period*.4 or false
  local moving=math.abs(mx-s.x)+math.abs(my-s.y)+math.abs(angle-s.angle)*30+math.abs(h-s.height)+math.abs(m.w-s.width)>.02
  local audible=gain>.015
  local edge=audible and s.audible and not S.fresh and t>=s.seen and t-s.seen<=.15
  if audible then
   if m.kind=='fan' then want('fan',gain*.17)
   elseif m.kind=='conveyor' then want('belt',gain*.12)
   elseif m.kind=='jet' and jet then want('jet',gain*.20)
   elseif m.kind=='magnet' then want('magnet',gain*.11)
   elseif moving then
    if m.kind=='lift' then want('lift',gain*.15)
    elseif m.kind=='ferry' then want(m.manual and 'slider' or 'ferry',gain*.15)
    elseif m.kind=='rotor' then want(m.retract and 'winch' or m.manual and 'bridge' or 'rotor',gain*.15)
    elseif m.kind=='sweeper' then want('sweeper',gain*.13) end
   end
   if edge then
    if m.kind=='gate' and math.abs(h-s.height)>.05 and (not s.moving or (h-s.height)*(s.direction or 0)<0) then S.play(h>s.height and 'gate_close' or 'gate_open',gain*.29)
    elseif m.kind=='trap' then
     if opened~=s.open then S.play(opened and 'trap_open' or 'trap_close',gain*.32,2) end
     if warning and not s.warning then S.play('warning',gain*.22,2) end
    elseif m.kind=='jet' and jet~=s.jet then S.play(jet and 'jet_on' or 'jet_off',gain*.30,2)
    elseif (m.kind=='ferry' or m.kind=='lift' or m.kind=='rotor') and s.moving and not moving then S.play('stop',gain*.23) end
   end
   -- Impact is an actual collision timestamp, not proximity to the spring.
   if m.hitAt and m.hitAt~=s.hit and t-m.hitAt<.15 and not S.fresh then
    Audio.players.wall:stop();S.play('spring',gain*.43,4)
   end
   local contact=false
   if m.kind=='conveyor' then contact=not airborne and M.contains(m,x,y,t)
   elseif m.kind=='magnet' then contact=(z or 0)<45 and distance<(m.radius or 140) and distance>10 end
   if contact and not s.contact and not S.fresh then S.play(m.kind=='magnet' and 'magnet_contact' or 'belt_contact',gain*.22) end
   s.contact=contact
  else s.contact=false end
  s.direction=h-s.height;s.x,s.y,s.angle,s.height,s.width=mx,my,angle,h,m.w
  s.open,s.warning,s.jet,s.hit,s.moving,s.audible,s.seen=opened,warning,jet,m.hitAt,moving,audible,t
  end
 end
 -- Keep only the two strongest ambient families, plus the actively cranked one.
 local control=D.active and S.commandUntil and S.clock<S.commandUntil and S.command or nil
 if control then want(control,.20,S.commandRate) end
 local first,second
 for _,v in ipairs(S.loops) do if v.name~=control and v.want>0 then
  if not first or v.want>first.want then second=first;first=v elseif not second or v.want>second.want then second=v end
 end end
 local total=0
 for _,v in ipairs(S.loops) do if v==first or v==second or v.name==control then total=total+v.want end end
 local scale=math.min(1,.30/math.max(.001,total))
 for _,v in ipairs(S.loops) do
  local target=(v==first or v==second or v.name==control) and v.want*scale or 0
  -- Stop unselected voices immediately; fade retained loops without extra voices.
  if target==0 then if v.volume>0 then v.player:stop() end;v.volume=0
  else
   local starting=v.volume==0
   v.volume=v.volume+(target-v.volume)*(1-math.exp(-dt*15))
   if starting or not v.appliedVolume or math.abs(v.volume-v.appliedVolume)>.00001 then
    v.player:setVolume(v.volume);v.appliedVolume=v.volume
   end
   if v.appliedRate~=v.rate then v.player:setRate(v.rate);v.appliedRate=v.rate end
   if starting then v.player:play(0) end
  end
 end
 S.fresh=false
end
