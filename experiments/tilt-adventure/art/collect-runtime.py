"""Package lossless native exports, deduplicating identical road surfaces."""
from pathlib import Path
import hashlib, json, os
from PIL import Image

root = Path(__file__).resolve().parent.parent
sdk = Path(os.environ.get('PLAYDATE_SDK_PATH', 'C:/Users/12063/Documents/PlaydateSDK'))
data = sdk / 'Disk/Data/com.wangyibo.skyhamster.bake'
report = json.loads((data / 'bake-report.json').read_text())
assert report['complete'], report
copied = root.parents[1] / 'builds/tilt-bake-source/bake-source-hashes.json'
snapshot = json.loads(copied.read_text(encoding='utf-8-sig'))
for name, digest in snapshot.items():
    current=hashlib.sha256((root/'source'/name).read_text(encoding='utf-8').encode()).hexdigest()
    assert current==digest, f'Source changed during native export: {name}; rerun bake-runtime.ps1'
out = root / 'source/road-cache'
out.mkdir(exist_ok=True)
seen, remap = {}, {}
for n in range(1, report['surfaces'] + 1):
    im = Image.open(data / f'images/bake-surface-{n}.gif').convert('RGBA')
    key = (im.size, hashlib.sha256(im.tobytes()).hexdigest())
    if key not in seen:
        index = len(seen) + 1
        seen[key] = index
        im.save(out / f'surfaces-table-{index}.png')
    remap[n] = seen[key]
for name in report['courses']:
    rows = json.loads((data / f'road-{name}.json').read_text())
    rows = [[r[0],r[1],remap[r[3]],r[4],r[5]] for r in rows]
    (out / f'{name}.json').write_text(json.dumps(rows, separators=(',', ':')) + '\n')
for kind, target, count in [('cannon', 'cannon', 62), ('fan', 'fan-housings', 72)]:
    for n in range(1, count + 1):
        Image.open(data / f'images/bake-{kind}-{n}.gif').convert('RGBA').save(root / f'source/structures/{target}-table-{n}.png')
inputs = ['courses.lua','campaign.lua','workshop_courses.lua','turntable_courses.lua','finale_design.lua','review_design.lua','lesson_revisions.lua','curriculum.lua','joinery.lua','height_index.lua','engine.lua','road_art.lua','cannon_model.lua','machine_art.lua']
hashes = {name: hashlib.sha256((root/'source'/name).read_text(encoding='utf-8').encode()).hexdigest() for name in inputs}
for p in sorted((root/'source/paving').glob('*.png')):
    hashes[p.relative_to(root/'source').as_posix()] = hashlib.sha256(p.read_bytes()).hexdigest()
(root/'art/runtime-bake.json').write_text(json.dumps({'courses':len(report['courses']),'roadSprites':len(seen),'sourceHashes':hashes}, indent=2)+'\n')
print(f"Collected {len(report['courses'])} roads, {len(seen)} unique surfaces, 62 cannon and 72 fan frames")
