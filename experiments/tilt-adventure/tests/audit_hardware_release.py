"""Archive diagnostic evidence, then verify the exact public package and save.

Requires a mounted physical Playdate. No test progress is published.
"""
from pathlib import Path
import argparse, hashlib, json, shutil

here=Path(__file__).resolve().parent
repo=here.parents[2]
art=repo/'release/itch-v0.12.9/hardware'
drive=Path('F:/')
data=drive/'Data/com.wangyibo.skyhamster.tilt'
public=repo/'builds/public-download-v0.12.9/sky-hamster-tilt.pdx'
parser=argparse.ArgumentParser()
parser.add_argument('phase',choices=['collect','installed'])
args=parser.parse_args()
assert data.is_dir(), 'Physical Playdate Data disk is not mounted'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
original=art/'save-before/tilt-progress.json'
progress=data/'tilt-progress.json'
assert digest(original)==digest(progress), 'User save changed; preserve and investigate before continuing'
if args.phase=='collect':
    report=json.loads((data/'native-functional-report.json').read_text(encoding='utf-8-sig'))
    assert report['complete'] and report['device'] and report['scope']=='full' and not report.get('error')
    assert 'native-datastore-fresh-process-continuation' in report['checks']
    perf=json.loads((data/'tilt-perf-report.json').read_text(encoding='utf-8-sig'))
    audio=json.loads((data/'audio-device-report.json').read_text(encoding='utf-8-sig'))
    assert perf['complete'] and perf['device'] and len(perf['stages'])==761 and not perf.get('error')
    assert audio['complete'] and len(audio['samples'])==47 and not audio.get('error')
    for name in ['native-functional-report.json','tilt-perf-report.json','audio-device-report.json']:
        shutil.copy2(data/name,art/name)
    frames=art/'native-frames';frames.mkdir(exist_ok=True)
    images=list((data/'images').glob('native-functional-*.gif'))
    assert len(list((data/'images').glob('native-functional-guide-*.gif')))==84
    for p in images: shutil.copy2(p,frames/p.name)
    shutil.copytree(data,art/'save-after',dirs_exist_ok=True)
    print(f'Archived {len(report["checks"])} native checks, 761 scenes, 47 audio checks and {len(images)} native framebuffers; original save unchanged.')
else:
    installed=drive/'Games/sky-hamster-tilt.pdx'
    expected={str(p.relative_to(public)).replace('\\','/'):digest(p) for p in public.rglob('*') if p.is_file()}
    actual={str(p.relative_to(installed)).replace('\\','/'):digest(p) for p in installed.rglob('*') if p.is_file()}
    assert actual==expected, 'Installed game does not match the public download byte for byte'
    info=(installed/'pdxinfo').read_text()
    assert 'version=0.12.9' in info and 'buildNumber=59' in info
    manifest={'version':'0.12.9','build':59,'physicalDevice':True,
              'installedFiles':len(actual),'installedFileSha256':actual,
              'publicZipSha256':digest(Path('C:/Users/12063/Downloads/sky-hamster-v0.12.9.zip')),
              'originalSaveUnchanged':True,'userSaveSha256':digest(progress),
              'limitations':['injected-input automation is distinct from hand-held gesture testing',
                             'native playback checks do not establish speaker listening quality']}
    (art/'installed-public-package.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'PASS: all {len(actual)} installed files match the actual public download; original save unchanged; 0.12.9 build 59.')
