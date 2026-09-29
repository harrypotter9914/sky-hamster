# Export the existing native rasterizer; no artistic changes or approximate redraw.
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$repo=[IO.Path]::GetFullPath((Join-Path $root '../..'))
$qa=Join-Path $repo 'builds/tilt-bake-source'
New-Item -ItemType Directory -Force $qa | Out-Null
Copy-Item "$root/source/*" $qa -Recurse -Force
$bakeHashes=@{}
$bakeSha=[Security.Cryptography.SHA256]::Create()
try {
 foreach($inputFile in Get-ChildItem "$root/source" -Filter '*.lua'){
  $bytes=[Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText($inputFile.FullName).Replace("`r`n","`n"))
  $bakeHashes[$inputFile.Name]=[Convert]::ToHexString($bakeSha.ComputeHash($bytes)).ToLowerInvariant()
 }
} finally {$bakeSha.Dispose()}
$bakeHashes | ConvertTo-Json | Set-Content "$qa/bake-source-hashes.json" -Encoding utf8
Copy-Item "$root/source/engine.lua" "$qa/game.lua"
'Build.baking=true' | Add-Content "$qa/build.lua"
@'
function BakeRoad(c)
 course=c
 warmTileSprites()
end
'@ | Add-Content "$qa/game.lua"
@'
function BakeFanFrames() return fanHousings end
'@ | Add-Content "$qa/machine_art.lua"
Copy-Item "$PSScriptRoot/bake-runtime.lua" "$qa/main.lua"
"name=Sky asset bake`nbundleID=com.wangyibo.skyhamster.bake`nversion=1" | Set-Content "$qa/pdxinfo"
$sdk=if($env:PLAYDATE_SDK_PATH){$env:PLAYDATE_SDK_PATH}else{'C:/Users/12063/Documents/PlaydateSDK'}
& "$sdk/bin/pdc.exe" -sdkpath $sdk $qa "$repo/builds/tilt-bake.pdx"
if($LASTEXITCODE -ne 0){throw 'Bake build failed'}
Start-Process -FilePath "$sdk/bin/PlaydateSimulator.exe" -ArgumentList "$repo/builds/tilt-bake.pdx" -WindowStyle Hidden
