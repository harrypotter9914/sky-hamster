from pathlib import Path
from PIL import Image,ImageChops
import json
root=Path(__file__).resolve().parents[3]
before=root/'builds/occlusion-before-cache'
after=Path.home()/'Documents/PlaydateSDK/Disk/Data/com.wangyibo.skyhamster.ui-review/images'
changed=[];files=list(before.glob('occ-*.gif'))
assert len(files)==408
for p in files:
    a=Image.open(p).convert('RGB');b=Image.open(after/p.name).convert('RGB')
    if ImageChops.difference(a,b).getbbox():changed.append(p.name)
report={'compared':len(files),'changed':changed}
(Path(__file__).parent/'occlusion-cache-v0.10.11.json').write_text(json.dumps(report,indent=2)+'\n')
assert not changed,changed
print('PASS: all 408 cached native frames exactly match the uncached occlusion result')
