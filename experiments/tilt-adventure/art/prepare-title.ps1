# Deterministic export only: artwork is authored separately in title-v3-original.png.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$src=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'title-v3-original.png'))
$dst=[Drawing.Bitmap]::new(400,240)
$gr=[Drawing.Graphics]::FromImage($dst);$gr.DrawImage($src,0,0,400,240);$gr.Dispose()
for($y=0;$y -lt 240;$y++){for($x=0;$x -lt 400;$x++){$c=$dst.GetPixel($x,$y);$dst.SetPixel($x,$y,$(if(($c.R+$c.G+$c.B)/3 -gt 128){[Drawing.Color]::White}else{[Drawing.Color]::Black}))}}
$dst.Save((Join-Path $root 'source/title-scene.png'))
# Launcher artwork is exported separately by prepare-launcher.ps1.
$dst.Dispose();$src.Dispose()
