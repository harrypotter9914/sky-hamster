"""Package native capture frames, preserving 5:3 pixels and capture timing."""
from pathlib import Path
import json
from PIL import Image

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
DATA=Path('C:/Users/12063/Documents/PlaydateSDK/Disk/Data/com.wangyibo.skyhamster.releasegif')
report=json.loads((DATA/'capture-report.json').read_text(encoding='utf-8'))
assert report.get('complete') and not report.get('error')
exports=[]
for kind,count in [('jump',90),('cannon',110),('turn',75)]:
    frames=[Image.open(DATA/'images'/f'{kind}-{n:03d}.gif').convert('RGB').resize((800,480),Image.Resampling.NEAREST) for n in range(1,count+1)]
    durations=[(40 if i%3==2 else 30) for i in range(count)]
    durations[-1]+=600
    path=HERE/f'gameplay-{kind}.gif'
    frames[0].save(path,save_all=True,append_images=frames[1:],duration=durations,loop=0,optimize=True,disposal=1)
    im=Image.open(path)
    assert im.n_frames>20 and im.size==(800,480)
    exports.append({'file':path.name,'frames':im.n_frames,'bytes':path.stat().st_size})
    frames[count//2].save(HERE/f'gameplay-{kind}-poster.png')
    strip=Image.new('RGB',(1200,480),'white')
    for j,n in enumerate([0,14,29,44,59,count-1]):
        raw=Image.open(DATA/'images'/f'{kind}-{n+1:03d}.gif').convert('RGB')
        strip.paste(raw,((j%3)*400,(j//3)*240))
    strip.save(HERE/f'gameplay-{kind}-review.png')
# The actual in-game steering UI animation is unchanged by the cloud update.
from shutil import copy2
copy2(ROOT/'experiments/tilt-adventure/tests/steering-v0.12.8.gif',HERE/'steering-modes.gif')
(HERE/'gameplay-capture.json').write_text(json.dumps({'capture':report,'exports':exports,'notes':'Production engine with scripted tilt/button/crank input, isolated save ID; not hardware or human playtesting. Lift departure used an incorrect exit direction and fell; not published as a success demonstration. Some native turn GIFs after frame 75 fail strict Pillow decoding; the published turn clip ends at frame 75 and includes only correctly decoded source frames.'},indent=2),encoding='utf-8')
print(json.dumps(exports))
