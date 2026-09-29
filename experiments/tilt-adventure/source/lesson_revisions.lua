-- Keep the first encounter readable; make later practice ask for a new decision.
LessonRevisions={}
function LessonRevisions.apply(byId)
 WindDesign.lesson(assert(byId['wind-dial']))
 local function revise(id)
  local c=assert(byId[id]);c.tiles={};c.lookup={};c.revisedLesson=true;c.layoutRevision=4;return c
 end
 local c=revise('legacy-1')
 c:rect(0,4,0,2);c:rect(5,9,1,2);c:rect(8,9,3,5)
 c:rect(10,13,4,5);c:rect(12,13,1,3);c:rect(14,17,0,2)
 c.goal={544,48};c.checkpoint={304,144};c.checkpoints={c.checkpoint}
 c.note={'Tilt gently to follow the road.','Level your grip before each wide turn.'}
 c=revise('legacy-4')
 c:rect(0,6,1,3);c:rect(7,11,1,2);c:rect(10,11,3,6)
 c:rect(12,14,5,6);c:rect(15,18,5,7)
 c.checkpoint={336,64};c.checkpoints={c.checkpoint}
 c.note={'The descent ends before the corner.','Brake on the flat, then turn.'}
 c=revise('dual-turn')
 c:rect(0,6,6,7);c:rect(9,10,10,13);c.goal={320,416}
 local deck=c.mechanisms[1];deck.ports[2].y=320;deck.ports[2].dy=1
 c.note={'Call the deck from shore before boarding.','This exit is south: turn after boarding.'}
 c=byId['switchback'];c.revisedLesson=true;c.layoutRevision=4
 c.profile={{0,144},{224,144},{448,80},{640,80}}
 c.note={'Turn on the level terraces.','The long straights change height.'}
 c=revise('legacy-16')
 c:rect(0,4,1,3);c:rect(9,18,1,3);c.goal={560,80}
 c.pads[1].initialAngle=.7
 c.note={'The barrel starts off target. Crank to aim.','A fires. Brake on the long landing terrace.'}
 for _,course in pairs(byId) do
  if course.revisedLesson then table.sort(course.tiles,function(a,b)return a.x+a.y<b.x+b.y end) end
 end
end
