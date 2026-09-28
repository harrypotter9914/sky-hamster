-- Append stable course identities so existing completion/save data stays intact.
local function course(id,name,start,goal)
 local c=Courses.create(name,'',{{0,0},{7000,0}},start,goal)
 c.id=id;c.shortName=name;c.jump=false;c.mechanisms={};c.pads={};c.checkpoints={}
 return c
end
local function tableAt(c,x,y,down,dual)
 local m={kind='rotor',manual=true,lesson='onboard',x=x,y=y,w=192,h=64,maxWidth=192,turnSquare=192,angle=dual and math.pi/2 or 0}
 m.ports={{x=x-96,y=y,dx=-1,dy=0,name='ENTRY'},{x=x,y=y+(down and 96 or -96),dx=0,dy=down and 1 or -1,name='EXIT'}}
 c.mechanisms[#c.mechanisms+1]=m
 local angle=m.angle
 if dual then c.pads[#c.pads+1]={kind='bridge',x=x-144,y=y,target=m,initialAngle=angle,desiredPort=1} end
 c.pads[#c.pads+1]={kind='bridge',lesson='onboard',onboard=true,x=x,y=y,target=m,initialAngle=angle,desiredPort=2}
 return m
end
local c=course('onboard-turn','Turn with the road',{48,224},{320,48})
c:rect(0,6,6,7);c:rect(9,10,0,3);tableAt(c,320,224,false,false)
c.note={'Board first. Dock at the deck centre.','Crank to GO at the exit; B releases.'}
c=course('onboard-relay','Two turning rooms',{48,352},{512,416})
c:rect(0,6,10,11);c:rect(9,10,4,7);c:rect(11,12,4,5);c:rect(15,16,8,13)
tableAt(c,320,352,false,false);tableAt(c,512,160,true,false)
c.checkpoints={{336,176}};c.checkpoint=c.checkpoints[1]
c.note={'Ride one turn north, then another south.','Watch each exit marker before releasing.'}
c=course('dual-turn','Call and ride',{48,224},{320,48})
c:rect(0,6,6,7);c:rect(9,10,0,3);tableAt(c,320,224,false,true)
c.note={'The shore dial calls the deck to you.','Board, then use its dial to reach the exit.'}
c=course('onboard-expedition','Sky interchange',{48,352},{1440,160})
c.jump=true
c:rect(0,6,10,11);c:rect(9,10,4,7);c:rect(11,18,4,5)
c:rect(21,22,8,13);c:rect(23,26,12,13);c:rect(36,41,11,14);c:rect(44,45,4,9)
tableAt(c,320,352,false,false);tableAt(c,704,160,true,false);tableAt(c,1440,416,false,true)
local ferry={kind='ferry',manual=true,lesson='slider',x=904,y=416,toX=1112,toY=416,w=80,h=80,progress=0}
c.mechanisms[#c.mechanisms+1]=ferry;c.pads[#c.pads+1]={kind='slider',x=904,y=416,target=ferry}
c.mechanisms[#c.mechanisms+1]={kind='fan',x=800,y=352,w=40,h=40,angle=math.pi/2,initialAngle=math.pi/2,force=55,region={800,416,96,64}}
c.mechanisms[#c.mechanisms+1]={kind='bumper',x=496,y=160,w=28,h=28,radius=14,sideHeight=10}
c.checkpoints={{400,160},{704,400},{1248,416}};c.checkpoint=c.checkpoints[1]
c.note={'Three turns, a ferry and a crosswind.','Call the last deck, board, then turn north.'}
for i=45,#Courses do local r=Courses[i]
 r.name=string.format('%02d / %s',i,string.upper(r.shortName));Courses.indexById[r.id]=i
 table.sort(r.tiles,function(a,b)return a.x+a.y<b.x+b.y end)
end
