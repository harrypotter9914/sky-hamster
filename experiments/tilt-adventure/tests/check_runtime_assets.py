"""Verify native bake provenance and exact map-to-sprite assignments."""
from pathlib import Path
import hashlib, json
from PIL import Image

root=Path(__file__).resolve().parents[1]
report=json.loads((root/'art/runtime-bake.json').read_text())
for name, digest in report['sourceHashes'].items():
    p=root/'source'/name
    content=p.read_text(encoding='utf-8').encode() if p.suffix=='.lua' else p.read_bytes()
    assert hashlib.sha256(content).hexdigest()==digest, f'Stale native rasters: {name}; rerun art/bake-runtime.ps1 and art/collect-runtime.py'
fixture=Path(__file__).with_name('check_tilt.py')
source=fixture.read_text(encoding='utf-8')
scope={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0]+"load('engine')",str(fixture),'exec'),scope)
lua=scope['lua'];lua.execute('for _,c in ipairs(Courses) do Curriculum.ensure(c) end')
count=0
for _,c in lua.globals().Courses.items():
    if not hasattr(c,'items') or not c['id']:continue
    rows=json.loads((root/f"source/road-cache/{c['id']}.json").read_text())
    expected={(t['x'],t['y']) for _,t in c['tiles'].items()}
    assert {(r[0],r[1]) for r in rows}==expected
    assert len(rows)==len(expected)
    for x,y,frame,sx,sy in rows:
        assert 1<=frame<=report['roadSprites'] and sx==int(sx) and sy==int(sy)
    count+=1
assert count==report['courses']==53
for kind,path,n in [('roads','road-cache/surfaces',report['roadSprites']),('cannon','structures/cannon',62),('fan','structures/fan-housings',72)]:
    for i in range(1,n+1):
        with Image.open(root/f'source/{path}-table-{i}.png') as im:
            assert im.mode=='RGBA' and im.width>0 and im.height>0
print(f'PASS: native bake source hashes, 53 road footprints, {report["roadSprites"]} surfaces and 134 cannon/fan frames')
