"""Summarize the focused hardware run, matched to the previous full campaign run."""
from pathlib import Path
import json,re

root=Path(__file__).resolve().parent
log=(root/'device-hud-v0.10.10.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in log and 'BENCH ERROR' not in log
rows=[];scene=None
for line in log.splitlines():
    if line.startswith('SCENE\t'):
        _,n,kind,index,name=line.split('\t')
        scene={'scene':int(n),'kind':kind,'index':int(index),'name':name}
    if line.startswith('BENCH route='):
        assert scene
        rows.append({**scene,**{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)}})
old=json.loads((root/'device-all-v0.10.9.json').read_text(encoding='utf-8'))
before=[r for r in old['rows'] if r['route'] in (1,15,44)]
assert len(rows)==len(before)==41
keys=('route','kind','index','name')
assert [tuple(r[k] for k in keys) for r in rows]==[tuple(r[k] for k in keys) for r in before]
report={'complete':True,'errors':[],'routes':[1,15,44],'scenes':41,'rows':rows}
(root/'device-hud-v0.10.10.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 顶部 HUD 真机抽测','','本轮抽测第 1、15、44 关，共 41 个场景。实际运行完整游戏的绘制、物理、音效；仅用可重复输入替代人工操作。对照为上一版相同 41 个场景，不是本轮重新测完全部 44 关。均关闭逐函数探针。','','| 关卡 | 道路遍历 FPS 旧 → 新 | 最慢场景平均 FPS 旧 → 新 | 新版最长单帧 ms |','| --- | ---: | ---: | ---: |']
for n in (1,15,44):
    a=[r for r in before if r['route']==n];b=[r for r in rows if r['route']==n]
    road=lambda rs:next(r['fps'] for r in rs if r['kind']=='road')
    lines.append(f"| {n} | {road(a):.2f} → {road(b):.2f} | {min(r['fps'] for r in a):.2f} → {min(r['fps'] for r in b):.2f} | {max(r['frameMax'] for r in b):.0f} |")
lines+=['',f"可见地形缓存缺失：{max(r['cacheMiss'] for r in rows):.0f}。Lua 堆峰值：{max(r['luaKB'] for r in rows):.0f} KB。",'', '最终关卡密集机关仍低于 30 FPS；这次 UI 更新没有解决其原有性能瓶颈。单轮微小差异不视为稳定性能提升。','']
(root/'PERFORMANCE-v0.10.10.md').write_text('\n'.join(lines),encoding='utf-8')
print('\n'.join(lines))
