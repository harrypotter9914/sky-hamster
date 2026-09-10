-- Append to main.lua in a classroom diagnostic build only.
local normalUpdate=pd.update
local edgeIndex,frame,wait=1,0,90
local edges={{48,127.8,0,60},{0.2,80,-60,0},{319.8,176,60,0},{48,32.2,0,-60}}
pd.buttonIsPressed=function() return false end
pd.buttonJustPressed=function() return false end
pd.getCrankChange=function() return 0 end
function pd.update()
 if wait>0 then wait=wait-1;return end
 if frame==0 then
  selectLevel(1);lesson=false
  local e=edges[edgeIndex];x,y,vx,vy=e[1],e[2],e[3],e[4]
  camX=(x-y)*0.9;camY=(x+y)*0.45
 end
 normalUpdate();frame=frame+1
 if frame==8 then
  assert(state=='fall' and jumpZ<0 and falls==1 and not support(x,y),'edge fall failed')
  print(string.format('EDGE %d OK x=%.2f y=%.2f z=%.2f',edgeIndex,x,y,jumpZ))
  if Build.freezeEdge then pd.update=function() end;return end
  frame=0;edgeIndex=edgeIndex+1
  if edgeIndex>4 then print('EDGES DONE');pd.update=function() end end
 end
end
