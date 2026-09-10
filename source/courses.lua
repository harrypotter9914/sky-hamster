Courses={}
local function create(name,hint,profile,start,goal)
 local c={name=name,hint=hint,profile=profile,start=start,goal=goal,tiles={},lookup={}}
 function c:add(x,y)
  local k=x..","..y
  if not self.lookup[k] then self.lookup[k]=true;self.tiles[#self.tiles+1]={x=x,y=y} end
 end
 function c:rect(x1,x2,y1,y2) for x=x1,x2 do for y=y1,y2 do self:add(x,y) end end end
 function c:height(x,y)
  for i=1,#self.profile-1 do
   local a,b=self.profile[i],self.profile[i+1]
   if x<b[1] then
    local slope=(b[2]-a[2])/(b[1]-a[1])
    return a[2]+math.max(0,x-a[1])*slope,slope,0
   end
  end
  return self.profile[#self.profile][2],0,0
 end
 Courses[#Courses+1]=c;return c
end
local c=create('01 / CORNER SCHOOL','Build speed, then counter-steer to brake.',{{0,0},{700,0}},{48,48},{512,64})
c:rect(0,3,0,2);c:rect(4,8,1,1);c:rect(8,8,2,5);c:rect(9,12,5,5);c:rect(12,12,2,4);c:rect(13,16,1,3)
c.checkpoint={272,176}
c=create('02 / ZERO-THROTTLE DROP','Leave POWER at 0: gravity rolls you downhill.',{{0,110},{64,110},{256,14},{448,14}},{80,80},{400,80})
c:rect(0,13,1,3)
c=create('03 / MOMENTUM VALLEY','Use the descent to climb the opposite ramp.',{{0,110},{64,110},{224,6},{256,6},{448,92},{544,92}},{80,80},{496,80})
c:rect(0,16,1,3)
c=create('04 / BRAKE AT THE BEND','Gain speed downhill. Brake before the narrow turn.',{{0,100},{64,100},{224,12},{640,12}},{80,80},{560,208})
c:rect(0,6,1,3);c:rect(7,10,2,2);c:rect(10,10,3,6);c:rect(11,14,6,6);c:rect(15,18,5,7)
c.checkpoint={336,80}
c=create('05 / FIRST HOP','Reverse crank charges. A jumps. Keep momentum.',{{0,0},{800,0}},{48,80},{368,80})
c:rect(0,4,1,3);c:rect(6,12,1,3)
c=create('06 / PRECISION LANDING','Choose speed AND jump charge for the landing.',{{0,0},{800,0}},{48,80},{448,80})
c:rect(0,4,1,3);c:rect(7,9,2,2);c:rect(11,15,1,3)
c.checkpoint={272,80}
for _,course in ipairs(Courses) do table.sort(course.tiles,function(a,b) return a.x+a.y<b.x+b.y end) end

