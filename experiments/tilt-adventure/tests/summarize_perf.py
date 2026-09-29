"""Summarize captured device serial measurements, keeping stress and local scenes separate."""
import argparse
import csv
import json
import re
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('log', type=Path)
p.add_argument('--write', action='store_true')
args = p.parse_args()
text = args.log.read_text(encoding='utf-8-sig', errors='replace')
scene = {}
rows = []
for line in text.splitlines():
    if line.startswith('SCENE'):
        fields = line.split()
        if len(fields) >= 5:
            scene = dict(scene=int(fields[1]), kind=fields[2], index=int(fields[3]), name=fields[4])
    if line.startswith('BENCH route='):
        row = {k: float(v) for k, v in re.findall(r'(\w+)=([0-9.]+)', line)}
        row.update(scene)
        rows.append(row)
routes = sorted({int(r['route']) for r in rows})
report = dict(complete='BENCH COMPLETE' in text, errors=re.findall(r'BENCH ERROR[^\r\n]*', text),
              routes=routes, scenes=len(rows), rows=rows)
plan = re.search(r'BENCH PLAN courses=(\d+) scenes=(\d+)', text)
campaign_size = int(plan[1]) if plan else None
print(f"Complete: {report['complete']}; sampled courses: {len(routes)}" +
      (f" (campaign: {campaign_size})" if campaign_size else '') +
      f"; scenes: {len(rows)}; errors: {report['errors']}")
for label, subset in [('road stress', [r for r in rows if r.get('kind') == 'road']),
                      ('normal and machinery', [r for r in rows if r.get('kind') != 'road'])]:
    if not subset:
        continue
    print(f"{label}: {min(r['fps'] for r in subset):.2f}–{max(r['fps'] for r in subset):.2f} FPS; "
          f"slowest frame {max(r['frameMax'] for r in subset):.0f} ms")
    for r in sorted(subset, key=lambda r: r['fps'])[:12]:
        print(f"  route {int(r['route']):2} {r.get('kind', ''):10} {r.get('name', ''):10} "
              f"#{r.get('index', 0)}: {r['fps']:.2f} FPS, p95={r['frame95']:.0f}, max={r['frameMax']:.0f}, cpu95={r['cpu95']:.0f}")
if args.write and rows:
    args.log.with_suffix('.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    with args.log.with_suffix('.csv').open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
