import "CoreLibs/graphics"
import "loading"
import "physics"
import "courses"
import "mechanisms"
import "spatial"
import "physics_tests"
import "campaign"
import "workshop_courses"
import "ui"
import "build"
import "classroom"
import "terrain"
import "road_art"
import "audio"
import "tilt"
import "dock"
import "mechanism_cache"
import "expansion"
import "workshop"
import "machine_art"
import "physics_index"
import "render_index"
import "pose"
import "mechanism_audio"
import "tilt_ui"
import "guide"
import "guide_ui"
if Build.classroom then Classroom.apply() end
if not Loading.booting then
 Audio.init(not Build.classroom)
 MechanismAudio.init(not Build.classroom)
end
local pd,g=playdate,playdate.graphics
pd.display.setRefreshRate(30)
-- Collect transient geometry during spare frame time, before a forced full GC.
if pd.setGCScaling then pd.setGCScaling(0,0) end
local level=1
local course=Courses[level]
local x,y,vx,vy,throttle,elapsed,falls,state,fallTime,braking,ballHeight
local controls=Physics.newControls()
local airborne=false
local jumpZ,jumpV=0,0
local rollAngle=0
local checkpoint=false
local overview=false
local choosing=false
local selected=1
local lesson=true
local briefing=false
local infoPage=1
local title=not Build.classroom
local titleChoice=1
local settings=false
local settingsChoice=1
local gesture=true
local selectorReturn
local saved=pd.datastore and pd.datastore.read('tilt-progress') or {}
saved=Courses.migrate(saved or {})
Guide.seen=saved.guideRevision==3 and (saved.guides or {}) or {}
if saved.jumpGuideRevision~=1 then Guide.seen.jump=nil end
local options=saved.options or {}
UI.motion=options.motion~=false
gesture=options.gesture~=false
if options.effects==false then Audio.toggleEffects() end
if options.music==false then Audio.toggleMusic() end
local completed={}
for k,v in pairs(saved.completed or {}) do if tonumber(k) then completed[tonumber(k)]=v end end
local best=saved.best or {}
local ending=false
local function saveProgress()
 if pd.datastore then pd.datastore.write({campaignRevision=2,completed=completed,best=best,level=level,guideRevision=3,jumpGuideRevision=1,guides=Guide.seen,options={effects=Audio.effects,music=Audio.musicEnabled,motion=UI.motion,gesture=gesture}},'tilt-progress') end
end
level=math.max(1,math.min(#Courses,tonumber(saved.level) or 1));course=Courses[level];selected=level
local jumpEnabled=false
local worldTime=0
local ballImage=g.image.new(28,28,g.kColorClear)
local ballMask=g.image.new(28,28,g.kColorWhite)
local maskPolygon={}
local terrainImage,terrainX,terrainY,terrainCourse
local terrainChunks
local needsPower=false
local prepareTerrain
local cachingTerrain=false
local function reset(full)
 Audio.quiet();Dock.reset(course)
 if full then elapsed=0;falls=0;checkpoint=false end
 worldTime=0
 local point=checkpoint and course.checkpoints[checkpoint] or course.start
 x,y=point[1],point[2];vx,vy,throttle=0,0,0
 state='play';fallTime=0;braking=false;ballHeight=course:height(x,y);controls=Physics.newControls();airborne=false;jumpZ=ballHeight;jumpV=0;rollAngle=0
end
local function beginFall(height,verticalSpeed)
 state='fall';falls=falls+1;fallTime=0
 jumpZ=height;jumpV=verticalSpeed;airborne=false
 Audio.quiet();Audio.play('fall')
end
local function selectLevel(n)
 if not Loading.working() then
  Tilt.startCalibration()
  Loading.begin(function() selectLevel(n) end,'ENTERING COURSE '..n,function() Audio.ui('ready') end)
  return
 end
 briefing=false;ending=false;title=false;level=n;selected=n;course=Courses[level];jumpEnabled=course.jump
 overview=false;choosing=false;lesson=Guide.enter(course);reset(true);Tilt.startCalibration()
 Loading.checkpoint(.08,'PREPARING COURSE')
 if prepareTerrain then prepareTerrain() end
 Loading.checkpoint(1,'READY')
end
local function openSelector()
 if Loading.busy then return end
 if choosing or settings or title or briefing or (lesson and Guide.manual) then return end
 selectorReturn={title=title,overview=overview,lesson=lesson}
 title=false;overview=false;choosing=true;selected=level;Audio.quiet()
end
local function closeSelector()
 choosing=false
 if selectorReturn then
  title=selectorReturn.title;overview=selectorReturn.overview;lesson=selectorReturn.lesson
 end
 selectorReturn=nil
end
reset(true)
local camX,camY=0,0
local function project(a,b,h) return 200+(a-b)*0.9-camX,124+(a+b)*0.45-(h or 0)*0.65-camY end
local function support(a,b) return Mechanisms.support(course,a,b,worldTime) end
local function floorAt(a,b) return Mechanisms.floor(course,a,b,worldTime) end
local function tileGeometry(t)
 local a,b=t.x*32,t.y*32
 if not t.renderCache then
  local function fixed(x,y) return 200+(x-y)*0.9,124+(x+y)*0.45-course:height(x,y)*0.65 end
  local p,q=fixed(a,b);local r,s=fixed(a+32,b);local u,v=fixed(a+32,b+32);local w,z=fixed(a,b+32)
  local cx,cy=fixed(a+16,b+16);local _,slope=course:height(a+16,b+16)
  local sign=slope<0 and 1 or -1;local tx,ty=fixed(a+16+sign*8,b+16)
  t.renderCache={p,q,r,s,u,v,w,z,cx,cy,slope,sign,tx,ty}
 end
 return t.renderCache
end
local function paintTile(t)
 local _=tileGeometry(t)
 local c=t.renderCache
 local p,q,r,s=c[1]-camX,c[2]-camY,c[3]-camX,c[4]-camY
 local u,v,w,z=c[5]-camX,c[6]-camY,c[7]-camX,c[8]-camY
 if not cachingTerrain and (math.max(p,r,u,w)<0 or math.min(p,r,u,w)>400 or math.max(q,s,v,z)<42 or math.min(q,s,v,z)>212) then return end
 g.setColor(g.kColorBlack)
 local edgeX=not course.lookup[(t.x+1)..','..t.y]
 local edgeY=not course.lookup[t.x..','..(t.y+1)]
 if edgeX then g.fillPolygon(r,s,u,v,u,v+12,r,s+12) end
 if edgeY then g.fillPolygon(w,z,u,v,u,v+12,w,z+12) end
 g.setColor(g.kColorWhite);g.fillPolygon(p,q,r,s,u,v,w,z)
 g.setColor(g.kColorBlack)
 -- Only exposed edges get a heavy outline; internal tile borders are hidden.
 if not course.lookup[t.x..','..(t.y-1)] then g.drawLine(p,q,r,s) end
 if not course.lookup[(t.x+1)..','..t.y] then g.drawLine(r,s,u,v) end
 if not course.lookup[t.x..','..(t.y+1)] then g.drawLine(u,v,w,z) end
 if not course.lookup[(t.x-1)..','..t.y] then g.drawLine(w,z,p,q) end
 RoadArt.draw(t,c[11],c[9]-camX,c[10]-camY)
 g.setColor(g.kColorWhite)
 if edgeX then g.drawLine(r+1,s+4,u,v+4);g.drawLine((r+u)/2,(s+v)/2+5,(r+u)/2,(s+v)/2+10) end
 if edgeY then g.drawLine(w+1,z+3,u,v+3);g.drawLine((w+u)/2,(z+v)/2+4,(w+u)/2,(z+v)/2+10) end
 g.setColor(g.kColorBlack)
 local sx=c[11]
 local cx,cy=c[9]-camX,c[10]-camY
 if math.abs(sx)>0.01 and (t.x+t.y)%4==0 then
  -- Arrow points DOWN the slope, independent of the travel direction.
  local sign=c[12]
  local tipX,tipY=c[13]-camX,c[14]-camY
  g.drawLine(cx,cy,tipX,tipY);g.drawLine(tipX,tipY,tipX-sign*5,tipY-3);g.drawLine(tipX,tipY,tipX-sign*5,tipY+2)
 end
end
local function warmTileSprites()
 if not pd.geometry then return end
 if terrainCourse and terrainCourse~=course then for _,t in ipairs(terrainCourse.tiles) do t.surface=nil end end
 local cache={};local oldX,oldY=camX,camY
 cachingTerrain=true
 for tileIndex,t in ipairs(course.tiles) do
  local c=tileGeometry(t)
  local left=math.floor(math.min(c[1],c[3],c[5],c[7]))-1
  local top=math.floor(math.min(c[2],c[4],c[6],c[8]))-1
  local w=math.ceil(math.max(c[1],c[3],c[5],c[7])-left)+2
  local h=math.ceil(math.max(c[2],c[4],c[6],c[8])-top)+14
  local edges=0
  if not course.lookup[(t.x+1)..','..t.y] then edges=edges+1 end
  if not course.lookup[(t.x-1)..','..t.y] then edges=edges+2 end
  if not course.lookup[t.x..','..(t.y+1)] then edges=edges+4 end
  if not course.lookup[t.x..','..(t.y-1)] then edges=edges+8 end
  local key=string.format('%d/%d/%d/%.2f/%.2f/%.2f/%.2f/%.2f/%.2f/%.2f/%.2f',t.x%4+t.y%4*4,edges,(t.x+t.y)%4,c[1]-left,c[2]-top,c[3]-left,c[4]-top,c[5]-left,c[6]-top,c[7]-left,c[8]-top)
  local im=cache[key]
  if not im then
   im=g.image.new(w,h,g.kColorClear);camX,camY=left,top
   g.pushContext(im);paintTile(t);g.popContext();cache[key]=im
  end
  t.surface={image=im,x=left,y=top}
  if tileIndex%24==0 then Loading.checkpoint(.3+.35*tileIndex/#course.tiles,"BUILDING STONE ROAD") end
 end
 camX,camY=oldX,oldY;cachingTerrain=false
end
local function drawTile(t)
 local s=t.surface
 if s then s.image:draw(s.x-camX,s.y-camY) else paintTile(t) end
end
prepareTerrain=function()
 if terrainCourse==course then return end
 Loading.checkpoint(.12,"GATHERING THE STONES")
 RoadArt.warm(course)
 Loading.checkpoint(.3,"BUILDING STONE ROAD")
 warmTileSprites()
 Loading.checkpoint(.66,"WINDING THE MACHINES")
 UI.markerOffset(course,course.start);UI.markerOffset(course,course.goal)
 for _,point in ipairs(course.checkpoints) do UI.markerOffset(course,point) end
 -- Allocate slope occlusion and HUD caches before the playable frame.
 Spatial.occluders(course,0,project,0,0,400,240,-1e9)
 UI.hud(course,level,jumpEnabled,0,0,0,0,0)
 Loading.checkpoint(.75,"LOOKING TO THE SKY")
 if Build.terrainMode=='chunks' then
  terrainImage=nil
  terrainChunks=Terrain.new(course,function(image,tiles,ox,oy)
   local oldX,oldY=camX,camY;camX,camY=ox,oy;cachingTerrain=true
   g.pushContext(image);for _,tile in ipairs(tiles) do drawTile(tile) end;g.popContext()
   cachingTerrain=false;camX,camY=oldX,oldY
  end)
  Terrain.warm(terrainChunks,(x-y)*0.9,(x+y)*0.45-ballHeight*0.65)
  terrainCourse=course;collectgarbage('collect');return
 end
 terrainChunks=nil
 local minX,minY,maxX,maxY=1e9,1e9,-1e9,-1e9
 for _,tile in ipairs(course.tiles) do
  for dx=0,1 do for dy=0,1 do
   local x,y=(tile.x+dx)*32,(tile.y+dy)*32
   local sx,sy=200+(x-y)*0.9,124+(x+y)*0.45-course:height(x,y)*0.65
   minX,minY=math.min(minX,sx),math.min(minY,sy);maxX,maxY=math.max(maxX,sx),math.max(maxY,sy+12)
  end end
 end
 terrainX,terrainY=math.floor(minX)-2,math.floor(minY)-2
 terrainImage=g.image.new(math.ceil(maxX-terrainX)+3,math.ceil(maxY-terrainY)+3,g.kColorClear)
 local oldX,oldY=camX,camY;camX,camY=terrainX,terrainY;cachingTerrain=true
 g.pushContext(terrainImage);for _,tile in ipairs(course.tiles) do drawTile(tile) end;g.popContext()
 cachingTerrain=false;camX,camY=oldX,oldY;terrainCourse=course
 -- Clear transition allocations before timed play rather than during a jump.
 collectgarbage('collect')
end
local function marker(point,label,foreground)
 if not point then return end
 -- A station at the spawn already has a callout; avoid stacking START over its barrel.
 if label=='START' then
  for _,pad in ipairs(course.pads or {}) do
   if (point[1]-pad.x)^2+(point[2]-pad.y)^2<28^2 then return end
  end
 end
 local p,q=project(point[1],point[2],course:height(point[1],point[2]))
 if p < -70 or p>440 or q<50 or q>210 then return end
 local text=label=='SAVE' and 'CHECK' or label=='SAVED' and 'SAVED' or label=='GOAL' and 'FINISH' or 'START'
 if not foreground then
 g.setColor(g.kColorBlack);g.drawEllipseInRect(p-11,q-5,22,10)
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(p,q,3);g.setColor(g.kColorBlack);g.drawCircleAtPoint(p,q,3)
 return
 end
 local ox,oy=UI.markerOffset(course,point)
 local tx=math.max(5,math.min(323,p+ox));local ty=math.max(46,math.min(176,q+oy))
 -- Raised sign with a leader to the exact pad, never text on the road surface.
 g.setColor(g.kColorBlack)
 g.drawLine(p,q,math.max(tx+4,math.min(tx+68,p)),math.max(ty+3,math.min(ty+20,q)))
 UI.worldSign(text,tx,ty)
 if label=='GOAL' then
  g.drawLine(p-15,q,p-15,q-23)
  for i=0,2 do for j=0,1 do if (i+j)%2==0 then g.fillRect(p-15+i*4,q-23+j*4,4,4) end end end
 end
end
if not Loading.busy and not Loading.booting then prepareTerrain() end
local function renderWorld()
 -- Hold the camera at the edge while the ball falls away from the track.
 if state~='fall' then camX=(x-y)*0.9;camY=(x+y)*0.45-ballHeight*0.65 end
 g.clear(g.kColorWhite)
 if terrainChunks then Terrain.draw(terrainChunks,camX,camY) else terrainImage:draw(terrainX-camX,terrainY-camY) end
 if state~='fall' and support(x,y) then
  local sx,sy=project(x,y,floorAt(x,y))
  g.setColor(g.kColorBlack);g.fillEllipseInRect(sx-8,sy-2,16,4)
  if not airborne and controls.charge>0.05 then
   for i=0,3 do local yy=sy-2-i*(2-controls.charge);g.drawLine(sx-4,yy,sx+4,yy-1) end
  end
 end
 Pose.begin(worldTime)
 Mechanisms.draw(RenderIndex.view(course,project),worldTime,project)
 Dock.draw(course,project)
 marker(course.start,'START');for i,point in ipairs(course.checkpoints) do marker(point,checkpoint and i<=checkpoint and 'SAVED' or 'SAVE') end;marker(course.goal,'GOAL')
 -- Rolling shell and rotating hamster face follow distance travelled.
 local ground=floorAt(x,y)
 local bx,shadowY=project(x,y,ground)
 local _,by=project(x,y,(airborne or state=='fall') and jumpZ or ballHeight)
 local squash=state=='play' and not airborne and controls.charge*4 or 0
 by=by-12+squash
 local radius=11
 local screenX,screenY=bx,by
 g.pushContext(ballImage);g.clear(g.kColorClear);bx,by=14,14
 g.setColor(g.kColorWhite);g.fillCircleAtPoint(bx,by,radius)
 g.setColor(g.kColorBlack);g.drawCircleAtPoint(bx,by,radius)
 local function rot(a,b) return bx+a*math.cos(rollAngle)-b*math.sin(rollAngle),by+a*math.sin(rollAngle)+b*math.cos(rollAngle) end
 if radius>7 then
  local ex,ey=rot(-4,-4);g.fillCircleAtPoint(ex,ey,3)
  ex,ey=rot(4,-4);g.fillCircleAtPoint(ex,ey,3)
  g.setColor(g.kColorWhite);g.fillCircleAtPoint(bx,by+1,6)
  g.setColor(g.kColorBlack);g.drawCircleAtPoint(bx,by+1,6)
  ex,ey=rot(-3,-1);g.fillCircleAtPoint(ex,ey,1)
  ex,ey=rot(3,-1);g.fillCircleAtPoint(ex,ey,1)
  ex,ey=rot(0,3);g.fillCircleAtPoint(ex,ey,1)
  ex,ey=rot(8,0);local fx,fy=rot(-8,0);g.drawLine(ex,ey,fx,fy)
 end
 g.popContext()
 local left,top=screenX-14,screenY-14
 local z=(airborne or state=='fall') and jumpZ or ballHeight
 z=z-squash/0.65
 local boxes=Spatial.occluders(course,worldTime,project,left,top,28,28,z)
 if #boxes>0 then
 -- Copy the native silhouette once instead of sampling 784 pixels across the SDK boundary.
 local silhouette=ballImage:getMaskImage()
 g.pushContext(ballMask);g.clear(g.kColorWhite)
 if silhouette then silhouette:draw(0,0) end
 g.setColor(g.kColorBlack)
 for _,box in ipairs(boxes) do
  local poly=Spatial.maskPolygon(box,x,y,project,left,top,maskPolygon)
  if poly then g.fillPolygon(table.unpack(poly)) end
 end
 g.popContext();ballImage:setMaskImage(ballMask)
 end
 ballImage:draw(left,top)
 Pose.finish()
 marker(course.start,'START',true);for i,point in ipairs(course.checkpoints) do marker(point,checkpoint and i<=checkpoint and 'SAVED' or 'SAVE',true) end;marker(course.goal,'GOAL',true)
 if state=='play' and not Dock.active and not Tilt.calibrating and not lesson then
  UI.tiltPointer(screenX,screenY,Tilt.dx or 0,Tilt.dy or 0,Tilt.power or 0)
 end
 UI.hud(course,level,jumpEnabled,throttle,controls.charge,elapsed,falls,math.sqrt(vx*vx+vy*vy))
 if state=='play' and not lesson and not Tilt.calibrating then UI.dockStatus(Dock.status()) end
 if controls.flash>0 then
  UI.panel(99,48,202,22);g.drawTextAligned('Turn again for POWER',200,51,kTextAlignment.center)
 elseif needsPower and state=='play' then
  UI.powerHint:draw(87,48)
 end if state=='win' then
  UI.result(elapsed,falls,best[tostring(level)] or elapsed,level==#Courses)
 end
end
local last=pd.getCurrentTimeMilliseconds()
function pd.update()
 local now=pd.getCurrentTimeMilliseconds();local dt=math.min((now-last)/1000,0.05);last=now
 if Loading.busy then Loading.step(dt);pd.getCrankChange();return end
 MachineArt.time=worldTime
 local wasCalibrating=Tilt.calibrating
 Tilt.update(dt)
 if wasCalibrating and not Tilt.calibrating then Audio.ui("ready") end
 if ending then
  Audio.quiet();pd.getCrankChange()
  if pd.buttonJustPressed(pd.kButtonA) then ending=false;title=true
  elseif pd.buttonJustPressed(pd.kButtonB) then ending=false;openSelector() end
  UI.ending(completed);return
 end
 local started=false
 needsPower=false
 if settings then
  Audio.quiet();pd.getCrankChange()
  local previousChoice=settingsChoice
  if pd.buttonJustPressed(pd.kButtonUp) then settingsChoice=math.max(1,settingsChoice-1) end
  if pd.buttonJustPressed(pd.kButtonDown) then settingsChoice=math.min(4,settingsChoice+1) end
  if settingsChoice~=previousChoice then Audio.ui('move') end
  if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
   if settingsChoice==1 then Audio.toggleEffects() elseif settingsChoice==2 then Audio.toggleMusic()
   elseif settingsChoice==3 then UI.motion=not UI.motion else gesture=not gesture end
   saveProgress();Audio.ui('toggle')
  end
  if pd.buttonJustPressed(pd.kButtonB) then settings=false;saveProgress();Audio.ui("back") end
  UI.settings(settingsChoice,Audio.effects,Audio.musicEnabled,gesture);return
 end
 if title then
  if pd.buttonJustPressed(pd.kButtonUp) then titleChoice=math.max(1,titleChoice-1);Audio.ui('move') end
  if pd.buttonJustPressed(pd.kButtonDown) then titleChoice=math.min(2,titleChoice+1);Audio.ui('move') end
  if pd.buttonJustPressed(pd.kButtonA) then
   Audio.ui('confirm')
   if titleChoice==1 then Tilt.startCalibration();selectLevel(level)
   else settings=true;settingsChoice=1 end
  end
  pd.getCrankChange();Audio.quiet();UI.title(titleChoice,Audio.effects,Audio.musicEnabled);return
 end
 if state=='dead' and not choosing then
  Audio.quiet()
  if pd.buttonJustPressed(pd.kButtonA) then Audio.ui('confirm');Loading.begin(function() reset(false);Loading.checkpoint(1,'READY') end,'BACK TO THE TRACK');return
  else
   if pd.buttonJustPressed(pd.kButtonB) then Audio.ui('confirm');openSelector() end
   pd.getCrankChange();UI.failure(falls,checkpoint);return
  end
 end
 if choosing then
  Audio.quiet();local previous=selected
  if pd.buttonJustPressed(pd.kButtonLeft) then selected=UI.moveSelection(selected,'left',#Courses) end
  if pd.buttonJustPressed(pd.kButtonRight) then selected=UI.moveSelection(selected,'right',#Courses) end
  if pd.buttonJustPressed(pd.kButtonUp) then selected=UI.moveSelection(selected,'up',#Courses) end
  if pd.buttonJustPressed(pd.kButtonDown) then selected=UI.moveSelection(selected,'down',#Courses) end
  if selected~=previous then Audio.ui('move') end
  if pd.buttonJustPressed(pd.kButtonA) then Audio.ui('confirm');selectLevel(selected)
  elseif pd.buttonJustPressed(pd.kButtonB) then Audio.ui('back');closeSelector() end
  pd.getCrankChange();UI.selector(selected,completed);return
 end
 if briefing then
  Audio.quiet();pd.getCrankChange();Tilt.jump=false
  local pages=UI.goalPages(course,level)
  if pd.buttonJustPressed(pd.kButtonB) then Audio.ui("back");briefing=false;Tilt.cooldown=.75;Tilt.armed=false
  elseif pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonRight) then Audio.ui("move");infoPage=infoPage%#pages+1
  elseif pd.buttonJustPressed(pd.kButtonLeft) then Audio.ui("move");infoPage=(infoPage-2)%#pages+1 end
  UI.goal(course,level,infoPage);return
 end
 if overview then
  Audio.quiet()
  if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then Audio.ui("back");overview=false end
  pd.getCrankChange();UI.map(course,x,y,worldTime);return
 end
 if Tilt.calibrating then Audio.quiet();pd.getCrankChange();UI.calibration();return end
 if lesson then
  Audio.quiet();if Guide.time==0 and not Guide.manual then Audio.ui("unlock") end;Guide.time=Guide.time+dt
  if pd.buttonJustPressed(pd.kButtonA) then Audio.ui("confirm");lesson=Guide.advance();saveProgress();started=true;Tilt.jump=false;Tilt.cooldown=.75
  elseif pd.buttonJustPressed(pd.kButtonB) then
   Audio.ui('back');if Guide.manual then lesson=false;Tilt.jump=false;Tilt.cooldown=.75;Tilt.armed=false else Guide.replay() end
  end
  pd.getCrankChange();renderWorld()
  if lesson then UI.lesson(Guide.key(),Guide.time) end
  return
 end

 if state=='play' and pd.buttonJustPressed(pd.kButtonLeft) then lesson=Guide.enter(course,true);Audio.quiet();Audio.ui('confirm');pd.getCrankChange();UI.lesson(Guide.key(),0);return end
 if state=='play' and pd.buttonJustPressed(pd.kButtonRight) then briefing=true;infoPage=1;Audio.quiet();Audio.ui('confirm');pd.getCrankChange();UI.goal(course,level,infoPage);return end
 if state=='play' and not Dock.active and pd.buttonJustPressed(pd.kButtonDown) then Audio.ui('confirm');Tilt.startCalibration();return end
 if state=='play' and not Dock.active and pd.buttonJustPressed(pd.kButtonUp) then overview=true;Audio.quiet();Audio.ui('confirm');return end
 local lifted=Tilt.consumeJump() and gesture
 if not started and not Dock.active and (pd.buttonJustPressed(pd.kButtonA) or lifted) then
  if state=='win' and pd.buttonJustPressed(pd.kButtonA) then
   if level==#Courses then ending=true else selectLevel(level+1) end
   return
  elseif jumpEnabled and state=='play' and not airborne and (lifted or Tilt.cooldown<=0) then
   local _,riding=support(x,y)
   if riding and (riding.kind=='ferry' or riding.kind=='rotor') then
    local ax,ay=Mechanisms.carry(riding,x,y,worldTime,worldTime+1/120)
    vx,vy=vx+(ax-x)*120,vy+(ay-y)*120
   end
   airborne=true;jumpZ=ballHeight;jumpV=150;controls.charge=0;Tilt.cooldown=.75;Tilt.armed=false
   Audio.play('jump')
  end
 end
 if pd.buttonJustPressed(pd.kButtonB) and state=='win' then Audio.ui('confirm');Loading.begin(function() reset(true);Loading.checkpoint(1,'READY') end,'TRYING AGAIN');return end local crank=pd.getCrankChange()
 if state=='play' and not overview then
  elapsed=elapsed+dt
  -- Control meters are updated after reading direction.
  local dx,dy=Tilt.dx or 0,Tilt.dy or 0
  throttle=Tilt.power;controls.power=throttle;controls.charge=0
  local dock=Dock.update(course,x,y,vx,vy,airborne,crank,pd.buttonJustPressed(pd.kButtonA),pd.buttonJustPressed(pd.kButtonB))
  if dock then
   x,y=dock.x,dock.y;vx,vy=0,0;throttle=0;ballHeight=floorAt(x,y)
   if dock.launch then vx,vy=dock.vx,dock.vy;airborne=true;jumpZ=ballHeight;jumpV=150 end
  end
  local locked=dock and dock.locked
  if locked then worldTime=worldTime+dt end
  braking=false
  local steps=math.max(4,math.ceil(math.sqrt(vx*vx+vy*vy)*dt/3))
  for _=1,(locked and 0 or steps) do
   local step=dt/steps
   local oldX,oldY=x,y
   local beforeTime=worldTime
   vx,vy=Mechanisms.wind(course,x,y,vx,vy,(airborne and jumpZ or ballHeight)-floorAt(x,y),step,worldTime)
   local _,riding=support(x,y)
   worldTime=worldTime+step
   if not airborne and riding and (riding.kind=="ferry" or riding.kind=="rotor") then
    x,y=Mechanisms.carry(riding,x,y,beforeTime,worldTime)
   end
   if airborne then
    local oldZ=jumpZ
    jumpZ,jumpV=Physics.air(jumpZ,jumpV,step)
    x,y=x+vx*step,y+vy*step
    local oldVX,oldVY=vx,vy
    x,y,vx,vy=Mechanisms.collide(course,x,y,vx,vy,jumpZ-course:height(x,y),worldTime,step)
    local floor=floorAt(x,y)
    local topContact=support(x,y) and oldZ>=floor and jumpZ<=floor and jumpV<0
    -- A descending top crossing is a landing, even if this substep penetrated the slab.
    if not topContact then x,y,vx,vy=Spatial.sides(course,x,y,vx,vy,jumpZ,worldTime) end
    if vx~=oldVX or vy~=oldVY then Audio.impact(math.sqrt((vx-oldVX)^2+(vy-oldVY)^2)) end
    floor=floorAt(x,y)
    if support(x,y) and jumpZ<=floor and oldZ>=floor and jumpV<0 then
     airborne=false;ballHeight=floor;jumpZ=floor;jumpV=0
     Audio.play('land',0.45)
    elseif jumpZ < -140 then beginFall(jumpZ,jumpV);break end
   else
    local _,sx,sy=course:height(x,y)
    local b;vx,vy,b=Physics.step(vx,vy,dx,dy,throttle,sx,sy,step);braking=braking or b
    x,y=x+vx*step,y+vy*step
    local oldVX,oldVY=vx,vy
    x,y,vx,vy=Mechanisms.collide(course,x,y,vx,vy,0,worldTime,step)
    if vx~=oldVX or vy~=oldVY then Audio.impact(math.sqrt((vx-oldVX)^2+(vy-oldVY)^2)) end
    if not support(x,y) then beginFall(ballHeight,0);break end
    local targetHeight=floorAt(x,y)
    if targetHeight>ballHeight+10 then
     x,y,vx,vy=Spatial.sides(course,x,y,vx,vy,ballHeight,worldTime)
     if floorAt(x,y)>ballHeight+10 then x,y=oldX,oldY;vx,vy=-vx*.15,-vy*.15 end
    elseif targetHeight<ballHeight-10 then
     airborne=true;jumpZ=ballHeight;jumpV=0
    else ballHeight=targetHeight;jumpZ=ballHeight end
   end
   local travel=math.sqrt((x-oldX)^2+(y-oldY)^2)
   local sign=(vx-vy)<0 and -1 or 1
   rollAngle=(rollAngle+sign*travel/11)%(math.pi*2)
  end
  if not airborne and state=='play' then for i,point in ipairs(course.checkpoints) do
   if i>(checkpoint or 0) and math.abs(x-point[1])<14 and math.abs(y-point[2])<14 then checkpoint=i;Audio.play('checkpoint') end
  end end
  if state=='play' and not airborne and math.abs(x-course.goal[1])<17 and math.abs(y-course.goal[2])<22 then state='win';completed[level]=true;local key=tostring(level);best[key]=math.min(best[key] or math.huge,elapsed);saveProgress();Audio.play('win') end
 elseif state=='fall' and not overview then
  fallTime=fallTime+dt
  local steps=math.max(4,math.ceil(math.sqrt(vx*vx+vy*vy)*dt/3))
  for _=1,steps do
   local step=dt/steps;worldTime=worldTime+step
   jumpZ,jumpV=Physics.air(jumpZ,jumpV,step)
   x,y=x+vx*step,y+vy*step
   -- Falling remains world-space motion: the sphere clears the platform lip.
   x,y,vx,vy=Spatial.sides(course,x,y,vx,vy,jumpZ,worldTime)
  end
  if fallTime>0.8 then if Build.classroom then reset(false) else state='dead' end end
 end
 MechanismAudio.update(course,x,y,worldTime,dt,state=='play',airborne,(airborne and jumpZ or ballHeight)-course:height(x,y))
 Audio.update(dt,state=='play' and not airborne,math.sqrt(vx*vx+vy*vy),controls.charge)
 if state=='dead' then UI.failure(falls,checkpoint);return end
 renderWorld()
end
pd.getSystemMenu():addMenuItem('Level select',openSelector)
pd.getSystemMenu():addMenuItem('Map / pause',function() overview=not overview end)
pd.getSystemMenu():addMenuItem('Restart level',function() choosing=false;overview=false;reset(true) end)
if not Build.classroom then
 -- Playdate permits three custom system menu entries: replace restart with home.
 pd.getSystemMenu():removeAllMenuItems()
 pd.getSystemMenu():addMenuItem('Level select',openSelector)
 pd.getSystemMenu():addMenuItem('Map / pause',function() if Loading.busy then return end;if not title and not briefing and not (lesson and Guide.manual) then overview=not overview end;Audio.quiet() end)
 pd.getSystemMenu():addMenuItem('Title / settings',function() if Loading.busy then return end;briefing=false;settings=false;ending=false;title=true;choosing=false;overview=false;titleChoice=1;Audio.quiet() end)
end
pd.gameWillPause=function() Audio.pause();saveProgress() end
pd.gameWillResume=function() last=pd.getCurrentTimeMilliseconds();Tilt.cooldown=.75;Tilt.armed=false;Audio.resume() end
