param([switch]$Classroom)
$ErrorActionPreference='Stop'
$sdk=$env:PLAYDATE_SDK_PATH
if(-not $sdk){throw 'Set PLAYDATE_SDK_PATH to your installed SDK first.'}
$source=Join-Path $PSScriptRoot 'source'
$output=Join-Path $PSScriptRoot 'builds/sky-hamster-v0.5.5.pdx'
if($Classroom){
 $staging=Join-Path $PSScriptRoot 'builds/classroom-source'
 New-Item -ItemType Directory -Path $staging -Force | Out-Null
 Copy-Item -Path "$source/*" -Destination $staging -Force
 Set-Content (Join-Path $staging 'build.lua') 'Build={classroom=true}'
 $info=Get-Content (Join-Path $staging 'pdxinfo') -Raw
 $info=$info.Replace('name=Sky Hamster Prototype','name=Sky Hamster Core Test').Replace('bundleID=com.playdateworkshop.skyhamster','bundleID=com.playdateworkshop.skyhamster.core').Replace('version=0.5.5','version=0.5.5-core')
 Set-Content (Join-Path $staging 'pdxinfo') $info -NoNewline
 $source=$staging
 $output=Join-Path $PSScriptRoot 'builds/sky-hamster-core-v0.5.5.pdx'
}
& (Join-Path $sdk 'bin/pdc.exe') $source $output
if($LASTEXITCODE -ne 0){throw 'Playdate build failed'}
Write-Output $output
