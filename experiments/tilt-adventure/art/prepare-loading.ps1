# Pack generated artwork into native 1-bit textures. No drawing is synthesized here.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$out=Join-Path (Split-Path $PSScriptRoot -Parent) 'source/loading'
New-Item -ItemType Directory -Force -Path $out | Out-Null
function Export-Asset($original,$rect,[int]$w,[int]$h,[string]$path){
 $bmp=[Drawing.Bitmap]::new($w,$h)
 $g=[Drawing.Graphics]::FromImage($bmp)
 try{
  $g.Clear([Drawing.Color]::Black)
  $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($original,[Drawing.Rectangle]::new(0,0,$w,$h),$rect,[Drawing.GraphicsUnit]::Pixel)
 }finally{$g.Dispose()}
 try{
  for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){
   $c=$bmp.GetPixel($x,$y)
   $v=if(($c.R+$c.G+$c.B)/3 -gt 120){[Drawing.Color]::White}else{[Drawing.Color]::Black}
   $bmp.SetPixel($x,$y,$v)
  }}
  $bmp.Save($path,[Drawing.Imaging.ImageFormat]::Png)
 }finally{$bmp.Dispose()}
}
$sky=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'loading-sky-original.png'))
try{Export-Asset $sky ([Drawing.Rectangle]::new(0,0,$sky.Width,$sky.Height)) 400 240 (Join-Path $out 'sky.png')}finally{$sky.Dispose()}
$sheet=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'loading-run-original.png'))
try{
 for($i=0;$i -lt 8;$i++){
  $x=[int](($i%4)*$sheet.Width/4);$y=[int]([math]::Floor($i/4)*$sheet.Height/2)
  Export-Asset $sheet ([Drawing.Rectangle]::new($x,$y,[int]($sheet.Width/4),[int]($sheet.Height/2))) 128 128 (Join-Path $out ('run-'+($i+1)+'.png'))
 }
}finally{$sheet.Dispose()}
Write-Output 'Packed generated sky and eight 128px animation frames.'
