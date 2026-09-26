Guide={seen={},queue={},index=1,time=0}
local G=Guide
function G.enter(course,manual)
 G.manual=manual==true
 G.queue={};G.index=1;G.time=0
 local added={}
 local function add(key) if (G.manual or not G.seen[key]) and not added[key] then G.queue[#G.queue+1]=key;added[key]=true end end
 if not G.manual then add('arrival') end;add('roll')
 if course.jump then add('jump') end
 for _,m in ipairs(course.mechanisms or {}) do add(m.manual and 'control' or m.kind) end
 for _,p in ipairs(course.pads or {}) do add(p.kind=='bridge' and 'control' or p.kind) end
 return #G.queue>0
end
function G.key() return G.queue[G.index] end
function G.advance()
 local key=G.key();if key and not G.manual then G.seen[key]=true end
 G.index=G.index+1;G.time=0
 return G.key()~=nil
end
function G.replay() G.time=0 end
