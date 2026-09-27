from pathlib import Path
import json,re

root=Path(__file__).resolve().parent
log=(root/'device-occlusion-v0.10.11.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in log and 'BENCH ERROR' not in log
rows=[];scene=None
for line in log.splitlines():
    if line.startswith('SCENE\t'):
        _,n,kind,index,name=line.split('\t')
        scene={'scene':int(n),'kind':kind,'index':int(index),'name':name}
    if line.startswith('BENCH route='):
        rows.append({**scene,**{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)}})
prior=json.loads((root/'device-all-v0.10.9.json').read_text(encoding='utf-8'))['rows']
hud=json.loads((root/'device-hud-v0.10.10.json').read_text(encoding='utf-8'))['rows']
before=[r for r in prior if r['route'] in (14,27)]+[r for r in hud if r['route']==44]
assert len(rows)==len(before)==41
keys=('route','kind','index','name')
assert [tuple(r[k] for k in keys) for r in rows]==[tuple(r[k] for k in keys) for r in before]
report={'complete':True,'errors':[],'routes':[14,27,44],'scenes':41,'rows':rows}
(root/'device-occlusion-v0.10.11.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 弹簧与机关遮挡真机抽测','','抽测第 14、27、44 关，共 41 个场景。使用完整游戏物理、绘制和音效，关闭逐函数探针。第 14、27 关对照最近的 0.10.9 完整采样，第 44 关对照 0.10.10 HUD 采样；不冒充同一轮全关卡重测。','','| 关卡 | 道路平均 FPS 旧 → 新 | 最慢场景平均 FPS 旧 → 新 | 最长单帧 ms |','| --- | ---: | ---: | ---: |']
for n in (14,27,44):
    a=[r for r in before if r['route']==n];b=[r for r in rows if r['route']==n]
    road=lambda rs:next(r['fps'] for r in rs if r['kind']=='road')
    lines.append(f"| {n} | {road(a):.2f} → {road(b):.2f} | {min(r['fps'] for r in a):.2f} → {min(r['fps'] for r in b):.2f} | {max(r['frameMax'] for r in b):.0f} |")
lines+=['',f"可见地形缓存缺失：{max(r['cacheMiss'] for r in rows):.0f}。Lua 堆峰值：{max(r['luaKB'] for r in rows):.0f} KB。",'', '最终大关密集机关仍低于 30 FPS；测试为可重复的自动场景，不等于人工操作全部关卡。移动机关按实际经过时间推进，因此不同采样轮次的动画相位可能不同，单场景差值不完全等于遮挡代码的开销。最终关道路与最慢场景均略低于旧版，不能宣称性能没有回退。','']
(root/'PERFORMANCE-v0.10.11.md').write_text('\n'.join(lines),encoding='utf-8')
print('\n'.join(lines))
