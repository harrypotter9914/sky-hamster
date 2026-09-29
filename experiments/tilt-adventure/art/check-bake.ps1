$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$manifest=Get-Content (Join-Path $PSScriptRoot 'runtime-bake.json') -Raw | ConvertFrom-Json
$sha=[Security.Cryptography.SHA256]::Create()
try {
 foreach($entry in $manifest.sourceHashes.PSObject.Properties){
  $path=Join-Path "$root/source" $entry.Name
  if($entry.Name.EndsWith('.lua')){
   $content=[IO.File]::ReadAllText($path).Replace("`r`n","`n")
   $bytes=[Text.Encoding]::UTF8.GetBytes($content)
  } else {$bytes=[IO.File]::ReadAllBytes($path)}
  $hash=[Convert]::ToHexString($sha.ComputeHash($bytes)).ToLowerInvariant()
  if($hash -ne $entry.Value){throw "Native road artwork is stale: $($entry.Name). Run art/bake-runtime.ps1 and art/collect-runtime.py before building."}
 }
} finally {$sha.Dispose()}
