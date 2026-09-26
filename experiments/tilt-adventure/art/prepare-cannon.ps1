$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$src=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'cannon-barrel-original.png'))
$x0=$src.Width;$y0=$src.Height;$x1=0;$y1=0
for($y=0;$y -lt $src.Height;$y++){for($x=0;$x -lt $src.Width;$x++){if($src.GetPixel($x,$y).A -gt 127){$x0=[Math]::Min($x0,$x);$y0=[Math]::Min($y0,$y);$x1=[Math]::Max($x1,$x);$y1=[Math]::Max($y1,$y)}}}
foreach($item in @(@('cannon-barrel.png',72,46),@('cannon-title.png',44,29))){
$w=[int]$item[1];$h=[int]$item[2];$dst=[Drawing.Bitmap]::new($w,$h)
$gr=[Drawing.Graphics]::FromImage($dst);$gr.DrawImage($src,[Drawing.Rectangle]::new(0,0,$w,$h),[Drawing.Rectangle]::new($x0,$y0,$x1-$x0+1,$y1-$y0+1),[Drawing.GraphicsUnit]::Pixel);$gr.Dispose()
for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){$c=$dst.GetPixel($x,$y);if($c.A -lt 128){$dst.SetPixel($x,$y,[Drawing.Color]::Transparent)}else{$dst.SetPixel($x,$y,$(if(($c.R+$c.G+$c.B)/3 -gt 128){[Drawing.Color]::White}else{[Drawing.Color]::Black}))}}}
$dst.Save((Join-Path $root ('source/'+$item[0])));$dst.Dispose()
}
$src.Dispose()
