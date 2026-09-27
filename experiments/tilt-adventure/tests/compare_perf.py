"""Compare completed hardware scenes; never use profiling data as release FPS."""
import argparse
import json
from collections import Counter
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('before', type=Path)
p.add_argument('after', type=Path)
p.add_argument('output', type=Path)
args = p.parse_args()
before = json.loads(args.before.read_text(encoding='utf-8'))
after = json.loads(args.after.read_text(encoding='utf-8'))
for report in (before, after):
    assert report['complete'] and not report['errors']
    assert report['routes'] == list(range(1, 45)) and report['scenes'] == 303
def coverage(report):
    return Counter((r['route'], r['kind'], r['index'], r['name']) for r in report['rows'])
assert coverage(before) == coverage(after), 'Scenario coverage differs'

lines = ['# 全部 44 关真机性能对照', '',
         '同一台 Playdate；0.10.8 基线与 0.10.9 优化版；均关闭逐函数性能探针，保留游戏绘制、物理与音效。', '',
         '每关包含道路快速遍历、三处局部移动、该关所有机关与控制点。下表帧率是单个采样场景的平均值；“最慢场景”取这些平均值的最低值，并非最低瞬时帧率。“最长帧”保留短暂卡顿。加载时间不计入帧率。这是 303 段硬件采样，不等于人工通关。', '',
         '| 关卡 | 道路遍历：旧 → 新 FPS | 局部/机关最慢场景：旧 → 新 FPS | 新版最长单帧 ms |',
         '| --- | ---: | ---: | ---: |']
for route in range(1, 45):
    old = [r for r in before['rows'] if r['route'] == route]
    new = [r for r in after['rows'] if r['route'] == route]
    roads = [next(r['fps'] for r in rows if r['kind'] == 'road') for rows in (old, new)]
    local = [min(r['fps'] for r in rows if r['kind'] != 'road') for rows in (old, new)]
    lines.append(f"| {route:02d} | {roads[0]:.2f} → {roads[1]:.2f} | {local[0]:.2f} → {local[1]:.2f} | {max(r['frameMax'] for r in new):.0f} |")
lines += ['', '## 新版最慢的 12 个采样场景', '',
          '| 关卡 | 场景 | 平均 FPS | 95% 帧间隔 ms | 最长帧 ms |',
          '| --- | --- | ---: | ---: | ---: |']
for r in sorted(after['rows'], key=lambda row: row['fps'])[:12]:
    lines.append(f"| {r['route']:.0f} | {r['kind']} / {r['name']} {r['index']} | {r['fps']:.2f} | {r['frame95']:.0f} | {r['frameMax']:.0f} |")
lines += ['', '基线因早期自动锁屏分为 1–12 和 13–44 两段；逐关场景相同。原始串口日志与 JSON/CSV 位于本目录。保留中途的性能分析日志，不能把带探针的结果当成正式版本帧率。', '']
args.output.write_text('\n'.join(lines), encoding='utf-8')
print('Comparison written:', args.output)
print('Visible terrain misses:', max(r['cacheMiss'] for r in after['rows']))
print('Lua heap maximum KB:', max(r['luaKB'] for r in after['rows']))
