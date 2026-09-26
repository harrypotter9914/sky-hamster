$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$src=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'paving-original.png'))
$atlas=[Drawing.Bitmap]::new(128,128)
$gr=[Drawing.Graphics]::FromImage($atlas)
$gr.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gr.DrawImage($src,0,0,128,128);$gr.Dispose();$src.Dispose()
for($y=0;$y -lt 128;$y++){for($x=0;$x -lt 128;$x++){$c=$atlas.GetPixel($x,$y);$atlas.SetPixel($x,$y,$(if($c.R -gt 190){[Drawing.Color]::White}else{[Drawing.Color]::Black}))}}
$out=Join-Path $root 'source/paving'
New-Item -ItemType Directory -Force $out | Out-Null
for($row=0;$row -lt 4;$row++){for($col=0;$col -lt 4;$col++){$tile=$atlas.Clone([Drawing.Rectangle]::new($col*32,$row*32,32,32),$atlas.PixelFormat);$tile.Save((Join-Path $out ((4*$row+$col).ToString()+'.png')));$tile.Dispose()}}
$atlas.Dispose()
