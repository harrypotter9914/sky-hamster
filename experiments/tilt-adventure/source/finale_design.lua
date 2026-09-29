-- Authored finale rooms. Shared machines, different decisions and silhouettes.
-- All turns have level braking terraces; cannon islands require deliberate aim.
FinaleDesign={}
function FinaleDesign.build(c,key,visit,variant,ox,oz,reviewSeed)
 if variant<102 and key~='terrain' then return nil end
 if variant<100 then return nil end
 local theme=reviewSeed and (2+reviewSeed%3) or variant-100
 local flip=(theme+visit)%2==0 and 1 or -1
 local design={route={},style=theme..':'..visit..':'..key}
 local function rect(a,b,d,e) c:rect(ox//32+a,ox//32+b,d,e) end
 local function m(kind,x,y,w,h,extra)
  local v=extra or {};v.kind=kind;v.x=ox+x;v.y=y;v.w=w;v.h=h
  c.mechanisms[#c.mechanisms+1]=v;return v
 end
 local function pad(v) v.x=ox+v.x;c.pads[#c.pads+1]=v;return v end
 local function walk(x,y) design.route[#design.route+1]={kind='walk',x=ox+x,y=y} end
 local function strip(x0,y0,x1,y1)
  -- Centre lines use tile boundaries; two tiles wide, three at a corner.
  if y0==y1 then rect(math.floor(x0/32)-1,math.floor(x1/32),y0//32-1,y0//32)
  else rect(x0//32-1,x0//32,math.min(y0,y1)//32-1,math.max(y0,y1)//32) end
 end
 if key=='terrain' then
  local bend=flip>0 and 224 or -96
  local a=320+(visit-1)*32;local b=a+192+theme*32
  design.width=b+384
  rect(0,6,1,3);strip(192,80,a,80);strip(a,80,a,bend)
  strip(a,bend,b,bend);strip(b,bend,b,80);strip(b,80,b+96,80)
  rect((b+96)//32,(design.width//32)-1,1,3)
  -- The whole dogleg is a level terrace, not a downhill hairpin.
  design.profile={{0,0},{64,0},{192,48},{b+128,48},{b+288,0},{design.width,0}}
  for _,p in ipairs({{192,80},{a,80},{a,bend},{b,bend},{b,80},{b+144,80}}) do walk(p[1],p[2]) end
  design.turns={{ox+a,80},{ox+a,bend},{ox+b,bend},{ox+b,80}}
  c.features.slope=true;c.features.hairpin=true;c.features.narrow=true
 elseif key=='valley' then
  design.width=640
  rect(0,11,1,3);strip(352,80,416,80);strip(416,80,416,208)
  strip(416,208,544,208);strip(544,208,544,80);rect(16,19,1,3)
  design.profile={{0,0},{64,0},{160,-48},{224,-48},{352,0},{640,0}}
  walk(352,80);walk(416,80);walk(416,208);walk(544,208);walk(544,80)
  c.features.valley=true
 elseif key=='jump' then
  design.width=visit==1 and 608 or 736
  local islandY=reviewSeed and (reviewSeed%2==0 and 144 or 16) or (visit==1 and 144 or 16)
  rect(0,4,1,3);rect(7,10,islandY//32-1,islandY//32+1)
  rect(13,16,1,3)
  local function hop(x,y,tx,ty)
   walk(x,y);design.route[#design.route+1]={kind='hop',x=ox+tx,y=ty}
  end
  hop(144,80,256,islandY);hop(320,islandY,448,80)
  if visit>1 then
   strip(480,80,512,80);strip(512,80,512,208);strip(512,208,640,208)
   strip(640,208,640,80);rect(19,22,1,3)
   walk(512,80);walk(512,208);walk(640,208);walk(640,80)
  else rect(17,18,1,3) end
  c.jump=true;c.features.gap=true;c.features.island=true
 elseif key=='cannon' then
  local dx=({160,128,192})[(theme+visit-2)%3+1]
  local dy=({128,160,96})[(theme+visit-2)%3+1]*flip
  local shots=theme==4 and visit==4 and 4 or 2
  rect(0,4,1,3)
  local px,py=128,80
  for i=1,shots do
   local tx,ty=px+dx,py+(i%2==1 and dy or -dy)
   local deltaY=ty-py
   local angle=math.atan(deltaY,tx-px)
   local p=pad({kind='cannon',x=px,y=py,initialAngle=0,landing={ox+tx,ty}})
   -- A broad receiving terrace extends in the direction of flight, allowing
   -- real counter-tilt braking before the next launcher. No instant auto-brake.
   local nextX=px+448+(reviewSeed and math.max(0,reviewSeed-15)*32 or 0)
   local nearY=ty-(deltaY>0 and 48 or 176)
   local farY=ty+(deltaY>0 and 176 or 48)
   rect(tx//32-1,nextX//32+1,math.floor(nearY/32),math.ceil(farY/32)-1)
   design.route[#design.route+1]={kind='fire',pad=p,angle=angle,landing={ox+tx,ty}}
   walk(tx+96,ty+(deltaY>0 and 96 or -96));walk(nextX-64,ty)
   px,py=nextX,ty
  end
  design.width=px+160
  rect(px//32,design.width//32-1,1,3)
  walk(px+64,80)
  c.jump=true;c.features.flight=true
 elseif key=='conveyor' then
  design.width=640
  rect(0,9,0,4);strip(288,80,352,80);strip(352,80,352,208)
  strip(352,208,512,208);strip(512,208,512,80);rect(15,19,0,4)
  m('conveyor',208,80,128,96,{angle=0,speed=50})
  m('conveyor',432,208,96,48,{angle=math.pi,speed=45})
  walk(304,80);walk(352,80);walk(352,208);walk(512,208);walk(512,80)
 elseif key=='jet' then
  design.width=640
  rect(0,7,0,4);strip(224,80,288,80);strip(288,80,288,-64)
  strip(288,-64,480,-64);strip(480,-64,480,80);rect(14,19,0,4)
  m('jet',160,80,64,96,{angle=flip*math.pi/2,period=5,phase=0})
  m('jet',400,-64,64,64,{angle=-flip*math.pi/2,period=6,phase=2})
  walk(112,80);design.route[#design.route+1]={kind='clock',value=2.4}
  walk(224,80);walk(288,80);walk(288,-64);walk(344,-64)
  design.route[#design.route+1]={kind='clock',value=1}
  walk(480,-64);walk(480,80)
 elseif key=='switch' then
  design.width=(visit==1 and 704 or 832)+(reviewSeed and (reviewSeed-19)*64 or 0)
  local top,bottom=visit==1 and 0 or -64,visit==1 and 160 or 224
  local exit=design.width-160
  rect(0,4,top//32-1,bottom//32)
  rect(5,exit//32-1,top//32-1,top//32);rect(5,exit//32-1,bottom//32-1,bottom//32)
  rect(exit//32,design.width//32-1,top//32-1,bottom//32)
  local a=m('gate',240,top,16,64,{switchGate=true,lesson='switch',initialOpen=true,isOpen=true,lane=1})
  local b=m('gate',240,bottom,16,64,{switchGate=true,lesson='switch',initialOpen=false,isOpen=false,lane=2});a.partner=b
  local p=pad({kind='switch',x=112,y=80,target=a,initialAngle=.5})
  m('conveyor',384,top,160,48,{angle=math.pi,speed=42})
  m('jet',384,bottom,96,48,{angle=math.pi,period=6,phase=theme+visit})
  design.route[#design.route+1]={kind='dock',pad=p,crank=0}
  walk(128,top);walk(exit+48,top);walk(exit+80,80)
  design.alternative={{ox+128,bottom},{ox+exit+48,bottom},{ox+exit+80,80}}
 elseif key=='magnet' then
  design.width=608;rect(0,18,-1,5)
  m('magnet',224,0,32,32,{radius=112});m('magnet',416,160,32,32,{radius=112})
  m('conveyor',320,80,96,64,{angle=math.pi,speed=35})
  walk(224,96);walk(320,80);walk(416,48);walk(528,80)
 elseif key=='bumper' then
  design.width=576;rect(0,17,-1,5)
  for i=1,3 do m('bumper',112+i*96,i%2==0 and 128 or 32,28,28,{radius=14,sideHeight=10}) end
  m('fan',352,-16,40,40,{angle=math.pi/2,initialAngle=math.pi/2,force=38,region={ox+352,80,160,96}})
  walk(176,112);walk(272,48);walk(368,112);walk(496,80)
 else return nil end
 design.profile=design.profile or {{0,0},{design.width,0}}
 return design
end
