# Build true perspective pitch/yaw poses from the existing illustrated device.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies @("System.Drawing.Common","System.Drawing.Primitives","System.Private.Windows.GdiPlus","System.Private.Windows.Core") -TypeDefinition @"
using System;
using System.Drawing;
public static class TiltFrames {
 public static void Build(string src,string dest) {
  using(var im=new Bitmap(src)) {
   foreach(string dir in new[]{"right","left","up","down"}) for(int step=0;step<=6;step++) {
    double a=step*7*Math.PI/180;
    double yaw=dir=="right"?-a:dir=="left"?a:0;
    double pitch=dir=="down"?a:dir=="up"?-a:0;
    double xu=Math.Cos(yaw),xv=Math.Sin(yaw)*Math.Sin(pitch),yu=0,yv=Math.Cos(pitch);
    double zu=-Math.Sin(yaw),zv=Math.Cos(yaw)*Math.Sin(pitch),f=100;
    using(var o=new Bitmap(100,90)) {
     for(int y=0;y<90;y++) for(int x=0;x<100;x++) {
      double px=x-50,py=y-45,A=px*zu-f*xu,B=px*zv-f*xv,C=py*zu-f*yu,D=py*zv-f*yv,det=A*D-B*C;
      if(Math.Abs(det)<.0001)continue;
      double u=(-px*f*D+B*py*f)/det,v=(-A*py*f+px*f*C)/det;
      int sx=(int)Math.Floor(u+im.Width/2.0),sy=(int)Math.Floor(v+im.Height/2.0);
      if(sx>=0&&sx<im.Width&&sy>=0&&sy<im.Height)o.SetPixel(x,y,im.GetPixel(sx,sy));
     }
     o.Save(System.IO.Path.Combine(dest,dir+"-"+step+".png"));
    }
   }
  }
 }
}
"@
$source=Join-Path $PSScriptRoot '../source'
$out=Join-Path $source 'tutorial-turns'
New-Item -ItemType Directory -Force $out | Out-Null
[TiltFrames]::Build((Join-Path $source 'ui-device.png'),$out)

