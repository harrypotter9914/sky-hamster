# Render one-degree deck views through the SDK, then pack them into image tables.
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=Resolve-Path (Join-Path $root '../..')
$qa=Join-Path $repo 'builds/rotor-art-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
$code=Get-Content "$qa/structures.lua" -Raw
$code=$code.Replace('Structures={}','Structures={exporting=true}')
Set-Content "$qa/structures.lua" $code
@'
function Structures.exportRotors()
 for _,span in ipairs({160,192,193}) do
  local m={kind='rotor',manual=true,joinSpan=span,maxWidth=span,x=0,y=0,w=span,h=64,angle=0}
  local name='rotor-'..span
  if span==193 then m.joinSpan=nil;m.turnSquare=192;m.maxWidth=192;m.w=192;name='turn-192' end
  for i=0,179 do
   m.angle=math.rad(i);m.w=Joinery.width(m,m.angle)
   deck(m,0,0,0,m.angle,tex.deck,0,false,12)
   playdate.datastore.writeImage(m.structureCache.image,name..'-'..i..'.gif')
  end
 end
 playdate.datastore.write({complete=true,frames=540},'rotor-art-report')
end
'@ | Add-Content "$qa/structures.lua"
@'
import 'game'
local done=false
function playdate.update()
 if not done then Structures.exportRotors();done=true;print('ROTOR ART: 540 frames exported') end
 playdate.graphics.clear(playdate.graphics.kColorWhite)
 playdate.graphics.drawText('Rotor art export complete.',25,100)
end
'@ | Set-Content "$qa/main.lua"
"name=Rotor Art Export`nbundleID=com.wangyibo.skyhamster.rotor-art`nversion=0.11.0" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa (Join-Path $repo 'builds/rotor-art.pdx')
if($LASTEXITCODE -ne 0){throw 'Rotor art build failed'}
