# Export dedicated artwork to the SDK's fixed launcher sizes.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$launcher=Join-Path $root 'source/launcher'
function Export-Monochrome([string]$inputPath,[int]$width,[int]$height,[string]$outputPath) {
 $original=[Drawing.Bitmap]::new($inputPath)
 $bitmap=[Drawing.Bitmap]::new($width,$height)
 $graphics=[Drawing.Graphics]::FromImage($bitmap)
 try {
  $graphics.Clear([Drawing.Color]::Black)
  $graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.DrawImage($original,0,0,$width,$height)
 } finally {$graphics.Dispose();$original.Dispose()}
 try {
  for($y=0;$y -lt $height;$y++){for($x=0;$x -lt $width;$x++){
   $c=$bitmap.GetPixel($x,$y)
   $color=if(($c.R+$c.G+$c.B)/3 -gt 128){[Drawing.Color]::White}else{[Drawing.Color]::Black}
   $bitmap.SetPixel($x,$y,$color)
  }}
  $bitmap.Save($outputPath,[Drawing.Imaging.ImageFormat]::Png)
 } finally {$bitmap.Dispose()}
}
Export-Monochrome (Join-Path $PSScriptRoot 'launcher-cover-original.png') 350 155 (Join-Path $launcher 'card.png')
Export-Monochrome (Join-Path $PSScriptRoot 'launcher-icon-original.png') 32 32 (Join-Path $launcher 'icon.png')
# The selected card uses the same dedicated cover, never the old empty menu boards.
1..3 | ForEach-Object {Copy-Item -LiteralPath (Join-Path $launcher 'card.png') -Destination (Join-Path $launcher "card-highlighted/$_.png") -Force}
$splash=[Drawing.Bitmap]::new(400,240)
$graphics=[Drawing.Graphics]::FromImage($splash)
$card=[Drawing.Bitmap]::new((Join-Path $launcher 'card.png'))
try {
 $graphics.Clear([Drawing.Color]::Black)
 # Center at native resolution: preserve all the cover's crisp pixels.
 $graphics.DrawImageUnscaled($card,25,43)
 $splash.Save((Join-Path $launcher 'launchImage.png'),[Drawing.Imaging.ImageFormat]::Png)
} finally {$card.Dispose();$graphics.Dispose();$splash.Dispose()}
Write-Output 'Exported launcher card 350x155, icon 32x32 and loading image 400x240.'
