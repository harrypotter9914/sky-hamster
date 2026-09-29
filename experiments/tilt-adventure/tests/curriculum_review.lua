import 'game'
local g=playdate.graphics;local done=false;local count=0;local exported={}
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext()
 playdate.datastore.writeImage(im,'curr12-'..name..'.gif');count=count+1
 exported[#exported+1]='curr12-'..name..'.gif'
end
local function run()
 for n=1,49 do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local c=Courses[n]
  Review.animate(2.5);Review.place(c.start[1],c.start[2]);Dock.active=nil
  export(n..'-start',Review.render)
  if c.sections then
   for i,s in ipairs(c.sections) do
    UI.mapSection=i
    export(n..'-section-map-'..i,function() UI.map(c,s.x+48,80,0) end)
    Review.place(s.x+math.min(208,s.width/2),80);Dock.active=nil
    export(n..'-section-'..i,Review.render)
   end
  else
   UI.mapSection=nil;export(n..'-map',function() UI.map(c,c.start[1],c.start[2],0) end)
   for i,m in ipairs(c.mechanisms or {}) do
    local x,y=Mechanisms.pose(m,2.5);Review.place(x-36,y);Dock.active=nil
    export(n..'-machine-'..i,Review.render)
   end
  end
 end
 for n=50,53 do
  Review.select(n);Tilt.calibrating=false;Tilt.ready=true
  local c=Courses[n]
  assert(c.roadBaked,'native review did not use packaged road rasters')
  for i,s in ipairs(c.sections) do
   Dock.active=nil;Dock.blocked=nil
   local m=c.mechanisms[s.first];local p=c.pads[s.firstPad]
   local x,y=s.x+208,80
   if m and s.first<=s.last then x,y=Mechanisms.pose(m,2.5)
   elseif p and s.firstPad<=s.lastPad then x,y=p.x,p.y end
   Review.animate(2.5);Review.place(x-36,y);Dock.active=nil
   export(n..'-'..i..'-'..s.kind,Review.render)
   for j,action in ipairs(s.route or {}) do if action.kind=='fire' then
    local cannon=action.pad
    for _,offset in ipairs({-3,0,3}) do
     Review.place(cannon.x,cannon.y);Dock.active=cannon;cannon.angle=action.angle+math.rad(offset)
     export(n..'-'..i..'-shot-'..j..'-'..offset,Review.render)
    end
    Dock.active=nil;Dock.blocked=cannon
    Review.place(action.landing[1],action.landing[2]);Dock.active=nil
    export(n..'-'..i..'-land-'..j,Review.render)
   end end
  end
  for _,i in ipairs({1,math.floor(#c.sections/2),#c.sections}) do
   UI.mapSection=i;local s=c.sections[i]
   export(n..'-map-'..i,function()UI.map(c,s.x+48,80,0)end)
  end
 end
 for n=1,#Courses,6 do export('selector-'..n,function()UI.selector(n,{})end) end
 playdate.datastore.write({complete=true,count=count,courses=#Courses,files=exported},'curriculum-review-v0.12.3')
 print('PASS: '..count..' production expedition encounters, chapter selector and section maps')
end
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err),count=count},'curriculum-review-v0.12.3');print('REVIEW ERROR: '..tostring(err)) end
end
