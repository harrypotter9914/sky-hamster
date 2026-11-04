[← Project home](../README.md) · [Journal index / 日志目录](JOURNAL.md)

> Archive metadata: first recorded Git author timestamp 2026-09-09T22:56:35-04:00. This dates the surviving record, not necessarily the original design work.
>
> 归档元数据：最早记录的 Git 作者时间为 2026-09-09T22:56:35-04:00。这是现存记录时间，不一定是原始设计发生时间。

> Historical record: rules, counts, tests, and pending work refer to this version, not the current release.
>
> 历史记录：规则、数量、测试与待办均对应当时版本，并非当前发布状态。

# v0.5.7 hardware stutter diagnosis

# v0.5.7 真机卡顿定位记录

## 1. Restore connection

## 1. 恢复连接

Windows showed healthy COM4 but opening returned Access denied; pdutil install/data-disk commands failed. Closing Simulator immediately restored installation. This fits connection contention, not an unplugged device.

Windows 可见 COM4，状态正常，但打开串口报 Access denied；pdutil 的安装和数据盘命令失败。关闭 Playdate Simulator 后安装立即成功。此次故障与模拟器占用连接相符，不应归咎于没有插线。

## 2. Segmented timing points to collection

## 2. 分段计时定位集中回收

`tests/prepare_profile.py` adds eight temporary timing points: input/physics, terrain, machinery/shadows, markers, ball, occlusion filtering, mask drawing, HUD. Diagnostics never enter release.

`tests/prepare_profile.py` 在临时副本加入 8 个计时点，依次分开输入/物理、地形、机关/影子、标记、球绘制、遮挡筛选、遮罩绘制、HUD。诊断代码不进入发布包。

Course 14 camera scans tile centers for 600 frames per mode. Default GC had two spikes:

第 14 关相机扫过地块中心，各模式 600 帧。默认 GC 策略两次尖峰：

|Frame<br>帧|Update ms<br>更新 ms|Input/physics ms<br>输入/物理段 ms|Same-frame Lua memory change KB<br>同帧 Lua 内存变化 KB|
|---|---:|---:|---:|
| 277 | 312.285 | 297.00 | -484.1 |
| 277 | 312.285 | 297.00 | -484.1 |
| 547 | 263.058 | 243.10 | -370.1 |
| 547 | 263.058 | 243.10 | -370.1 |

Long pauses with large memory releases support bulk GC, not merely heavy terrain drawing. Default mean/worst: 24.068/312.285 ms. `playdate.setGCScaling(0,0)` comparison: 23.727/32.810, no update over 33.33, but maximum interval 43.259 ms.

突发耗时同时伴随大量内存释放，支持集中垃圾回收是主要原因，而不是该帧单纯绘制了很多地形。默认策略平均 24.068 ms、最慢 312.285 ms；使用 `playdate.setGCScaling(0,0)` 的对照平均 23.727 ms、最慢 32.810 ms，没有超过 33.33 ms 的更新，但最大帧间隔为 43.259 ms。

## 3. Cull before constructing occluders

## 3. 遮挡体提前剔除

Offscreen machinery previously still created volumes, corners, and temporary tables. Conservative projected bounds covering rotation now reject impossible overlap before precision work; stationary machinery reuses data.

屏幕外机关之前虽然不画，遮挡流程仍可能构造其体积、角点和临时表。现在先用涵盖旋转姿态的保守投影范围判断是否可能遮住球，再做精确计算；静止机关复用数据。

Same 600-frame retest: default GC mean/worst 21.761/32.487 ms; idle GC 22.512/31.540, neither over 33.33. Idle GC maximum display interval 44.558 ms shows update time alone is not presentation cadence.

同样的 600 帧扫图复测：默认 GC 平均 21.761 ms、最慢 32.487 ms；空闲时间 GC 平均 22.512 ms、最慢 31.540 ms。两轮均无超过 33.33 ms 的更新。空闲 GC 轮最大帧间隔 44.558 ms，不能只用 update 耗时代表完整呈现节奏。

## 4. Sustained input reveals omissions

## 4. 持续输入揭示遗漏

`tests/device_soak.lua` replaces only buttons/crank in actual update, not ball position. Full Courses 13/14 then class each run 450 frames, including both crank directions, turns, jumps, and periodic retries. This is not auto-completion or full-route coverage.

`tests/device_soak.lua` 使用真实 update，仅替换按钮与摇柄输入；不逐帧传送球。顺序为完整版第 13、14 关和课堂短关，各 450 帧，包含顺摇、逆摇、转向、跳跃和周期性重试。该脚本不是自动通关，也不覆盖完整路线。

First worst updates were 323.308/41.647/17.963 ms, showing GC/filtering alone insufficient. Eight initial crank degrees gave POWER 0.0222, below flat friction, so moved=false despite received input. Later 90° verifies same-frame movement without physics changes.

第一轮第 13 关最慢 323.308 ms，第 14 关 41.647 ms，课堂 17.963 ms。证明仅调整 GC 和机关筛选仍不充分。该轮开局只给 8 度摇柄，POWER 为 0.0222，低于克服平地摩擦所需力度，因此报告 moved=false；输入实际上已经收到。后续改为 90 度以明确验证同帧移动，未更改游戏物理。

More timing found Course 13 frame 255 at 267.828 ms, input/physics 250.65, memory down 313.2 KB. Mask stages at frames 292/293 took 22.22/21.01 ms. Collection remained, with expensive nearby barrier masks too.

再加计时点后，第 13 关第 255 帧出现 267.828 ms 更新，其中输入/物理段 250.65 ms，Lua 内存减少 313.2 KB；第 292、293 帧遮罩段分别 22.22、21.01 ms。仍有垃圾回收问题，且靠近挡板的遮罩本身开销较大。

## 5. Reuse polygon workspaces

## 5. 复用遮挡多边形工作区

Vertices, intersections, sort lists, hulls, output, and closures repeatedly allocated. Fixed eight-volume vertices, up-to-20-point workspace, shared edges, and hull lists now reuse data. Main-loop callers supply output buffers; callers without one still receive independent results.

原实现每次构造顶点、裁剪交点、排序列表、凸包、输出和若干闭包；多个遮挡体会反复产生临时对象。改为固定的 8 个体积顶点、最多 20 个点的工作区、共享边表与凸包工作列表。主游戏循环提供复用输出缓冲区；未提供缓冲区的调用者仍得到独立结果。

Host comparisons against old reference rays cover static slopes, barriers, moving/rotating platforms, times, four sides, and three heights. Visibility matches. With Lua GC paused, 1,000 buffered calls grow 0.00 KB—Lua allocation evidence, not device total memory or FPS.

主机检查对比旧版参考射线算法，覆盖静态坡面、挡板、移动平台、旋转平台、多个时刻、四侧及三种高度。所有可见性结果一致。暂停主机 Lua GC 后重复 1000 次带缓冲区调用，内存增长 0.00 KB。此数字验证 Lua 分配变化，不是设备总内存或 FPS。

## 6. Final hardware retest

## 6. 最终真机复测

The same sustained-input/timing procedure runs 450 frames per scene.

使用带计时点的持续输入测试；与上一轮相同流程，每场景 450 帧。

|Scene<br>场景|Mean update ms<br>平均更新 ms|Worst update ms<br>最慢更新 ms|Updates >33.33 ms<br>更新 >33.33 ms|Maximum interval ms<br>最大帧间隔 ms|Intervals >40 ms<br>帧间隔 >40 ms|FPS<br>FPS|
|---|---:|---:|---:|---:|---:|---:|
| Course 13 | 21.816 | 32.083 | 0 | 37.637 | 0 | 30.25 |
| 第 13 关 | 21.816 | 32.083 | 0 | 37.637 | 0 | 30.25 |
| Course 14 | 17.354 | 28.418 | 0 | 36.636 | 0 | 30.33 |
| 第 14 关 | 17.354 | 28.418 | 0 | 36.636 | 0 | 30.33 |
| Short classroom route | 8.363 | 14.442 | 0 | 34.607 | 0 | 30.34 |
| 课堂短关 | 8.363 | 14.442 | 0 | 34.607 | 0 | 30.34 |

Class first frame A + Right + 90° gives moved=true, POWER=0.25. Two falls per scene show retry paths were exercised. Former hundred-millisecond spikes did not recur in this pass.

课堂第一帧 A + 右方向 + 90 度摇柄：moved=true，POWER=0.25。每个场景记录到两次掉落，说明测试包含掉落与重试路径。此前数百毫秒尖峰在这一轮未复现。

## Verification boundaries

## 验证边界

Full host regressions, reference occlusion, reuse-memory checks, and both SDK builds passed. About 45 seconds of hardware covers three scenes/scripted inputs, not all-course human completion or hours of stability. Future stutters need course/position/action reproduction; average FPS must not dismiss player experience.

通过完整主机回归、遮挡参考对照、复用内存检查、SDK 两种配置编译。真机记录约 45 秒，覆盖三个指定场景及脚本操作；并非全关卡人工通关或数小时稳定性保证。若后续发现特定路线仍卡，应记录关卡、位置与动作再复现，不以平均 FPS 否定玩家感受。

Final full/class builds installed/launched with startup PASS logs. At completion, hardware ran classroom `/Games/sky-hamster-core-v0.5.7.pdx`.

最终构建的完整版本和课堂版本均安装成功，分别发送启动命令并读到启动检查通过日志；完成时真机运行课堂版 `/Games/sky-hamster-core-v0.5.7.pdx`。
