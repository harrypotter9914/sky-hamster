"""Pack SDK-rendered frames without drawing or altering their pixels."""
from pathlib import Path
from PIL import Image
import os,json
sdk=Path(os.environ.get('PLAYDATE_SDK_PATH',Path.home()/'Documents/PlaydateSDK'))
data=sdk/'Disk/Data/com.wangyibo.skyhamster.rotor-art'
assert json.loads((data/'rotor-art-report.json').read_text())['complete']
out=Path(__file__).resolve().parents[1]/'source/structures'
for span in (160,192):
    frames=[Image.open(data/'images'/f'rotor-{span}-{i}.gif').convert('RGBA') for i in range(180)]
    w,h=frames[0].size
    assert all(im.size==(w,h) for im in frames)
    assert frames[0].getextrema()[3][0]==0,'SDK export lost transparent background'
    sheet=Image.new('RGBA',(w*10,h*18),(0,0,0,0))
    for i,im in enumerate(frames):sheet.paste(im,(i%10*w,i//10*h))
    path=out/f'rotor-{span}-table-{w}-{h}.png'
    sheet.save(path,optimize=True)
    print(path.name,180,'frames',path.stat().st_size,'bytes')
