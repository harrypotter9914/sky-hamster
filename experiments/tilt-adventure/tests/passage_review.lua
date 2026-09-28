import 'game'
local g=playdate.graphics
local done=false;local count=0
local function export(name)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);Review.render();g.popContext()
 playdate.datastore.writeImage(im,'pass11-'..name..'.gif');count=count+1
end
local function run()
 for _,n in ipairs({40,41,44}) do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local c=Courses[n];local a,b
  for _,m in ipairs(c.mechanisms) do if m.lane==1 then a=m elseif m.lane==2 then b=m end end
  assert(a and b)
  for phase=1,3 do
   a.isOpen=phase==1;b.isOpen=phase==2
   a.transitionAt=nil;b.transitionAt=nil
   Review.animate(1)
   assert(Passage.state(a,1)==(phase==1) and Passage.state(b,1)==(phase==2))
   for _,pose in ipairs({{'dock',a.x-96,(a.y+b.y)/2,0},
     {'near1',a.x-26,a.y,0},{'near2',b.x-26,b.y,0},
     {'back1',a.x+26,a.y,0},{'back2',b.x+26,b.y,0},
     {'jump1',a.x-26,a.y,40},{'jump2',b.x-26,b.y,65}}) do
    Dock.active=nil;Dock.blocked=nil
    Review.place(pose[2],pose[3]);Review.height(pose[4])
    export(n..'-'..phase..'-'..pose[1])
   end
  end
 end
 playdate.datastore.write({complete=true,count=count},'passage-review-v0.11.0')
 print('PASS: '..count..' dual-lane signs, both states, transition, dock, front/back and airborne frames')
end
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err),count=count},'passage-review-v0.11.0');print('REVIEW ERROR: '..tostring(err)) end
end
