"""Ordered raster fast path, reordered fallback and stale-coordinate rejection."""
from pathlib import Path
from lupa.lua54 import LuaRuntime
lua=LuaRuntime()
lua.execute("""
Build={};Loading={checkpoint=function()end}
local data={{1,2,7,3,4},{5,6,9,10,11}}
playdate={geometry={},datastore={read=function() return data end},graphics={imagetable={new=function()return {getImage=function(_,i)return i end}end}}}
""")
lua.execute((Path(__file__).resolve().parents[1]/'source/road_assets.lua').read_text())
lua.execute("""
for _,tiles in ipairs({{{x=1,y=2},{x=5,y=6}},{{x=5,y=6},{x=1,y=2}}}) do
 local c={id='fixture',tiles=tiles};assert(RoadAssets.apply(c))
 for _,t in ipairs(tiles) do
  assert(t.surface.image==(t.x==1 and 7 or 9))
  assert(t.surface.x==(t.x==1 and 3 or 10))
  assert(t.surface.y==(t.x==1 and 4 or 11))
 end
end
assert(not pcall(RoadAssets.apply,{id='stale',tiles={{x=1,y=2},{x=7,y=8}}}))
print('PASS: ordered and reordered road assets match, stale coordinates fail')
""")
