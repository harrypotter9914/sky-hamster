Classroom={}
function Classroom.apply()
 local original=Courses[1]
 local flat={name='01 / CORE CONTROL',shortName='Core control',hint='Reach FINISH. Learn when to release POWER.',
  profile={{0,0},{640,0}},start={48,80},goal={272,176},tiles={},lookup={},jump=false,
  add=original.add,rect=original.rect,height=original.height}
 flat:rect(0,4,1,3);flat:rect(4,6,2,5);flat:rect(6,9,4,6)
 table.sort(flat.tiles,function(a,b) return a.x+a.y<b.x+b.y end)
 local slope=Courses[2];slope.name='02 / OPTIONAL SLOPE';slope.shortName='Gravity test';slope.jump=false
 Courses={flat,slope}
end
