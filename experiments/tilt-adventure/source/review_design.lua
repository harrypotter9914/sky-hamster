-- Revisit a skill in a different spatial/task context as the syllabus expands.
ReviewDesign={}
function ReviewDesign.build(c,key,chapter,ox,oz)
 if chapter>=100 then return nil end
 local advanced={terrain=true,valley=true,jump=true,cannon=true,conveyor=true,jet=true,switch=true,magnet=true}
 if advanced[key] then
  return FinaleDesign.build(c,key,1,100+math.max(2,chapter),ox,oz,chapter)
 end
 local d={style='review:'..chapter..':'..key}
 local phase=chapter%3;local wide=chapter>=9
 local function rect(a,b,e,f)c:rect(ox//32+a,ox//32+b,e,f)end
 local function m(kind,x,y,w,h,extra)
  local v=extra or {};v.kind=kind;v.x=ox+x;v.y=y;v.w=w;v.h=h;c.mechanisms[#c.mechanisms+1]=v;return v
 end
 local function pad(v)v.x=ox+v.x;c.pads[#c.pads+1]=v;return v end
 local function road(last)rect(0,last,1,3)end
 if key=='gate' then
  d.width=416+phase*64;road(d.width//32-1)
  m('gate',176,80,16,96,{period=6,phase=3,openFor=.48})
  m('gate',d.width-112,80,16,96,{period=7+phase,phase=phase+1,openFor=.52})
 elseif key=='trap' then
  d.width=512+phase*64
  rect(0,3,1,3);rect(6,8+phase,1,3);rect(11+phase,d.width//32-1,1,3)
  m('trap',160,80,64,96,{period=7,phase=4})
  m('trap',320+phase*32,80,64,96,{period=8+phase,phase=phase})
 elseif key=='ferry' or key=='slider' then
  local shift=phase*32
  local tx=312+shift;local ty=144+phase*32
  d.width=544+shift;rect(0,3,1,3)
  local edge=(tx+40)//32
  rect(edge,edge+2,ty//32-1,ty//32+1);rect(edge+1,edge+2,1,ty//32);rect(edge+3,d.width//32-1,1,3)
  local manual=key=='slider'
  local v=m('ferry',168,80,80,80,{toX=ox+tx,toY=ty,period=12+phase,manual=manual,progress=0,lesson=manual and 'slider' or nil})
  if manual then pad({kind='slider',x=168,y=80,target=v}) end
  c.features.diagonalRide=true
 elseif key=='rotor' or key=='bridge' then
  d.width=512+phase*64;rect(0,3,1,3);rect(9,11,1,3)
  rect(10,11,4,6+phase);rect(12,13+phase,5+phase,6+phase)
  rect(12+phase,13+phase,1,4+phase);rect(14+phase,d.width//32-1,1,3)
  local manual=key=='bridge'
  local v=m('rotor',208,80,160,64,{period=14+phase*2,manual=manual,angle=manual and math.pi/2 or 0})
  if manual then pad({kind='bridge',x=80,y=80,target=v,initialAngle=math.pi/2}) end
 elseif key=='sweeper' then
  d.width=512+phase*64;rect(0,d.width//32-1,0,5)
  m('sweeper',176,80,18,60,{range=60,period=5,phase=phase})
  m('sweeper',d.width-160,112,18,60,{range=48,period=6,phase=phase+2})
 elseif key=='bumper' then
  d.width=512+phase*64;rect(0,d.width//32-1,0,5)
  for i=1,3 do m('bumper',96+i*96,((i+phase)%2)*80+40,28,28,{radius=14,sideHeight=10}) end
  if wide then m('fan',352,0,40,40,{angle=math.pi/2,initialAngle=math.pi/2,force=35,region={ox+352,96,160,96}}) end
 elseif key=='fan' or key=='windcontrol' then
  d.width=576+phase*64;rect(0,7,0,4);rect(8,11,1,2)
  rect(11,12,3,6);rect(13,14+phase,5,6);rect(14+phase,15+phase,1,4);rect(16+phase,d.width//32-1,0,4)
  local angle=chapter%2==0 and math.pi/2 or -math.pi/2
  local v=m('fan',160,16,40,40,{angle=angle,initialAngle=angle,force=50,region={ox+304,64,192,96}})
  if key=='windcontrol' then pad({kind='fan',x=112,y=48,target=v,initialAngle=angle}) end
 elseif key=='onboard' then
  d.width=640+phase*64;rect(0,6,1,3);rect(9,10,6,8);rect(11,15+phase,7,8)
  rect(14+phase,15+phase,1,6);rect(16+phase,d.width//32-1,1,3)
  local v=m('rotor',320,96,192,64,{manual=true,lesson='onboard',turnSquare=192,maxWidth=192,angle=math.pi/2})
  v.ports={{x=ox+224,y=96,dx=-1,dy=0},{x=ox+320,y=192,dx=0,dy=1}}
  pad({kind='bridge',x=176,y=96,target=v,initialAngle=math.pi/2})
  pad({kind='bridge',lesson='onboard',onboard=true,x=320,y=96,target=v,initialAngle=math.pi/2})
 elseif key=='lift' then
  d.width=544+phase*64;d.raised=64+(chapter-12)*8
  rect(0,5,1,3);rect(8,10,1,3);rect(9,10,4,6)
  rect(11,13+phase,5,6);rect(12+phase,13+phase,1,4);rect(14+phase,d.width//32-1,1,3)
  d.profile={{0,0},{256,0},{256,d.raised},{d.width,d.raised}}
  local v=m('lift',224,80,64,64,{minHeight=oz,maxHeight=oz+d.raised,elevation=oz})
  pad({kind='lift',x=224,y=80,target=v});c.features.elevation=true
 elseif key=='extend' then
  local span=128+(chapter-18)*32;d.width=span+352
  rect(0,4,1,3);rect((160+span)//32,d.width//32-1,1,3)
  local v=m('rotor',168,80,16,64,{manual=true,retract=true,lesson='extend',anchor=ox+160,maxWidth=span})
  pad({kind='extend',x=112,y=80,target=v})
 else return nil end
 d.profile=d.profile or {{0,0},{d.width,0}}
 return d
end
