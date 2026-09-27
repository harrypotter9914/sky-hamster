$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$out=Join-Path (Split-Path $PSScriptRoot -Parent) 'source/structures'
New-Item -ItemType Directory -Path $out -Force | Out-Null
function Export-Part($src,$rect,[int]$w,[int]$h,[string]$name,[bool]$trim){
 if($trim){
  $x0=$rect.Right;$y0=$rect.Bottom;$x1=$rect.X;$y1=$rect.Y
  for($y=$rect.Y;$y -lt $rect.Bottom;$y++){for($x=$rect.X;$x -lt $rect.Right;$x++){
   if($src.GetPixel($x,$y).A -gt 127){$x0=[math]::Min($x0,$x);$x1=[math]::Max($x1,$x);$y0=[math]::Min($y0,$y);$y1=[math]::Max($y1,$y)}
  }}
  $rect=[Drawing.Rectangle]::new($x0,$y0,$x1-$x0+1,$y1-$y0+1)
 }
 $dst=[Drawing.Bitmap]::new($w,$h);$g=[Drawing.Graphics]::FromImage($dst)
 $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 $g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::HighQuality
 $dw=$w;$dh=$h
 if($trim){$scale=[math]::Min(($w-2)/$rect.Width,($h-2)/$rect.Height);$dw=[int]($rect.Width*$scale);$dh=[int]($rect.Height*$scale)}
 $g.DrawImage($src,[Drawing.Rectangle]::new([int](($w-$dw)/2),[int](($h-$dh)/2),$dw,$dh),$rect,[Drawing.GraphicsUnit]::Pixel);$g.Dispose()
 for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){
  $c=$dst.GetPixel($x,$y)
  $v=if($c.A -lt 128){[Drawing.Color]::Transparent}elseif(($c.R+$c.G+$c.B)/3 -gt 128){[Drawing.Color]::White}else{[Drawing.Color]::Black}
  $dst.SetPixel($x,$y,$v)
 }}
 $dst.Save((Join-Path $out "$name.png"),[Drawing.Imaging.ImageFormat]::Png);$dst.Dispose()
}
$atlas=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'mechanical-surfaces-original.png'))
$names=@('deck','beam','hatch','gate','belt','bearing','socket','rail')
for($i=0;$i -lt 8;$i++){
 $rect=[Drawing.Rectangle]::new([int](($i%4)*$atlas.Width/4),[int]([math]::Floor($i/4)*$atlas.Height/2),[int]($atlas.Width/4),[int]($atlas.Height/2))
 Export-Part $atlas $rect 64 64 $names[$i] $false
}
$atlas.Dispose()
$atlas=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'mechanical-structures-original.png'))
$spec=@(@('pillar',48,72),@('bogie',60,36),@('cradle',70,58),@('gearbox',28,30))
for($i=0;$i -lt 4;$i++){
 $rect=[Drawing.Rectangle]::new([int](($i%2)*$atlas.Width/2),[int]([math]::Floor($i/2)*$atlas.Height/2),[int]($atlas.Width/2),[int]($atlas.Height/2))
 Export-Part $atlas $rect $spec[$i][1] $spec[$i][2] $spec[$i][0] $true
}
$atlas.Dispose()
$barrel=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'cannon-v2-original.png'))
Export-Part $barrel ([Drawing.Rectangle]::new(0,0,$barrel.Width,$barrel.Height)) 76 34 'barrel' $true
$barrel.Dispose()
Write-Output 'Packed eight generated materials and five structural sprites.'
