from pathlib import Path
from PIL import Image,ImageDraw,ImageChops
import json
root=Path(__file__).resolve().parents[1]
data=Path.home()/'Documents/PlaydateSDK/Disk/Data/com.wangyibo.skyhamster.ui-review'
report=json.loads((data/'occlusion-review-v0.10.11.json').read_text())
assert report['complete'],report
src=data/'images'
out=root/'art'
for kind in list(report['kinds'])+['cannon','old-spring','jump-spring','station-extend','station-switch']:
    atlas=Image.new('RGB',(8*150,3*150),'white');d=ImageDraw.Draw(atlas)
    for phase in range(1,4):
        for i in range(8):
            im=Image.open(src/f'occ-{kind}-{phase}-{i}.gif').convert('RGB')
            x,y=i*150,(phase-1)*150
            atlas.paste(im.crop((125,55,275,190)),(x,y+15));d.text((x+4,y+2),f'{kind} {phase}/{i}',fill='black')
    atlas.save(out/f'occlusion-{kind}-v0.10.11.png')
changes=[]
for phase in range(1,4):
    for i in range(8):
        a=Image.open(src/f'occ-old-spring-{phase}-{i}.gif').convert('RGB')
        b=Image.open(src/f'occ-bumper-{phase}-{i}.gif').convert('RGB')
        changed=sum(p!=(0,0,0) for p in ImageChops.difference(a,b).get_flattened_data())
        if i in (0,1,2,3,7): assert changed==0,'front/side ball was altered'
        if i==5: assert changed>0,'rear ball still covers spring'
        changes.append({'phase':phase,'angle':i,'changed':changed})
report['springComparisons']=changes
comparison=Image.new('RGB',(840,315),'white')
for i,name in enumerate(['old-spring','bumper']):
    frame=Image.open(src/f'occ-{name}-1-5.gif').convert('RGB').crop((130,70,270,175))
    comparison.paste(frame.resize((420,315),Image.Resampling.NEAREST),(i*420,0))
comparison.save(out/'spring-before-after-v0.10.11.png')
(root/'tests/occlusion-review-v0.10.11.json').write_text(json.dumps(report,indent=2)+'\n')
print(changes)
