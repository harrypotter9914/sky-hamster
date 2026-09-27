-- Profiles are static after campaign/joinery construction. Find the same first
-- upper endpoint as the original linear walk, including duplicate-x steps.
HeightIndex={reference={}}
for _,course in ipairs(Courses) do
 HeightIndex.reference[course]=course.height
 local profile=course.profile
 local segments={}
 for i=1,#profile-1 do
  local a,b=profile[i],profile[i+1]
  segments[i]={x=a[1],z=a[2],finish=b[1],slope=(b[2]-a[2])/(b[1]-a[1])}
 end
 local count=#segments
 local last=1
 function course:height(x,y)
  local bounds=self.upperLipBounds
  if bounds and x>=bounds[1] and x<bounds[2] and y>=bounds[3] and y<bounds[4] then
   for _,lip in ipairs(self.upperLips) do
    if x>=lip[1] and x<lip[2] and y>=lip[3] and y<lip[4] then return lip[5],0,0 end
   end
  end
  if x>=profile[#profile][1] then return profile[#profile][2],0,0 end
  local segment=segments[last]
  if not segment or x>=segment.finish or (last>1 and x<segments[last-1].finish) then
   local lo,hi=1,count
   while lo<hi do
    local mid=(lo+hi)//2
    if x<segments[mid].finish then hi=mid else lo=mid+1 end
   end
   last=lo;segment=segments[lo]
  end
  if not segment then return profile[#profile][2],0,0 end
  return segment.z+math.max(0,x-segment.x)*segment.slope,segment.slope,0
 end
end
