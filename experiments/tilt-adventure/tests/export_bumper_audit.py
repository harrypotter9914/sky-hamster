from pathlib import Path
from PIL import Image,ImageChops
import json

root=Path(__file__).resolve().parent.parent
data=Path.home()/'Documents/PlaydateSDK/Disk/Data/com.wangyibo.skyhamster.ui-review'
p=data/'images'
report=json.loads((data/'bumper-review-v0.10.12.json').read_text())
assert report['complete'] and report['count']==54
for name in ('contact','clear','jump'):
    canvas=Image.new('RGB',(800,960),'white')
    for i in range(8):
        im=Image.open(p/f'ring12-{name}-{i}.gif').convert('RGB')
        canvas.paste(im,((i%2)*400,(i//2)*240))
    canvas.save(root/f'art/ring-{name}-v0.10.12.png')
frames=[Image.open(p/f'ring12-pulse-{i}.gif').convert('RGB') for i in range(13)]
boxes=[]
for im in frames:
    crop=im.crop((175,110,225,156)).convert('L')
    boxes.append(ImageChops.invert(crop).getbbox())
widths=[b[2]-b[0] for b in boxes]
assert widths[6]>widths[0] and widths[0]==widths[-1],widths
assert ImageChops.difference(frames[0],frames[-1]).getbbox() is None,'pulse failed to settle'
assert all(0<b[0] and b[2]<50 and 0<b[1] and b[3]<46 for b in boxes),'pulse clipping'
frames[0].save(root/'art/ring-pulse-v0.10.12.gif',save_all=True,append_images=frames[1:]+[frames[-1]]*12,duration=30,loop=0)
sheet=Image.new('RGB',(750,138),'white')
for j,i in enumerate((0,3,6,9,12)):
    crop=frames[i].crop((175,110,225,156)).resize((150,138),Image.Resampling.NEAREST)
    sheet.paste(crop,(j*150,0))
sheet.save(root/'art/ring-pulse-strip-v0.10.12.png')
report['pulseWidths']=widths
report['pulseSettlesExactly']=True
lessons=Image.new('RGB',(800,480),'white')
for i in range(4):
    lessons.paste(Image.open(p/f'ring12-lesson-{i+1}.gif').convert('RGB'),((i%2)*400,(i//2)*240))
lessons.save(root/'art/ring-lesson-v0.10.12.png')
(root/'tests/bumper-review-v0.10.12.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: 54 native frames; outward pulse widths '+str(widths)+'; no clipping and exact return')
