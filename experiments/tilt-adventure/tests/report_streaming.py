"""Compare complete physical captures; keep loading separate from gameplay."""
from pathlib import Path
import json,re,statistics
root=Path(__file__).resolve().parent
text=(root/'device-finales-v0.12.2.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in text and 'BENCH ERROR' not in text
rows=[];loads={};scene={}
for line in text.splitlines():
    if line.startswith('SCENE'):
        _,n,kind,index,name=line.split()
        scene=dict(scene=int(n),kind=kind,index=int(index),name=name)
    if line.startswith('BENCH route='):
        rows.append(dict({k:float(v) for k,v in re.findall(r'(\w+)=([0-9.]+)',line)},**scene))
    if line.startswith('LOAD COMPLETE'):
        data={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
        loads[data['route']]=data
assert len(rows)==156 and len(loads)==4
old=json.loads((root/'device-report-v0.12.1.json').read_text())
comparisons=[]
for before,after in zip(old['rows'],rows):
    assert all(before[k]==after[k] for k in ('route','kind','index','name'))
    comparisons.append(dict(route=after['route'],kind=after['kind'],index=after['index'],before=before['fps'],after=after['fps'],gain=after['fps']/before['fps']-1))
report=dict(complete=True,scenes=len(rows),rows=rows,loads=loads,comparisons=comparisons)
(root/'device-report-v0.12.2.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 0.12.2 真机加载与帧率对比','','四个最终大关共 156 个场景完成同一生产更新、绘制和音效测试，无 BENCH ERROR。加载单独计时，不混入玩法帧率。','',
'| 关卡 | 旧加载 秒 | 新加载 秒 | 旧场景 FPS 范围 | 新场景 FPS 范围 | 旧最长帧 ms | 新最长帧 ms |','| --- | ---: | ---: | --- | --- | ---: | ---: |']
for n in range(50,54):
    before=[r for r in old['rows'] if r['route']==n];after=[r for r in rows if r['route']==n]
    oldload=old['loads'].get(str(n))
    prev=f"{oldload['elapsedMS']/1000:.2f}" if oldload else '未记录'
    lines.append(f"| {n} | {prev} | {loads[n]['elapsedMS']/1000:.2f} | {min(r['fps'] for r in before):.2f}–{max(r['fps'] for r in before):.2f} | {min(r['fps'] for r in after):.2f}–{max(r['fps'] for r in after):.2f} | {max(r['frameMax'] for r in before):.0f} | {max(r['frameMax'] for r in after):.0f} |")
lines+=['',f"逐场景 FPS 相对变化的中位数为 {statistics.median(c['gain'] for c in comparisons)*100:.1f}%。采样 Lua 堆峰值 {max(r['luaKB'] for r in rows):.0f} KB，区块计数峰值 {max(r['chunks'] for r in rows):.0f}；Lua 堆不含全部图片／音频的原生内存。",'',
'测试会瞬移到各机关并快速扫过整张地图，所以新版本的 cacheMiss 记录了即时补图，不表示道路缺失或碰撞失效。正常速度的连续准备另有独立测试；不能把这种瞬移压力测试说成玩家连续手持通关。', '',
'旧版分两次启动完成 50 与 51–53，新版一次启动完成 50–53；首次使用共享资源的温度不同，因此加载结果是完整实测记录，不声称每个差值都是严格隔离变量的实验。', '',
'最长加载更新：'+', '.join(f"{n} 关 {loads[n]['maxUpdateMS']} ms" for n in range(50,54))+'。加载仍不是瞬间完成，复杂场景仍可能低于 30 FPS。','']
travel_text=(root/'device-travel-v0.12.2.log').read_text(encoding='utf-8-sig')
assert 'BENCH COMPLETE' in travel_text and 'BENCH ERROR' not in travel_text
travel=[];travel_loads={}
for line in travel_text.splitlines():
    if line.startswith('BENCH route='):
        travel.append({k:float(v) for k,v in re.findall(r'(\w+)=([0-9.]+)',line)})
    if line.startswith('LOAD COMPLETE'):
        data={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
        travel_loads[data['route']]=data
assert len(travel)==5 and all(r['cacheMiss']==0 for r in travel)
report['travel']=dict(complete=True,rows=travel,loads=travel_loads,worldUnitsPerFrame=8)
(root/'device-report-v0.12.2.json').write_text(json.dumps(report,indent=2)+'\n')
lines+=['## 连续快移检查','',
'相机每个采样帧移动 8 个世界单位；30 FPS 时相当于 240 单位／秒，实际速度随帧率变化。包含最大关卡的全程前进、倒退，不等同于人工控球通关。五处均无可见区块缓存缺失。','',
'| 关卡 | 加载秒 | FPS | 帧时间 P95 ms | 最长帧 ms | 可见缓存缺失 |',
'| --- | ---: | ---: | ---: | ---: | ---: |']
for row in travel:
    n=int(row['route'])
    lines.append(f"| {n} | {travel_loads[n]['elapsedMS']/1000:.3f} | {row['fps']:.2f} | {row['frame95']:.0f} | {row['frameMax']:.0f} | {row['cacheMiss']:.0f} |")
lines+=['', '第 1 关是已准备过的热加载，不能用它的 0.304 秒代表冷启动。25／29／36 关约 0.5–0.8 秒；最大关卡此次加载 7.831 秒，3951 个采样帧平均 28.30 FPS，最长 56 ms。', '',
'仍有短暂停顿：156 场景采样中，第 50 关最长帧从 63 ms 增至 157 ms，不能宣称所有峰值都改善。总体场景 FPS 提升不等于稳定 30 FPS。','']
(root/'PERFORMANCE-v0.12.2.md').write_text('\n'.join(lines),encoding='utf-8')
print('\n'.join(lines))
