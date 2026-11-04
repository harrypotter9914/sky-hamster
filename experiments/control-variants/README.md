[← Project home](../../README.md) · [Journal index / 日志目录](../../docs/JOURNAL.md)

# Sky Hamster control-rule experiments

# Sky Hamster 控制规则实验合集

A separate experiment area, not a new formal-game release; root project stays unchanged. Reconstructed from v0.6.7 and design records, not historical originals or playtest evidence. Design: Wang Yibo; AI-assisted code, packaging, and automated tests.

独立实验区，不是正式游戏的新版本；仓库根目录不变。基于 v0.6.7 与设计记录重建，不是历史原件或玩家测试证据。设计：Wang Yibo；代码、打包、自动测试由 AI 辅助完成。

## Download eight variants

## 下载八个变体

[Download all eight as ZIP](downloads/sky-hamster-eight-variants.zip?raw=true), containing eight separate .pdx packages.

[下载全部八版 ZIP](downloads/sky-hamster-eight-variants.zip?raw=true)，解压得到八个独立 .pdx。

|Number<br>编号|Download<br>下载|Rule<br>规则|
| --- | --- | --- |
| Variation 1 | [Target speed](downloads/sky-hamster-speed.zip?raw=true) | Crank sets speed; D-pad steers. |
| Variation 1 | [目标速度](downloads/sky-hamster-speed.zip?raw=true) | 摇柄设定速度，方向键控制方向。 |
| Variation 2 | [Persistent throttle](downloads/sky-hamster-throttle.zip?raw=true) | Force persists after stopping; opposing input adds braking. |
| Variation 2 | [持续油门](downloads/sky-hamster-throttle.zip?raw=true) | 停摇保持推力，反方向额外刹车。 |
| Variation 3 | [Reverse-crank brake](downloads/sky-hamster-brake.zip?raw=true) | Clockwise propels; reverse brakes without reversing. |
| Variation 3 | [反摇刹车](downloads/sky-hamster-brake.zip?raw=true) | 顺摇推进，逆摇刹车，不倒退。 |
| Variation 4 | [Immediate velocity steering](downloads/sky-hamster-direct.zip?raw=true) | Crank position redirects existing velocity; A accelerates, release coasts. |
| Variation 4 | [即时速度转向](downloads/sky-hamster-direct.zip?raw=true) | 摇柄位置立即改变已有速度方向；A 加速，松开滑行。 |
| Variation 5 | [Reversal latch](downloads/sky-hamster-latch.zip?raw=true) | Comparison: high-force reversal clears propulsion. |
| Variation 5 | [反向清条](downloads/sky-hamster-latch.zip?raw=true) | 核心规则对照：高力度反向清空推进条。 |
| Variation 6 | [Reverse thrust](downloads/sky-hamster-reverse.zip?raw=true) | Reverse crank builds negative force, slowing then reversing. |
| Variation 6 | [反向推力](downloads/sky-hamster-reverse.zip?raw=true) | 逆摇建立负推力，先减速再倒退。 |
| Variation 7 | [Docking console](downloads/sky-hamster-track.zip?raw=true) | CONTROL auto-docks; hold A + crank to turn bridge; B releases. |
| Variation 7 | [吸附控制台](downloads/sky-hamster-track.zip?raw=true) | CONTROL 自动吸附停球，A + 摇柄旋桥，B 释放。 |
| Variation 8 | [Zero before turning](downloads/sky-hamster-lock.zip?raw=true) | Force must reach zero before direction changes. |
| Variation 8 | [归零才能转向](downloads/sky-hamster-lock.zip?raw=true) | 推进条归零才允许转向。 |

2026-09-22: old 4 (steering) and old 9 (absolute) retired, with source entries/downloads removed. New 4 uses the separate direct bundleID; others keep numbers. There is no current Variation 9; Git history retains old content.

2026-09-22：旧 4（steering）和旧 9（absolute）退役，源码入口及下载包移除；新玩法使用编号 4 和独立 direct bundleID。其他编号不变，当前没有 Variation 9。旧内容可从 Git 历史恢复。

### New Variation 4

### 新 Variation 4

Crank 0°/90°/180°/270° maps to screen up/right/down/left with corrected isometric projection. Even without A, turning immediately redirects existing velocity without losing speed. A accelerates; release coasts with rolling resistance. Gravity's component along the current direction affects speed. D-pad does not steer.

摇柄 0° 对应屏幕上、90° 右、180° 下、270° 左，已修正斜视投影。即使松开 A，摇柄转向也会立即转动已有速度向量。转向本身不损失速率；A 持续加速，松手不立即停止，但保留滚动阻力。坡道重力沿当前方向的分量影响速率。方向键不控制球。

### Variation 7

Within radius 22, the control point auto-docks/stops the ball without prior slowing. `DOCKED: hold A + crank to rotate.` requires A for bridge rotation; release A stays docked. B undocks without restart; crank clockwise/D-pad to leave. Beyond radius 30, docking rearms, allowing capture within 22 again. B inside release exclusion cannot retry; outside it retries normally, and system restart remains.

进入控制点半径 22 自动吸附到中心并停住，不要求事先减速。屏幕提示 `DOCKED: hold A + crank to rotate.`，必须按住 A 才能转桥，松开 A 仍停住。B 解除吸附，不重开关卡；顺摇推进、方向键离开。离开半径 30 后才重新启用吸附，之后进入半径 22 可再次吸附。释放区内再次按 B 不会触发重试；离开后 B 正常重试，系统菜单也可重新开始。

## Build, run, and install

## 构建、运行与安装

Set PLAYDATE_SDK_PATH here and run `bash build-variants.sh` (Windows: `./build-variants.ps1`). Eight packages output to builds/variants using the Lua SDK, without changing formal source.

在本目录设置 PLAYDATE_SDK_PATH，执行 `bash build-variants.sh`（Windows：`./build-variants.ps1`）。八个包输出到 builds/variants。只需 Lua SDK，不改正式源码。

Open .pdx in Simulator: S maps A and keyboard A maps B. A starts, B retries, system menu selects. With USB-connected unlocked hardware, choose Device → Upload Game to Device. Web Sideload accepts a single variant ZIP, not the entire collection.

模拟器打开 .pdx；S 对应 A，键盘 A 对应 B。A 开始，B 重试，系统菜单选关。USB 连接并解锁实机后，在模拟器选择 Device → Upload Game to Device。网页 Sideload 上传单版 ZIP，不要直接上传合集。

01–06 and 08 share short flat/optional slope courses. 07 uses a dedicated broken bridge, so times are not directly comparable. All disable jump/audio. See [playtest guidance](variants/README.md), [original reflections](../../docs/reflections/README.md), and [device record](device-variations.md).

01–06、08 使用相同短赛道与可选坡道；07 为专用断桥关，不能直接比较通关时间。全部关闭跳跃和声音。见 [试玩说明](variants/README.md)、[原始心路历程](../../docs/reflections/README.md)、[设备记录](device-variations.md)。

## Verification

## 验证

All eight compiled with SDK 3.1.1. Python + lupa test command:

八版通过 SDK 3.1.1 编译。Python + lupa 测试命令：

```sh
python tests/run_checks.py
python tests/check_variants.py
python tests/check_extra_variants.py
```

Coverage includes original regressions, alternate rules, new 4 steering without A/speed retention, 7 dock/stop/A-turn/B-release/rearm, and an actual-update bridge completion. Automated checks/device startup are not handling playtests.

覆盖原游戏回归、其他规则、新 4 无 A 即时转向与速率保持、7 吸附停球/A 旋桥/B 释放/离开再吸附以及真实 update 过桥通关。自动测试与设备启动不等于玩家手感测试。
