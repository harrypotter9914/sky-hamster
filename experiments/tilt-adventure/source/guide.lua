Guide={seen={},queue={},index=1,time=0}
local G=Guide
G.tools={map='up',help='left',goal='right',recenter='down'}
function G.enter(course,manual)
 G.manual=manual==true
 G.queue={};G.index=1;G.time=0;G.done={};G.trying=nil;G.tryState=nil
 local added={}
 local function add(key) if (G.manual or not G.seen[key]) and not added[key] then G.queue[#G.queue+1]=key;added[key]=true end end
 if not G.manual then add('arrival') end;add('roll')
 for _,key in ipairs({'map','help','goal','recenter'}) do add(key) end
 if course.jump then add('jump') end
 for _,m in ipairs(course.mechanisms or {}) do add(m.lesson or (m.manual and 'control' or m.kind)) end
 for _,p in ipairs(course.pads or {}) do add(p.lesson or (p.kind=='bridge' and 'control' or p.kind=='fan' and 'windcontrol' or p.kind)) end
 return #G.queue>0
end
function G.key() return G.queue[G.index] end
function G.advance()
 local key=G.key();if key and not G.manual then G.seen[key]=true end
 G.index=G.index+1;G.time=0
 return G.key()~=nil
end
function G.replay() G.time=0 end
-- Practice opens the real page without losing this first-run lesson queue.
-- Help temporarily owns the queue; returning restores its exact prior place.
function G.startTry(key,course)
 if G.trying or not G.tools[key] then return false end
 local saved={queue=G.queue,index=G.index,time=G.time,manual=G.manual,done=G.done}
 if key=='help' then G.enter(course,true) end
 G.tryState=saved;G.trying=key
 return true
end
function G.finishTry(cancel)
 if not G.tryState then return false end
 local key,saved=G.trying,G.tryState
 G.queue=saved.queue;G.index=saved.index;G.time=saved.time;G.manual=saved.manual;G.done=saved.done
 if not cancel then G.done[key]=true end
 G.trying=nil;G.tryState=nil
 return true
end
