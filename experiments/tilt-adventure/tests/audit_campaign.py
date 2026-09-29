"""Inventory actual geometry and first introductions, not just declared features."""
from pathlib import Path
import json, hashlib, collections, argparse, os
parser=argparse.ArgumentParser();parser.add_argument('--source');parser.add_argument('--output',required=True);args=parser.parse_args()
os.environ.pop('SKY_LEGACY_FIXTURES',None)
fixture=Path(__file__).with_name('check_tilt.py');source=fixture.read_text(encoding='utf-8');scope={'__file__':str(fixture)}
exec(compile(source.split("load('engine')")[0],str(fixture),'exec'),scope)
if args.source:scope['root']=Path(args.source)
scope['load']('engine');lua=scope['lua'];lua.execute('for _,c in ipairs(Courses) do Curriculum.ensure(c) end')
def values(t):return [v for _,v in t.items()] if t else []
def kind(m):
    k=m['kind']
    if k=='rotor':return 'extend' if m['retract'] else 'onboard' if m['turnSquare'] else 'bridge' if m['manual'] else k
    if k=='ferry' and m['manual']:return 'slider'
    if k=='gate' and m['switchGate']:return 'switch'
    return k
chapters=values(lua.globals().Curriculum.chapters)
expected={c['new']:i+1 for i,c in enumerate(chapters) if c['new']}
rows=[];rooms=collections.defaultdict(list);first={};problems=[]
for n,c in lua.globals().Courses.items():
    if not isinstance(n,int):continue
    ms=values(c['mechanisms']);ps=values(c['pads']);features={kind(m) for m in ms}
    features.update('windcontrol' if p['kind']=='fan' else 'cannon' for p in ps if p['kind'] in ('fan','cannon'))
    for k in features:
        first.setdefault(k,n)
        if k in expected and c['chapter']<expected[k]:problems.append(dict(course=n,issue='mechanic before teaching chapter',mechanic=k))
    section_rows=[]
    for j,s in enumerate(values(c['sections']),1):
        tiles=sorted((int(t['x']-s['x']/32),t['y']) for t in values(c['tiles']) if s['x']<=t['x']*32<s['x']+s['width'])
        digest=hashlib.sha256(json.dumps([s['kind'],tiles]).encode()).hexdigest()
        rooms[digest].append(dict(course=n,section=j,kind=s['kind']))
        section_rows.append(dict(kind=s['kind'],width=s['width'],signature=digest))
    rows.append(dict(course=n,id=c['id'],name=c['shortName'],chapter=c['chapter'],review=bool(c['review']),finale=bool(c['finale']),tiles=len(values(c['tiles'])),machines=len(ms),cannons=sum(p['kind']=='cannon' for p in ps),features=sorted(features),sections=section_rows))
rows.sort(key=lambda x:x['course'])
report=dict(courses=rows,firstMechanics=first,sequenceProblems=problems,repeatedRoomShapes=[v for v in rooms.values() if len(v)>1])
Path(args.output).write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Courses:',len(rows),'premature introductions:',problems,'shared room-shape groups:',len(report['repeatedRoomShapes']))
