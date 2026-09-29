-- The dial supplies uphill thrust: changing wind direction has a traversal role.
WindDesign={}
function WindDesign.build(c,ox,oz,variant)
 local extra=(variant%3)*32;local width=896+extra*2;local top=192+extra*.75
 local initial=variant%2==0 and math.pi/2 or math.pi
 c:rect(ox//32,ox//32+width//32-1,1,3)
 c:rect(ox//32+4,ox//32+5,0,0)
 local m={kind='fan',x=ox+160,y=16,w=40,h=40,angle=initial,initialAngle=initial,
  force=72,region={ox+384+extra/2,80,384+extra,96},assistAngle=0,assistSlope=.75}
 c.mechanisms[#c.mechanisms+1]=m
 local p={kind='fan',x=ox+112,y=80,target=m,initialAngle=initial}
 c.pads[#c.pads+1]=p
 c.features=c.features or {};c.features.slope=true;c.features.windAssist=true
 return {width=width,profile={{0,0},{224,0},{480+extra,top},{608+extra,top},{800+extra*2,0},{width,0}},
  style='wind-assisted-climb:'..tostring(variant),
  route={{kind='dock',pad=p,crank=-math.deg(initial)},{kind='walk',x=ox+544+extra,y=80},{kind='walk',x=ox+width-48,y=80}}}
end
function WindDesign.lesson(c)
 c.tiles={};c.lookup={};c.mechanisms={};c.pads={};c.features={}
 local d=WindDesign.build(c,0,0,0);c.profile=d.profile;c.start={48,80};c.goal={848,80}
 c.checkpoint={544,80};c.checkpoints={c.checkpoint};c.layoutRevision=5;c.revisedLesson=true
 c.note={'Crank until GO: aim UP the ramp.','B releases. Use the tailwind to climb.'}
end
