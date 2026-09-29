-- Revision 3: teach, practise, revisit; four complete expeditions end the campaign.
-- Geometry is built from short, separated encounters, never a pile of all machines.
Curriculum={revision=3,chapters={}}
local C=Curriculum
local previous={};local byId={}
for i,c in ipairs(Courses) do previous[i]=c.id;byId[c.id]=c end
C.previousIds=previous
local function buildCourse(id,name,keys,variant)
 local c=Courses.create(name,'',{}, {48,80},{48,80});table.remove(Courses)
 c.id=id;c.shortName=name;c.jump=false;c.mechanisms={};c.pads={};c.checkpoints={};c.sections={};c.features={};c.layoutRevision=3;c.preparedChunkLimit=128
 local x,z=0,0
 local function machine(m) c.mechanisms[#c.mechanisms+1]=m;return m end
 local function pad(p) c.pads[#c.pads+1]=p;return p end
 for order,key in ipairs(keys) do
  local ox,oz=x,z;local width=384;local raised=0;local profile
  local first=#c.mechanisms+1;local firstPad=#c.pads+1
  local function rect(a,b,d,e) c:rect(math.floor(a+ox/32),math.floor(b+ox/32),d,e) end
  local function road(last) rect(0,last,1,3) end
  local function m(kind,px,py,w,h,extra)
   local v=extra or {};v.kind=kind;v.x=ox+px;v.y=py;v.w=w;v.h=h;return machine(v)
  end
  local function ring(px,py) return m('bumper',px,py,28,28,{radius=14,sideHeight=10}) end
  local function fan(controlled)
   local v=m('fan',160,16,40,40,{angle=math.pi/2,initialAngle=math.pi/2,force=55,region={ox+304,80,192,96}})
   if controlled then pad({kind='fan',x=ox+112,y=48,target=v,initialAngle=math.pi/2}) end
  end
  if key=='terrain' then
   width=544
   rect(0,4,1,3);rect(5,8,2,2);rect(8,8,3,6);rect(9,12,6,6);rect(12,12,2,5);rect(13,16,1,3)
   profile={{0,0},{64,0},{192,56},{256,56},{416,0},{544,0}}
   c.features.slope=true;c.features.hairpin=true;c.features.narrow=true
  elseif key=='valley' then
   width=416;road(12);profile={{0,0},{64,0},{160,-56},{224,-56},{352,0},{416,0}};c.features.valley=true
  elseif key=='jump' then
   width=384;rect(0,3,1,3);rect(6,7,2,2);rect(9,11,1,3)
   c.jump=true;c.features.gap=true;c.features.island=true
  elseif key=='gate' then
   width=320;road(9);m('gate',176,80,16,96,{period=6,phase=3,openFor=.45})
  elseif key=='trap' then
   width=320;rect(0,3,1,3);rect(6,9,1,3);m('trap',160,80,64,96,{period=7,phase=4})
  elseif key=='ferry' or key=='slider' then
   width=480;rect(0,3,1,3)
   if key=='slider' then
    width=544;rect(11,14,4,6);rect(13,14,1,3);rect(15,16,1,3);c.features.diagonalRide=true
   else rect(11,14,1,3) end
   local v=m('ferry',168,80,80,80,{toX=ox+312,toY=key=='slider' and 176 or 80,period=12,manual=key=='slider',progress=0,lesson=key=='slider' and 'slider' or nil})
   if key=='slider' then pad({kind='slider',x=v.x,y=v.y,target=v}) end
  elseif key=='rotor' or key=='bridge' then
   width=448;rect(0,3,1,3);rect(9,13,1,3)
   local controlled=key=='bridge'
   local v=m('rotor',208,80,160,64,{period=14,manual=controlled,angle=controlled and math.pi/2 or 0})
   if controlled then pad({kind='bridge',x=ox+80,y=80,target=v,initialAngle=math.pi/2}) end
  elseif key=='sweeper' then
   width=384;rect(0,11,0,4);m('sweeper',208,80,18,60,{range=60,period=5})
  elseif key=='bumper' then
   width=384;rect(0,11,0,4);ring(176,48);ring(272,112)
  elseif key=='fan' or key=='windcontrol' then
   width=448;rect(0,13,0,4);fan(key=='windcontrol')
  elseif key=='onboard' then
   width=608;rect(0,6,1,3);rect(9,10,-3,-1);rect(11,16,-3,-2);rect(15,16,-1,3);rect(17,18,1,3)
   local v=m('rotor',320,96,192,64,{manual=true,lesson='onboard',turnSquare=192,maxWidth=192,angle=math.pi/2})
   v.ports={{x=ox+224,y=96,dx=-1,dy=0},{x=ox+320,y=0,dx=0,dy=-1}}
   pad({kind='bridge',x=ox+176,y=96,target=v,initialAngle=math.pi/2})
   pad({kind='bridge',lesson='onboard',onboard=true,x=v.x,y=v.y,target=v,initialAngle=math.pi/2})
  elseif key=='lift' then
   width=448;rect(0,5,1,3);rect(8,13,1,3);raised=96
   profile={{0,0},{256,0},{256,96},{448,96}}
   local v=m('lift',224,80,64,64,{minHeight=oz,maxHeight=oz+96,elevation=oz})
   pad({kind='lift',x=v.x,y=v.y,target=v});c.features.elevation=true
  elseif key=='cannon' then
   width=448;rect(0,4,1,3);rect(9,13,0,4)
   pad({kind='cannon',x=ox+112,y=80,initialAngle=0});c.jump=true;c.features.flight=true
  elseif key=='conveyor' then
   width=384;rect(0,11,0,4);m('conveyor',208,80,160,96,{angle=variant%2==0 and math.pi or 0,period=5})
  elseif key=='jet' then
   width=384;rect(0,11,0,4);m('jet',208,80,128,96,{angle=math.pi/2,period=5,phase=0})
  elseif key=='extend' then
   width=448;rect(0,4,1,3);rect(11,13,1,3)
   local v=m('rotor',168,80,16,64,{manual=true,retract=true,lesson='extend',anchor=ox+160,maxWidth=192})
   pad({kind='extend',x=ox+112,y=80,target=v})
  elseif key=='switch' then
   width=448;rect(0,4,0,4);rect(5,9,0,1);rect(5,9,3,4);rect(10,13,0,4)
   local a=m('gate',240,32,16,64,{switchGate=true,lesson='switch',isOpen=true,initialOpen=true,lane=1})
   local b=m('gate',240,128,16,64,{switchGate=true,lesson='switch',isOpen=false,initialOpen=false,lane=2});a.partner=b
   pad({kind='switch',x=ox+112,y=80,target=a,initialAngle=.5})
  elseif key=='magnet' then
   width=384;rect(0,11,0,4);m('magnet',208,16,32,32,{angle=0,period=5})
  else error('unknown curriculum encounter '..key) end
  if variant>=100 then
   local difficulty=variant-100
   -- Recombine learned skills inside encounters, while keeping controls and
   -- checkpoints on quiet ground and limiting simultaneous visible machinery.
   if key=='conveyor' and difficulty>=2 then ring(208,48) end
   if key=='bumper' and difficulty>=3 then fan(false) end
   if key=='switch' and difficulty>=2 then
    m('jet',344,128,48,64,{angle=math.pi,period=6,phase=difficulty})
   end
   if key=='onboard' and difficulty>=4 then m('gate',80,80,16,96,{period=7,phase=3}) end
  end
  c.features[key]=true
  profile=profile or {{0,0},{width,0}}
  for _,p in ipairs(profile) do c.profile[#c.profile+1]={ox+p[1],oz+p[2]} end
  -- Checkpoints are on quiet approach stone, before the first moving contact.
  local section={kind=key,x=ox,width=width,z=oz,start={ox+48,80},finish={ox+width-48,80},first=first,last=#c.mechanisms,firstPad=firstPad,lastPad=#c.pads}
  c.sections[#c.sections+1]=section
  if order>1 then c.checkpoints[#c.checkpoints+1]={ox+48,80} end
  x=ox+width;z=oz+raised
  if order<#keys then
   rect(width/32,width/32+3,1,3);c.profile[#c.profile+1]={x+128,z};x=x+128
  end
 end
 c.goal={x-48,80};c.checkpoint=c.checkpoints[1]
 c.note={'Read each landing signal before crossing.','Safe checkpoints separate every encounter.'}
 table.sort(c.tiles,function(a,b)return a.x+a.y<b.x+b.y end)
 return c
end
local function compose(id,name,keys,variant)
 local c=Courses.create(name,'',{{0,0},{1,0}},{48,80},{48,80});table.remove(Courses)
 c.id=id;c.shortName=name;c.jump=true;c.layoutRevision=3
 c.blueprint={keys=keys,variant=variant};c.encounters=#keys
 c.mechanisms={};c.pads={};c.checkpoints={};c.features={}
 return c
end
function C.ensure(c)
 if not c.blueprint or c.materialized then return end
 local name=c.name
 local built=buildCourse(c.id,c.shortName,c.blueprint.keys,c.blueprint.variant)
 for key,value in pairs(built) do c[key]=value end
 c.name=name;c.baseHeight=built.height;c.materialized=true
 if Joinery then Joinery.prepare(c) end
 if HeightIndex then HeightIndex.prepare(c) end
end
local keep={id=true,name=true,shortName=true,hint=true,jump=true,layoutRevision=true,chapter=true,chapterName=true,
 review=true,finale=true,blueprint=true,encounters=true,add=true,rect=true,height=true,baseHeight=true}
function C.release(c)
 if not c or not c.blueprint or not c.materialized then return end
 c.height=c.baseHeight
 for key in pairs(c) do if not keep[key] then c[key]=nil end end
 c.tiles={};c.lookup={};c.profile={{0,0},{1,0}};c.mechanisms={};c.pads={};c.checkpoints={};c.start={48,80};c.goal={48,80}
end
C.compose=compose
local chapters={
 {'Balance',{'legacy-1','legacy-2','legacy-3','legacy-4'},'terrain'},
 {'Leap',{'legacy-5','legacy-6','legacy-7','hop-bends'},'jump','hop-bends'},
 {'Timed gates',{'legacy-8','gate-revisit'},'gate','gate-revisit'},
 {'Vanishing floors',{'legacy-9','trap-revisit'},'trap','trap-revisit'},
 {'Moving decks',{'legacy-10','legacy-13'},'ferry','legacy-13'},
 {'Turning decks',{'legacy-11','legacy-14'},'rotor','legacy-14'},
 {'Moving barriers',{'legacy-12','sweep-revisit'},'sweeper','sweep-revisit'},
 {'Elastic rings',{'bumpers','bumper-slalom'},'bumper','bumper-slalom'},
 {'Crosswinds',{'crosswind','storm-run'},'fan','storm-run'},
 {'Shore controls',{'legacy-15','bridge-workshop'},'bridge','bridge-workshop'},
 {'Onboard controls',{'onboard-turn','onboard-relay','dual-turn','onboard-expedition'},'onboard','onboard-expedition'},
 {'Elevation',{'lift-school','switchback','lift-towers'},'lift','lift-towers'},
 {'Crank ferries',{'crank-ferry','ferry-zigzag'},'slider','ferry-zigzag'},
 {'Wind controls',{'wind-dial','wind-relay'},'windcontrol','wind-relay'},
 {'Cannons',{'legacy-16','cannon-relay','high-flight','legacy-17'},'cannon','legacy-17'},
 {'Conveyors',{'belt-school','belt-bends'},'conveyor','belt-bends'},
 {'Steam',{'jet-school','jet-relay'},'jet','jet-relay'},
 {'Extending roads',{'extend-school','extend-relay'},'extend','extend-relay'},
 {'Route switches',{'switch-school','switch-risk'},'switch','switch-risk'},
 {'Magnetism',{'magnet-school','magnet-relay'},'magnet','magnet-relay'}
}
local order={};local learned={'valley'}
for chapter,spec in ipairs(chapters) do
 learned[#learned+1]=spec[3]
 local info={name=spec[1],first=#order+1,new=spec[3]};C.chapters[#C.chapters+1]=info
 for _,id in ipairs(spec[2]) do
  local c=byId[id]
  if id==spec[4] then
   local keys={};for _,key in ipairs(learned) do keys[#keys+1]=key end
   local names={['gate-revisit']='Gate and leap',['trap-revisit']='Floor memory',['sweep-revisit']='Moving maze',
    ['legacy-17']='Flight review',['lift-towers']='Elevation relay'}
   local name=names[id] or (c and c.shortName)
   c=compose(id,name,keys,chapter);c.review=true
  end
  assert(c,'missing course '..id);c.chapter=chapter;c.chapterName=spec[1]
  if chapter>=2 then c.jump=true end
  order[#order+1]=c
 end
 info.last=#order
end
local finals={
 {'sky-odyssey','Sky odyssey'}, {'grand-expedition','Grand expedition'},
 {'master-crossing','Master crossing'}, {'homeward-voyage','Homeward voyage'}
}
C.allFeatures={};for _,key in ipairs(learned) do C.allFeatures[#C.allFeatures+1]=key end
for i,spec in ipairs(finals) do
 local keys={}
 -- Different encounter orders change where elevation, wind and timing occur.
 local count=#learned
 for j=1,count do keys[j]=learned[(j-1+i*5)%count+1] end
 local encore={{},{'jump','onboard'},{'valley','cannon','slider','terrain'},{'bridge','jump','onboard','lift','cannon','switch','terrain'}}
 for _,key in ipairs(encore[i]) do keys[#keys+1]=key end
 local c=compose(spec[1],spec[2],keys,100+i);c.finale=true;c.chapter=#chapters+1;c.chapterName='Final expeditions'
 c.note={'Every mechanism returns in this expedition.','A checkpoint protects each new encounter.'}
 order[#order+1]=c
end
C.chapters[#C.chapters+1]={name='Final expeditions',first=#order-3,last=#order}
local legacy,create=Courses.legacy,Courses.create
Courses=order;Courses.legacy=legacy;Courses.create=create;Courses.indexById={};Courses.legacyIndex={}
for i,c in ipairs(Courses) do
 c.name=string.format('%02d / %s',i,string.upper(c.shortName));Courses.indexById[c.id]=i
 if c.legacyIndex then Courses.legacyIndex[c.legacyIndex]=i end
end
function Courses.migrate(saved)
 if saved.campaignRevision==3 then return saved end
 local completed,best={},{}
 local function mapped(n)
  local id=saved.campaignRevision==2 and previous[tonumber(n)] or ('legacy-'..tostring(n))
  return id and Courses.indexById[id]
 end
 for key,v in pairs(saved.completed or {}) do local n=mapped(key);if n then completed[n]=v end end
 for key,v in pairs(saved.best or {}) do local n=mapped(key)
  -- Keep wins, but an old short-course time is not a record for a rebuilt voyage.
  if n and not Courses[n].layoutRevision then best[tostring(n)]=v end
 end
 saved.level=mapped(saved.level or 1) or 1;saved.completed=completed;saved.best=best;saved.campaignRevision=3
 return saved
end
