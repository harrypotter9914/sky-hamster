"""Compare native exports with the captured 0.10.9 HUD baseline."""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
import json

root=Path(__file__).resolve().parents[3]
source=Path.home()/'Documents/PlaydateSDK/Disk/Data/com.wangyibo.skyhamster.ui-review/images'
before=root/'builds/hud-before'
art=root/'experiments/tilt-adventure/art'
files=sorted(source.glob('hud-*.gif'))
assert len(files)==55
for path in files:
    a=Image.open(before/path.name).convert('RGB')
    b=Image.open(path).convert('RGB')
    assert b.size==(400,240)
    assert ImageChops.difference(a.crop((0,43,400,240)),b.crop((0,43,400,240))).getbbox() is None,path.name
panel=Image.new('RGB',(800,22*49),'white')
for i in range(44):
    im=Image.open(source/f'hud-course-{i+1}.gif').convert('RGB')
    panel.paste(im.crop((0,0,400,43)),((i//22)*400,(i%22)*49))
panel.save(art/'hud-course-audit-v0.10.10.png')
for name in ['idle','rolling','recovering','large','dock-cannon']:
    Image.open(source/f'hud-{name}.gif').save(art/f'hud-{name}-v0.10.10.png')
comparison=Image.new('RGB',(800,240),'white')
comparison.paste(Image.open(before/'hud-rolling.gif'),(0,0))
comparison.paste(Image.open(source/'hud-rolling.gif'),(400,0))
comparison.save(art/'hud-before-after-v0.10.10.png')
report={'nativeExports':len(files),'unchangedWorldAndBottom':len(files),'size':[400,240],'topRows':[0,42]}
(Path(__file__).parent/'hud-review-v0.10.10.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: all 55 native snapshots preserve every pixel below y=43; 44 course headers exported')
