"""Report separate workloads without treating changed maps as matched scenes."""
from pathlib import Path
import json,re
root=Path(__file__).resolve().parent

def read(name):
 text=(root/name).read_text(encoding='utf-8-sig')
 assert 'BENCH COMPLETE' in text and 'BENCH ERROR' not in text,name
 rows=[];loads={};scene={}
 for line in text.splitlines():
  if line.startswith('SCENE'):
   _,n,kind,index,label=line.split();scene=dict(scene=int(n),kind=kind,index=int(index),name=label)
  if line.startswith('BENCH route='):
   rows.append(dict({k:float(v) for k,v in re.findall(r'(\w+)=([0-9.]+)',line)},**scene))
  if line.startswith('LOAD COMPLETE'):
   d={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)};loads[d['route']]=d
 return dict(log=name,rows=rows,loads=loads)

survey=read('device-survey-v0.12.3.log');first=read('device-finales-v0.12.3.log')
assert len(survey['loads'])==53 and {int(r['route']) for r in survey['rows']}==set(range(1,54))
assert len(first['rows'])==182
report=dict(complete=True,survey=survey,finaleFirstPass=first)
(root/'device-report-v0.12.3.json').write_text(json.dumps(report,indent=2)+'\n')
s=survey['rows'];f=first['rows']
lines=['# 0.12.3 真机测试与优化记录','',
'测试在物理 Playdate 上运行生产更新、绘制和声音代码。自动相机／机关采样不等于人工手持逐关通关。加载与游玩帧率分别记录。','',
f"最终源代码全 53 关共 {len(s)} 场景完成，无 BENCH ERROR；场景平均 FPS 为 {min(r['fps'] for r in s):.2f}–{max(r['fps'] for r in s):.2f}，最长单帧 {max(r['frameMax'] for r in s):.0f} ms。采样 Lua 堆峰值 {max(r['luaKB'] for r in s):.0f} KB（不包含所有原生图片／音频内存）。",'',
'每关在路线 10%／50%／90% 处各采样 60 帧，并在有机关的关卡增加一个 90 帧机关场景。短窗口可能错过偶发问题，不是稳定 30 FPS 的保证。来源指纹见 `survey-workload-provenance-v0.12.3.json`。','',
'| 关卡 | 加载秒 | 最长加载更新 ms | 场景平均 FPS 范围 | 帧 P95 最高 ms | 最长帧 ms |',
'| --- | ---: | ---: | --- | ---: | ---: |']
for n in range(1,54):
 rows=[r for r in s if r['route']==n];load=survey['loads'][n]
 lines.append(f"| {n} | {load['elapsedMS']/1000:.3f} | {load['maxUpdateMS']} | {min(r['fps'] for r in rows):.2f}–{max(r['fps'] for r in rows):.2f} | {max(r['frame95'] for r in rows):.0f} | {max(r['frameMax'] for r in rows):.0f} |")
lines+=['','第 1 关已由启动路径准备过，其加载数字为热加载。其余关卡的共享资源也受到测试顺序影响。cacheMiss 计数包含切换采样位置时的即时补图，不能当成碰撞地面缺失。','',
'## 四终局详细首轮','',
f"在后续教学／复习关重组和两项索引优化之前，四个终局完成 182 场景详细测试，平均 FPS 范围 {min(r['fps'] for r in f):.2f}–{max(r['fps'] for r in f):.2f}，最长帧 {max(r['frameMax'] for r in f):.0f} ms。终局几何随后未改动，但这不是最终代码的完整 182 场景复测；最终代码由上表全关卡抽测覆盖。",'',
'| 终局 | 首轮加载秒 | 最终源加载秒 | 首轮最长加载更新 ms | 最终源最长加载更新 ms |',
'| --- | ---: | ---: | ---: | ---: |']
for n in range(50,54):
 a=first['loads'][n];b=survey['loads'][n];lines.append(f"| {n} | {a['elapsedMS']/1000:.3f} | {b['elapsedMS']/1000:.3f} | {a['maxUpdateMS']} | {b['maxUpdateMS']} |")
lines+=['','两轮的路线几何相同，但共享资源温度和前序工作不同，不能把加载差值全部归因于某项优化。更大、更丰富的关卡也不能直接与 0.12.2 的较短地图做等负载比较。','',
'## 本轮优化与防退步','',
'- 复习连接段 128→64 单位，缩短没有新增判断的过渡路，仍保留安全检查点。',
'- 道路图片按已有顺序匹配，遇到顺序不一致才建立坐标表；正常和重排输入分别检查。',
'- 地块投影边界用解析半尺寸计算；28,310 个地块均保留原索引所覆盖的区块，原生画面比对未出现新的大范围差异。',
'- 保留相机附近两块余量和约 2 ms 分批准备、40 个区块的回收策略。240 单位／秒前进、倒退及检查点跳转测试通过，显示的图片均已完整。',
'- 固定道路美术继续预生成；新图对应 2,917 张去重道路图和 134 张炮／风机图。导出源码快照避免资源与关卡错配。','',
'局限：复杂场景仍有掉帧和偶发长帧，长关加载不是瞬时完成。本轮没有降低机关数量、关闭音效或删除美术来获取数字，也不声称已消除全部卡顿。','']
lines+=['','## 未采用的高度查找试验','','同一个第 53 关第 16 机关仪器化场景，原查询 21.73 FPS、P95 51 ms、最长 84 ms；二分查询 21.82 FPS、P95 51 ms、最长 82 ms。不能确认显著收益，因此已撤回，最终 Lua 源码与上面 203 场景抽测的指纹一致。53,400 点等价检查与尝试记录保留在 `height-trial-v0.12.3.json`。','']
(root/'PERFORMANCE-v0.12.3.md').write_text('\n'.join(lines),encoding='utf-8')
print(f"PASS: {len(s)} final-source survey scenes / 53 courses and 182 diagnostic finale scenes")
print(f"FPS {min(r['fps'] for r in s):.2f}–{max(r['fps'] for r in s):.2f}; max frame {max(r['frameMax'] for r in s):.0f}ms")
