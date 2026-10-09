-- Player progress and temporary workshop access are deliberately separate.
CampaignAccess={developer=false,frontier=1}
local C=CampaignAccess
function C.init(saved,count)
 C.count=count;C.developer=false;C.hold=0;C.latched=false
 local n=saved.progressRevision==1 and saved.unlockedThrough or saved.level
 C.frontier=math.max(1,math.min(count,math.floor(tonumber(n) or 1)))
end
function C.allowed(n,completed)
 return C.developer or n<=C.frontier or completed[n]==true or (n>1 and completed[n-1]==true)
end
function C.clear(n)
 if not C.developer then C.frontier=math.max(C.frontier,math.min(C.count,n+1)) end
end
function C.reset() C.frontier=1;C.developer=false;C.hold=0;C.latched=false end
function C.secret(dt,held)
 if not held then C.hold=0;C.latched=false;return false end
 C.hold=C.hold+dt
 if C.hold>=2.5 and not C.latched then C.latched=true;return true end
 return false
end
