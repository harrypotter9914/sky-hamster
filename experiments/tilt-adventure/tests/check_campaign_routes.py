"""All-course reachability audit; temporal playability is checked separately."""
from pathlib import Path
from collections import defaultdict, deque
import math, os
os.environ.pop('SKY_LEGACY_FIXTURES',None)
f=Path(__file__).with_name('check_tilt.py');src=f.read_text(encoding='utf-8');env={'__file__':str(f)}
exec(compile(src.split("load('engine')")[0]+"load('engine')",str(f),'exec'),env)
lua=env['lua'];lua.execute('for _,c in ipairs(Courses) do Curriculum.ensure(c) end')
checked=0
def vals(t):return [v for _,v in t.items()] if t else []
def cell(x,y):return math.floor(x/32),math.floor(y/32)
for n,c in lua.globals().Courses.items():
    if not isinstance(n,int):continue
    tiles={(int(t['x']),int(t['y'])) for t in vals(c['tiles'])}
    heights={p:c.height(c,p[0]*32+16,p[1]*32+16)[0] for p in tiles}
    links=defaultdict(set)
    for m in vals(c['mechanisms']):
        ports=vals(lua.globals().Passage.ports(m))
        landing=[]
        for p in ports:
            node=cell(p['x']+p['dx']*8,p['y']+p['dy']*8)
            assert node in tiles,(n,'missing landing',m['kind'],node)
            landing.append(node)
        for a in landing:links[a].update(landing)
        if m['kind']=='trap':
            for tx in range(math.floor((m['x']-m['w']/2)/32),math.ceil((m['x']+m['w']/2)/32)):
                for ty in range(math.floor((m['y']-m['h']/2)/32),math.ceil((m['y']+m['h']/2)/32)):
                    tiles.add((tx,ty));heights[(tx,ty)]=c.height(c,tx*32+16,ty*32+16)[0]
    # Possible cannon arcs, including downhill trajectories. No snap or auto-aim.
    for p in vals(c['pads']):
        if p['kind']!='cannon':continue
        start=cell(p['x'],p['y']);z0=c.height(c,p['x'],p['y'])[0]
        for degree in range(-60,61,3):
            a=math.radians(degree);old_z=z0+20.16
            for i in range(1,91):
                t=i/60;x=p['x']+(33.6+210*t)*math.cos(a);y=p['y']+(33.6+210*t)*math.sin(a)
                z=z0+20.16+102*t-150*t*t;node=cell(x,y)
                if node in tiles and old_z>=heights[node] and z<=heights[node]:links[start].add(node);break
                old_z=z
    start=cell(c['start'][1],c['start'][2]);seen={start};q=deque([start])
    offsets=[(-1,0),(1,0),(0,-1),(0,1)]
    if c['jump']:
        offsets+=[(x,y) for x in range(-4,5) for y in range(-4,5) if 1<x*x+y*y<=16]
    while q:
        a=q.popleft()
        candidates=set(links[a])
        for dx,dy in offsets:
            b=(a[0]+dx,a[1]+dy)
            if b in tiles and abs(heights[b]-heights[a])<=36:candidates.add(b)
        for b in candidates:
            if b not in seen:seen.add(b);q.append(b)
    for label,p in [('goal',c['goal'])]+[('checkpoint',p) for p in vals(c['checkpoints'])]:
        assert cell(p[1],p[2]) in seen,(n,c['shortName'],label,p[1],p[2])
    checked+=1
assert checked==53
print('PASS: all 53 goals/checkpoints connected through road, taught jumps, actual landing ports and reachable cannon arcs; does not prove timing or hand-held control')
