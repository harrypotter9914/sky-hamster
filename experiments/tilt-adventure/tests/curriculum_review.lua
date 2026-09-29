import 'game'
local g=playdate.graphics;local done=false;local count=0
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext()
 playdate.datastore.writeImage(im,'curr12-'..name..'.gif');count=count+1
end
local function run()
 for n=50,53 do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local c=Courses[n]
  for i,s in ipairs(c.sections) do
   Dock.active=nil;Dock.blocked=nil
   local m=c.mechanisms[s.first];local p=c.pads[s.firstPad]
   local x,y=s.x+208,80
   if m and s.first<=s.last then x,y=Mechanisms.pose(m,2.5)
   elseif p and s.firstPad<=s.lastPad then x,y=p.x,p.y end
   Review.animate(2.5);Review.place(x-36,y);Dock.active=nil
   export(n..'-'..i..'-'..s.kind,Review.render)
  end
  for _,i in ipairs({1,math.floor(#c.sections/2),#c.sections}) do
   UI.mapSection=i;local s=c.sections[i]
   export(n..'-map-'..i,function()UI.map(c,s.x+48,80,0)end)
  end
 end
 for n=1,#Courses,6 do export('selector-'..n,function()UI.selector(n,{})end) end
 playdate.datastore.write({complete=true,count=count,courses=#Courses},'curriculum-review-v0.12.0')
 print('PASS: '..count..' production expedition encounters, chapter selector and section maps')
end
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err),count=count},'curriculum-review-v0.12.0');print('REVIEW ERROR: '..tostring(err)) end
end
