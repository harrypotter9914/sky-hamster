"""Archive and strictly decode native tutorial screenshots, without altering game art."""
from pathlib import Path
from PIL import Image,ImageDraw
import json,sys,shutil

data=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(parents=True,exist_ok=True)
report=json.loads((data/'shortcut-review-report.json').read_text(encoding='utf-8-sig'))
assert report['complete'] and report['practiceAssertions'] and not report.get('error')
assert len(report['captures'])==17
shutil.copy2(data/'shortcut-review-report.json',out/'report.json')
for name in report['captures']:
    path=data/'images'/('shortcuts-'+name+'.gif')
    with Image.open(path) as image:
        image.load();assert image.size==(400,240)
        image.convert('RGB').save(out/(name+'.png'))
selected=['map-intro','help-intro','goal-intro','recenter-intro','jump-1.4','jump-4.4']
sheet=Image.new('RGB',(820,798),'#c0c0c0');draw=ImageDraw.Draw(sheet)
for i,name in enumerate(selected):
    x,y=10+(i%2)*410,18+(i//2)*260
    draw.text((x,y-14),name,fill='black');sheet.paste(Image.open(out/(name+'.png')),(x,y))
sheet.save(out/'contact-sheet.png')
print(f'PASS: {len(report["captures"])} native 400x240 frames decoded, device={report["device"]}.')
