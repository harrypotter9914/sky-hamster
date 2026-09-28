from pathlib import Path
import json,re
p=Path(__file__).resolve().parent
s=(p/'device-ring-v0.10.12.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in s and 'BENCH ERROR' not in s
rows=[];scene=None
for line in s.splitlines():
    if line.startswith('SCENE\t'):
        _,n,kind,index,name=line.split('\t');scene={'scene':int(n),'kind':kind,'index':int(index),'name':name}
    if line.startswith('BENCH route='):
        rows.append({**scene,**{k:float(v) for k,v in re.findall(r'(\w+)=([\d.]+)',line)}})
assert len(rows)==44
report={'complete':True,'routes':[14,15,44],'scenes':len(rows),'rows':rows}
(p/'device-ring-v0.10.12.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 圆形弹力护圈真机抽测','','完整游戏物理、绘制和声音；测试第 14、15、44 关，共 44 个场景。自动输入并不能替代人工通关与扬声器听感评价。','','| 关卡 | 道路 FPS | 场景 FPS 范围 | 最长帧 ms |','| --- | ---: | ---: | ---: |']
for n in (14,15,44):
    rs=[r for r in rows if r['route']==n]
    road=next(r['fps'] for r in rs if r['kind']=='road')
    lines.append(f"| {n} | {road:.2f} | {min(r['fps'] for r in rs):.2f}–{max(r['fps'] for r in rs):.2f} | {max(r['frameMax'] for r in rs):.0f} |")
lines+=['',f"地形缓存缺失：{max(r['cacheMiss'] for r in rows):.0f}；Lua 堆峰值：{max(r['luaKB'] for r in rows):.0f} KB。",'', '最终大关仍存在密集机关场景低于 30 FPS 的限制。各轮移动机关相位可能受实际耗时影响，不把小幅差值当作确定的性能改进。','']
(p/'PERFORMANCE-v0.10.12.md').write_text('\n'.join(lines),encoding='utf-8')
print('\n'.join(lines))
