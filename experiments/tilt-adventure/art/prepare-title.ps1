# Deterministic export only: artwork is authored separately in title-v3-original.png.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$src=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'title-v3-original.png'))
$dst=[Drawing.Bitmap]::new(400,240)
$gr=[Drawing.Graphics]::FromImage($dst);$gr.DrawImage($src,0,0,400,240);$gr.Dispose()
for($y=0;$y -lt 240;$y++){for($x=0;$x -lt 400;$x++){$c=$dst.GetPixel($x,$y);$dst.SetPixel($x,$y,$(if(($c.R+$c.G+$c.B)/3 -gt 128){[Drawing.Color]::White}else{[Drawing.Color]::Black}))}}
$dst.Save((Join-Path $root 'source/title-scene.png'))
$dst.Save((Join-Path $root 'source/launcher/launchImage.png'))
$card=[Drawing.Bitmap]::new(350,155);$gr=[Drawing.Graphics]::FromImage($card);$gr.Clear([Drawing.Color]::Black)
$gr.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$gr.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
$gr.DrawImage($dst,46,0,258,155);$gr.Dispose()
$card.Save((Join-Path $root 'source/launcher/card.png'))
1..3 | ForEach-Object { $card.Save((Join-Path $root "source/launcher/card-highlighted/$_.png")) }
$card.Dispose();$dst.Dispose();$src.Dispose()
