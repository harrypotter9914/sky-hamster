"""Strictly decode SDK-exported native tutorial frames and prepare QA sheets."""
from pathlib import Path
import json, sys
from PIL import Image, ImageDraw

source=Path(sys.argv[1])
destination=Path(sys.argv[2]);destination.mkdir(parents=True,exist_ok=True)
paths=sorted(source.glob('native-functional-guide-*.gif'))
assert len(paths)==84, f'Expected 84 native tutorial frames, found {len(paths)}'
decoded=[];bad=[]
for p in paths:
    try:
        with Image.open(p) as im:
            im.load();assert im.size==(400,240)
            decoded.append((p,im.convert('RGB')))
    except Exception as e:
        bad.append({'file':p.name,'error':str(e)})
report={'expected':84,'decoded':len(decoded),'invalid':bad,'complete':not bad}
(destination/'tutorial-decode-report.json').write_text(json.dumps(report,indent=2)+'\n')
assert not bad,bad
for start in range(0,len(decoded),12):
    subset=decoded[start:start+12]
    sheet=Image.new('RGB',(1600,3*262),'#ddd');draw=ImageDraw.Draw(sheet)
    for i,(p,im) in enumerate(subset):
        x=(i%4)*400;y=(i//4)*262
        sheet.paste(im,(x,y+22));draw.text((x+4,y+3),p.stem.removeprefix('native-functional-guide-'),fill='black')
    sheet.save(destination/f'tutorial-sheet-{start//12+1}.png')
print(f'PASS: {len(decoded)} native 400x240 tutorial frames decoded without truncation')
