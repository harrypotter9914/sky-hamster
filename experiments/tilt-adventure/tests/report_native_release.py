"""Summarize raw COM4 measurements, requiring all planned scenes to complete."""
from pathlib import Path
import hashlib, json, re

root=Path(__file__).resolve().parent
log=root/'device-all-v0.12.9.log'
text=log.read_text(encoding='utf-8-sig')
plan=re.search(r'BENCH PLAN courses=(\d+) scenes=(\d+)',text)
assert plan, 'No native benchmark plan'
scenes=int(plan[2]);rows=[];loads={};scene={}
for line in text.splitlines():
    if line.startswith('SCENE'):
        _,n,kind,index,name=line.split()
        scene=dict(scene=int(n),kind=kind,index=int(index),name=name)
    elif line.startswith('BENCH route='):
        rows.append(dict({k:float(v) for k,v in re.findall(r'(\w+)=([0-9.]+)',line)},**scene))
    elif line.startswith('LOAD COMPLETE'):
        values={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',line)}
        loads[values['route']]=values
complete='BENCH COMPLETE' in text and 'BENCH ERROR' not in text
if not complete:
    print(json.dumps(dict(complete=False,scenes=len(rows),planned=scenes,latest=rows[-1] if rows else None)))
    raise SystemExit(2)
assert len(rows)==scenes and {int(r['route']) for r in rows}==set(range(1,54))
assert len(loads)==53
assert 'AUDIO COMPLETE\t47' in text or 'AUDIO COMPLETE 47' in text
source=root.parent/'source'
manifest={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in source.glob('*.lua')}
report=dict(version='0.12.9',complete=True,physicalDevice=True,planned=scenes,
            audioSamples=47,rows=rows,loads=loads,productionLua=manifest,
            limitations=['scripted camera/ball placement and mechanism state',
                         'not a human playthrough or physical grip gesture test',
                         'audio playback/stop assertions, not a listening evaluation'])
(root/'device-all-v0.12.9.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# 0.12.9 真机全关卡采样','',
       '物理 Playdate / COM4 / 2026-10-09。生产更新、原生绘制与声音实际运行；输入、球的位置和部分机关状态由隔离测试包提供。这不是人工逐关通关，也不是实际手持动作或听感测试。','',
       f'53 关、{len(rows)} 场景全部完成，47 项声音原生播放／停止检查完成，无 BENCH ERROR。场景平均 FPS 范围 {min(r["fps"] for r in rows):.2f}–{max(r["fps"] for r in rows):.2f}；最长游玩单帧 {max(r["frameMax"] for r in rows):.0f} ms。', '',
       '| 关卡 | 场景数 | 加载秒 | 加载最长更新 ms | 平均 FPS 范围 | 最高 P95 ms | 最长帧 ms |',
       '| --- | ---: | ---: | ---: | --- | ---: | ---: |']
for n in range(1,54):
    current=[r for r in rows if r['route']==n];load=loads[n]
    lines.append(f'| {n} | {len(current)} | {load["elapsedMS"]/1000:.3f} | {load["maxUpdateMS"]} | {min(r["fps"] for r in current):.2f}–{max(r["fps"] for r in current):.2f} | {max(r["frame95"] for r in current):.0f} | {max(r["frameMax"] for r in current):.0f} |')
lines+=['','加载数字受前序关卡与共享缓存影响；第 1 关是已准备过的热加载。跳转位置的道路场景刻意制造相机／缓存压力。FPS 为短窗口平均，不代表每个条件恒定 30 FPS。', '',
        '原始日志、场景清单、加载工作分项、Lua 源码指纹保存在同目录。正式公开包安装／启动、功能检查、存档保护和手动未测项另见发布核对记录。','']
(root/'PERFORMANCE-v0.12.9.md').write_text('\n'.join(lines),encoding='utf-8')
print(f'PASS: {len(rows)} physical scenes / 53 courses, 47 playback checks; FPS {min(r["fps"] for r in rows):.2f}–{max(r["fps"] for r in rows):.2f}; maximum frame {max(r["frameMax"] for r in rows):.0f}ms')
