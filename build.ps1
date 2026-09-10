param([switch]$Classroom)
$ErrorActionPreference='Stop'
$sdk=$env:PLAYDATE_SDK_PATH
if(-not $sdk){throw 'Set PLAYDATE_SDK_PATH to your installed SDK first.'}
$source=Join-Path $PSScriptRoot 'source'
$info=Get-Content (Join-Path $source 'pdxinfo') -Raw
$version=[regex]::Match($info,'(?m)^version=([^\r\n]+)').Groups[1].Value
if(-not $version){throw 'Missing version in source/pdxinfo'}
$output=Join-Path $PSScriptRoot "builds/sky-hamster-v$version.pdx"
if($Classroom){
 $staging=Join-Path $PSScriptRoot "builds/classroom-source-v$version"
 New-Item -ItemType Directory -Path $staging -Force | Out-Null
 Get-ChildItem -LiteralPath $source | Where-Object Name -ne 'audio' | Copy-Item -Destination $staging -Recurse -Force
 $config=(Get-Content (Join-Path $source 'build.lua') -Raw).Replace('classroom=false','classroom=true')
 Set-Content (Join-Path $staging 'build.lua') $config
 $info=Get-Content (Join-Path $staging 'pdxinfo') -Raw
 $info=$info.Replace('name=Sky Hamster Prototype','name=Sky Hamster Core Test').Replace('bundleID=com.playdateworkshop.skyhamster','bundleID=com.playdateworkshop.skyhamster.core').Replace("version=$version","version=$version-core")
 Set-Content (Join-Path $staging 'pdxinfo') $info -NoNewline
 $source=$staging
 $output=Join-Path $PSScriptRoot "builds/sky-hamster-core-v$version.pdx"
}
& (Join-Path $sdk 'bin/pdc.exe') $source $output
if($LASTEXITCODE -ne 0){throw 'Playdate build failed'}
Write-Output $output
