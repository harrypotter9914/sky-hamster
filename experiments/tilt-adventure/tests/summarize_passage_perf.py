"""Summarize the actual hardware passage workload without inventing missing rows."""
from pathlib import Path
import json,re
p=Path(__file__).resolve().parent
s=(p/'device-passages-v0.11.0.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in s and 'BENCH ERROR' not in s
rows=[];scene=None
for line in s.splitlines():
    if line.startswith('SCENE\t'):
        _,n,kind,index,name=line.split('\t');scene={'scene':int(n),'kind':kind,'index':int(index),'name':name}
    if line.startswith('BENCH route='):
        rows.append({**scene,**{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)}})
expected=int(re.search(r'BENCH PLAN courses=48 scenes=(\d+)',s)[1])
assert len(rows)==expected==141
routes=sorted({int(r['route']) for r in rows})
report={'complete':True,'routes':routes,'scenes':len(rows),'rows':rows}
(p/'device-passages-v0.11.0.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 通行提示与转台真机抽测','','完整游戏物理、绘制和声音；首轮 18 关、141 个场景，包括每关道路、局部移动、每个机关和控制点。自动输入不能替代人工通关与握持手感评价。','','## 首轮（优化前）','','| 关卡 | 道路 FPS | 场景 FPS 范围 | 最长帧 ms |','| --- | ---: | ---: | ---: |']
for n in routes:
    rs=[r for r in rows if r['route']==n]
    road=next(r['fps'] for r in rs if r['kind']=='road')
    lines.append(f"| {n} | {road:.2f} | {min(r['fps'] for r in rs):.2f}–{max(r['fps'] for r in rs):.2f} | {max(r['frameMax'] for r in rs):.0f} |")
lines+=['',f"地形缓存缺失：{max(r['cacheMiss'] for r in rows):.0f}；Lua 堆峰值：{max(r['luaKB'] for r in rows):.0f} KB。",'', '这是指定 18 关的逐场景采样，不是全 48 关人工通关，也不等于所有场景锁定 30 FPS。移动机关相位受真实耗时影响，不把跨版本的小幅差值当作确定的性能改进。','']
final_path=p/'device-passages-final-v0.11.0.log'
if final_path.exists() and 'BENCH COMPLETE' in final_path.read_text(encoding='utf-8-sig'):
    final_text=final_path.read_text(encoding='utf-8-sig');assert 'BENCH ERROR' not in final_text
    final=[];scene=None
    for line in final_text.splitlines():
        if line.startswith('SCENE\t'):
            _,n,kind,index,name=line.split('\t');scene={'scene':int(n),'kind':kind,'index':int(index),'name':name}
        if line.startswith('BENCH route='):
            final.append({**scene,**{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)}})
    assert len(final)==43
    (p/'device-passages-final-v0.11.0.json').write_text(json.dumps({'complete':True,'routes':[44,48],'scenes':len(final),'rows':final},indent=2)+'\n')
    lines+=['## 优化后复测','','无诊断计时器的正式更新、绘制、声音；第 44、48 关全部 43 个道路／机关／控制点场景。','','| 关卡 | 道路 FPS | 场景 FPS 范围 | 最长帧 ms |','| --- | ---: | ---: | ---: |']
    for n in (44,48):
        rs=[r for r in final if r['route']==n]
        road=next(r['fps'] for r in rs if r['kind']=='road')
        lines.append(f"| {n} | {road:.2f} | {min(r['fps'] for r in rs):.2f}–{max(r['fps'] for r in rs):.2f} | {max(r['frameMax'] for r in rs):.0f} |")
    lines+=['',f"地形缓存缺失：{max(r['cacheMiss'] for r in final):.0f}；Lua 堆峰值：{max(r['luaKB'] for r in final):.0f} KB。",'']
for suffix,title,expected in [('sign-layout','编号提示首轮',9),('sign-layout-final','名称牌共同避让后的最终密集区复测',3)]:
    path=p/f'device-{suffix}-v0.11.0.log'
    if not path.exists():continue
    s=path.read_text(encoding='utf-8-sig')
    if 'BENCH COMPLETE' not in s:continue
    assert 'BENCH ERROR' not in s
    extra=[{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)} for line in s.splitlines() if line.startswith('BENCH route=')]
    assert len(extra)==expected
    (p/f'device-{suffix}-v0.11.0.json').write_text(json.dumps({'complete':True,'scenes':len(extra),'rows':extra},indent=2)+'\n')
    lines+=['## '+title,'','| 关卡 | 场景数 | FPS 范围 | 最长帧 ms |','| --- | ---: | ---: | ---: |']
    for route in sorted({int(r['route']) for r in extra}):
        rows=[r for r in extra if r['route']==route]
        lines.append(f"| {route} | {len(rows)} | {min(r['fps'] for r in rows):.2f}–{max(r['fps'] for r in rows):.2f} | {max(r['frameMax'] for r in rows):.0f} |")
    lines+=['',f"地形缓存缺失：{max(r['cacheMiss'] for r in extra):.0f}。这是指定机关附近的自动采样，不能代表全关卡最低帧率。",'']
(p/'PERFORMANCE-v0.11.0.md').write_text('\n'.join(lines),encoding='utf-8')
print('\n'.join(lines))
