"""Build the v0.12.1 hardware summary only from complete serial captures."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parent
rows, loads = [], {}
for name in ['device-watchdog-v0.12.1.log', 'device-finales-v0.12.1.log']:
    text = (root / name).read_text(encoding='utf-8-sig')
    assert 'BENCH COMPLETE' in text and 'BENCH ERROR' not in text, name
    plan = re.search(r'BENCH PLAN courses=(\d+) scenes=(\d+)', text)
    start = len(rows)
    scene = {}
    for line in text.splitlines():
        if line.startswith('SCENE'):
            _, number, kind, index, label = line.split()
            scene = dict(scene=int(number), kind=kind, index=int(index), name=label)
        if line.startswith('BENCH route='):
            row = {key: float(value) for key, value in re.findall(r'(\w+)=([0-9.]+)', line)}
            rows.append(dict(row, **scene, log=name))
        if line.startswith('LOAD COMPLETE'):
            data = {key: int(value) for key, value in re.findall(r'(\w+)=(\d+)', line)}
            loads[data['route']] = data
    assert plan and int(plan[2]) == len(rows) - start, 'incomplete scene capture'
assert len(rows) == 156 and {int(row['route']) for row in rows} == {50, 51, 52, 53}
assert all(row['cacheMiss'] == 0 for row in rows)
report = dict(complete=True, scenes=len(rows), rows=rows, loads=loads)
(root / 'device-report-v0.12.1.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
lines = ['# 0.12.1 长关加载与真机采样', '',
         '四个终局关卡共 156 个道路、机关和控制点场景，使用正式更新、绘制及声音。第 50 关先独立验证，之后连续测试第 51–53 关。两个采集均正常到达 BENCH COMPLETE，无 BENCH ERROR。', '',
         '| 关卡 | 场景数 | 场景 FPS 范围 | 最长玩法帧 ms | 最长加载更新 ms |',
         '| --- | ---: | ---: | ---: | ---: |']
for route in range(50, 54):
    subset = [row for row in rows if row['route'] == route]
    load = loads.get(route)
    lines.append(f"| {route} | {len(subset)} | {min(r['fps'] for r in subset):.2f}–{max(r['fps'] for r in subset):.2f} | {max(r['frameMax'] for r in subset):.0f} | {load['maxUpdateMS'] if load else '未记录'} |")
lines += ['', f"可见地形缓存缺失：0。采样 Lua 堆峰值：{max(r['luaKB'] for r in rows):.0f} KB；这不代表包含图片和音频的全部原生内存。", '',
          '加载耗时单独记录，不混入玩法 FPS：']
for route, load in sorted(loads.items()):
    lines.append(f"- 第 {route} 关：总计 {load['elapsedMS']/1000:.2f} 秒，最长一次加载更新 {load['maxUpdateMS']} ms。")
lines += ['', '之前的错误日志记录的是一次运行循环超过 10 秒触发系统保护。修复后这些加载和采样成功结束，但加载仍有较长的单步，复杂场景也没有全部达到 30 FPS。自动输入与固定相位采样不能替代人工完成全关卡，更不能保证所有情况下不会崩溃。正常游戏安装、进关及错误日志复核另见 VALIDATION-v0.12.1.md。', '']
(root / 'PERFORMANCE-v0.12.1.md').write_text('\n'.join(lines), encoding='utf-8')
print('\n'.join(lines))
