import 'game'
local g=playdate.graphics
UI.tiltPointer=function() end
local done=false
local count=0
local function export(name)
 local im=g.image.new(400,240,g.kColorWhite)
 g.pushContext(im);Review.render();g.popContext()
 playdate.datastore.writeImage(im,'occ-'..name..'.gif');count=count+1
end
local function select(n)
 Review.select(n);Tilt.calibrating=false;Tilt.ready=true
end
local function review()
 if done then return end
 local seen={}
 -- Native-only alpha/stencil assertion: a hollow prop cannot erase the ball
 -- through its transparent center, and the SDK-sized stencil must be accepted.
 local ring=g.image.new(28,28,g.kColorClear)
 g.pushContext(ring);g.setColor(g.kColorBlack);g.drawRect(2,2,24,24);g.popContext()
 local mask=g.image.new(28,28,g.kColorWhite)
 PropOcclusion.begin(-30,-30,0,0,0)
 PropOcclusion.add(ring,0,0,0,0,36,36,0,-100,100)
 g.pushContext(mask);PropOcclusion.apply(function(x,y,z)return 14+(x-y)*.9,14+(x+y)*.45-z*.65 end);g.popContext()
 assert(mask:sample(14,14)==g.kColorWhite,'transparent prop hole erased ball')
 assert(mask:sample(2,14)==g.kColorBlack,'opaque prop edge failed to occlude')
 PropOcclusion.finish()
 for n,c in ipairs(Courses) do
  for index,m in ipairs(c.mechanisms or {}) do
   local kind=m.retract and 'extend' or m.kind
   if not seen[kind] then
    seen[kind]=n;select(n)
    local times={0,.10,2.9}
    if kind=='gate' then times={0,2.9,3.5}
    elseif kind=='trap' then times={0,3.1,3.5}
    elseif kind=='ferry' or kind=='rotor' then times={0,3.5,5} end
    for phase,t in ipairs(times) do
     Review.animate(t,m.manual and 100 or nil)
     if kind=='bumper' then m.hitAt=0 end
     local cx,cy,rotation=Mechanisms.pose(m,t)
     for i=0,7 do
      local a=i*math.pi/4
      local d=kind=='bumper' and 27.1 or kind=='fan' and 34 or kind=='magnet' and 27 or math.min(m.w/(2*math.max(.0001,math.abs(math.cos(a)))),m.h/(2*math.max(.0001,math.abs(math.sin(a)))))+10
      local bx,by=math.cos(a)*d,math.sin(a)*d
      Review.place(cx+bx*math.cos(rotation)-by*math.sin(rotation),cy+bx*math.sin(rotation)+by*math.cos(rotation))
      Dock.active=nil;Review.height(0)
      export(string.format('%s-%d-%d',kind,phase,i))
      if kind=='bumper' then
       local f=PropOcclusion.apply;PropOcclusion.apply=function() end
       export(string.format('old-spring-%d-%d',phase,i));PropOcclusion.apply=f
       Review.height(36);export(string.format('jump-spring-%d-%d',phase,i));Review.height(0)
      end
     end
    end
   end
  end
 end
 select(27)
 local p=Courses[27].pads[2]
 for phase,a in ipairs({-math.pi/3,0,math.pi/3}) do
  p.angle=a
  for i=0,7 do
   local a=i*math.pi/4;Review.place(p.x+math.cos(a)*37,p.y+math.sin(a)*37)
   Dock.active=nil;Review.height(0);export(string.format('cannon-%d-%d',phase,i))
  end
 end
 for _,spec in ipairs({{'station-extend',38},{'station-switch',40}}) do
  local name,n=spec[1],spec[2];select(n);local p=Courses[n].pads[1]
  for phase=1,3 do for i=0,7 do
   local a=i*math.pi/4;Review.place(p.x-22/1.8+math.cos(a)*27,p.y+22/1.8+math.sin(a)*27)
   p.spin=phase*75;Dock.active=nil;Review.height(0)
   export(string.format('%s-%d-%d',name,phase,i))
  end end
 end
 playdate.datastore.write({complete=true,count=count,kinds=seen},'occlusion-review-v0.10.11')
 print('PASS: '..count..' native direction/animation occlusion snapshots complete')
 done=true
end
function playdate.update()
 if done then return end
 local ok,err=pcall(review)
 if not ok then
  done=true
  playdate.datastore.write({complete=false,error=tostring(err),count=count},'occlusion-review-v0.10.11')
  print('REVIEW ERROR: '..tostring(err))
 end
end
