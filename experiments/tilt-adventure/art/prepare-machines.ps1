$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
foreach($item in @(@('machine-lift',116,86),@('machine-slider',144,96),@('machine-fan',52,52),@('machine-bumper',44,44))){
$name=$item[0];$master=if($name -eq 'ui-mascot-small'){'ui-mascot'}else{$name}
$src=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot "$master-original.png"))
$x0=$src.Width;$y0=$src.Height;$x1=0;$y1=0
for($y=0;$y -lt $src.Height;$y++){for($x=0;$x -lt $src.Width;$x++){if($src.GetPixel($x,$y).A -gt 127){$x0=[Math]::Min($x0,$x);$y0=[Math]::Min($y0,$y);$x1=[Math]::Max($x1,$x);$y1=[Math]::Max($y1,$y)}}}
$w=[int]$item[1];$h=[int]$item[2];$dst=[Drawing.Bitmap]::new($w,$h)
$scale=[Math]::Min(($w-2)/($x1-$x0+1),($h-2)/($y1-$y0+1));$dw=[int](($x1-$x0+1)*$scale);$dh=[int](($y1-$y0+1)*$scale)
$gr=[Drawing.Graphics]::FromImage($dst)
$gr.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gr.DrawImage($src,[Drawing.Rectangle]::new([int](($w-$dw)/2),[int](($h-$dh)/2),$dw,$dh),[Drawing.Rectangle]::new($x0,$y0,$x1-$x0+1,$y1-$y0+1),[Drawing.GraphicsUnit]::Pixel);$gr.Dispose()
for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){$c=$dst.GetPixel($x,$y);if($c.A -lt 128){$dst.SetPixel($x,$y,[Drawing.Color]::Transparent)}else{$dst.SetPixel($x,$y,$(if(($c.R+$c.G+$c.B)/3 -gt 145){[Drawing.Color]::White}else{[Drawing.Color]::Black}))}}}
$dst.Save((Join-Path $root ('source/'+$name+'.png')));$dst.Dispose();$src.Dispose()
}
