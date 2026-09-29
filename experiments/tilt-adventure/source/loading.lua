-- Cooperative work: every checkpoint yields after graphics contexts are closed.
Loading={busy=false,progress=0,shown=0,time=0,budgetMS=24,maxSlices=64}
local L=Loading
local g=playdate.graphics
local sky,font
local frames={}
function L.checkpoint(progress,label)
 if L.worker and coroutine.running()==L.worker then
  L.progress=math.max(L.progress,progress or L.progress);L.label=label or L.label
  coroutine.yield()
 end
end
function L.working() return L.worker and coroutine.running()==L.worker end
function L.begin(work,label,done)
 if L.busy then return false end
 if Audio then Audio.quiet() end
 L.busy=true;L.progress=0;L.shown=0;L.time=0;L.label=label or 'PREPARING';L.done=done;L.finished=false
 L.worker=coroutine.create(work)
 return true
end
function L.preload(i) frames[i]=frames[i] or g.image.new('loading/run-'..i) end
function L.draw()
 sky=sky or g.image.new('loading/sky');font=font or g.font.new('fonts/ui-bold')
 if font then g.setFont(font) end
 g.setImageDrawMode(g.kDrawModeCopy)
 sky:draw(0,0)
 -- Each pose is generated artwork. The hamster stays upright inside its ball.
 -- Twelve poses/second, with gentle 30 Hz drift; no whole-character rotation.
 local frame=math.floor(L.time*12)%8+1
 frames[frame]=frames[frame] or g.image.new('loading/run-'..frame)
 local bob=math.floor(math.sin(L.time*math.pi*1.5)*2+.5)
 frames[frame]:draw(136,27+bob)
 g.setImageDrawMode(g.kDrawModeFillWhite)
 local width=g.getTextSize('LOADING')
 local tx=math.floor((400-width-20)/2)
 g.drawText('LOADING',tx,151)
 g.setImageDrawMode(g.kDrawModeCopy);g.setColor(g.kColorWhite)
 -- Fixed positions keep the word still: one, two, three dots, then none.
 local dots=math.floor(L.time/.32)%4
 for i=1,dots do g.fillCircleAtPoint(tx+width+5+(i-1)*6,161,1) end
 -- Fill only the interior of the generated winged meter; retain its illustrated rim.
 local fill=math.floor(206*L.shown)
 if fill>0 then
  g.fillRoundRect(97,191,fill,10,5)
  if fill>16 then
   g.setClipRect(99,193,math.max(0,fill-4),6)
   g.setColor(g.kColorBlack)
   local shine=math.floor(L.time*46)%240
   g.drawLine(97+shine,193,94+shine,198)
   g.drawLine(102+shine,193,99+shine,198)
   g.clearClipRect()
  end
 end
 g.setColor(g.kColorBlack)
end
function L.step(dt)
 if Awake then Awake.update() end
 if not L.busy then return false end
 L.time=L.time+(dt or 1/30)
 -- Let the first loading frame reach the display before starting expensive work.
 if L.time>1/30 and not L.finished then
  -- Checkpoints bound each unit of work, not the number of display frames.
  -- Spend a small measured budget on several cheap units, then return to the
  -- system. A hard slice cap also bounds synthetic clocks and coarse timers.
  local started=playdate.getCurrentTimeMilliseconds()
  for slice=1,L.maxSlices do
   local before=L.traceSlice and playdate.getCurrentTimeMilliseconds()
   local ok,err=coroutine.resume(L.worker)
   if not ok then error('Loading: '..tostring(err)) end
   if L.traceSlice then L.traceSlice(L.label,playdate.getCurrentTimeMilliseconds()-before) end
   if coroutine.status(L.worker)=='dead' then L.finished=true;L.progress=1;L.label='READY';break end
   if playdate.getCurrentTimeMilliseconds()-started>=L.budgetMS then break end
  end
 end
 L.shown=L.shown+(L.progress-L.shown)*math.min(1,(dt or 1/30)*14)
 if L.finished and L.shown>.995 then L.shown=1 end
 L.draw()
 if L.finished and L.shown==1 then
  L.busy=false;L.worker=nil
  local done=L.done;L.done=nil;if done then done() end
 end
 return true
end
