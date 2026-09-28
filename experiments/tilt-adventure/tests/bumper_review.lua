import 'game'
local g=playdate.graphics
local done=false
UI.tiltPointer=function()end
local count=0
local function export(name,draw)
 local im=g.image.new(400,240,g.kColorWhite);g.pushContext(im);draw();g.popContext()
 playdate.datastore.writeImage(im,'ring12-'..name..'.gif');count=count+1
end
local function run()
 Review.select(14);Tilt.calibrating=false;Tilt.ready=true
 local m=Courses[14].mechanisms[1]
 for _,spec in ipairs({{'contact',22.99,0},{'clear',25,0},{'jump',18,12}}) do
  for i=0,7 do
   local a=i*math.pi/4
   Review.place(m.x+spec[2]*math.cos(a),m.y+spec[2]*math.sin(a));Dock.active=nil
   Review.height(spec[3]);Review.animate(.6)
   export(spec[1]..'-'..i,Review.render)
  end
 end
 for i=0,12 do
  local t=i*.03
  export('pulse-'..i,function()
   g.setColor(g.kColorBlack);g.drawText('CONTACT  >  EXPAND  >  SETTLE',24,24)
   MachineArt.bumper({hitAt=0},t,200,138)
   g.drawText('Fixed footprint / one impact sound',20,190)
  end)
 end
 -- Real contact trajectory on a narrow road: near misses must not move the ball.
 Review.place(m.x-22.99,m.y);Review.height(0)
 for i=0,12 do
  Review.animate(i*.03)
  export('world-pulse-'..i,Review.render)
 end
 for i,t in ipairs({0,1.5,1.68,2.1}) do
  export('lesson-'..i,function()UI.lesson('bumper',t)end)
 end
 playdate.datastore.write({complete=true,count=count},'bumper-review-v0.10.12')
 print('PASS: '..count..' native ring contact/clear/jump/expansion frames')
end
function playdate.update()
 if done then return end;done=true
 local ok,err=pcall(run)
 if not ok then playdate.datastore.write({complete=false,error=tostring(err),count=count},'bumper-review-v0.10.12');print('REVIEW ERROR: '..tostring(err)) end
end
