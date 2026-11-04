[← Project home](../README.md) · [Journal index / 日志目录](JOURNAL.md)

> Archive metadata: first recorded Git author timestamp 2026-09-09T22:14:34-04:00. This dates the surviving record, not necessarily the original design work.
>
> 归档元数据：最早记录的 Git 作者时间为 2026-09-09T22:14:34-04:00。这是现存记录时间，不一定是原始设计发生时间。

> Historical record: rules, counts, tests, and pending work refer to this version, not the current release.
>
> 历史记录：规则、数量、测试与待办均对应当时版本，并非当前发布状态。

# v0.5.6 performance and input checks

# v0.5.6 性能与输入检查

## Problem and method

## 问题与方法

Sustained hardware play still paused, with reports of needing two initial direction presses. Short start-position tests do not cover camera motion, first slope occlusion, or longer-run spikes.

真机持续试玩仍有停顿，并反馈开局方向键像要按两次。此前短时起点测试不能覆盖移动相机、首次坡面遮挡或较长运行中的尖峰。

`tests/device_motion.lua` is appended only to a temporary diagnostic build. Every third frame it moves to the next static tile center while running actual update and changing camera/occlusion. Each scene has 180 frames including first, ordered whole-map 1/2/14 then chunked 1/2/14. This is rendering stress, not route completion or continuous physics movement. CPU is update time; frame intervals also include SDK display/scheduling.

`tests/device_motion.lua` 仅用于追加到临时诊断构建。每三帧移动到下一个静态地块中心，同时运行真实 update，持续改变相机与遮挡。各场景 180 帧，含第一帧；顺序为整图 1/2/14，再分块 1/2/14。它是渲染压力测试，不是玩家完成路线，也不是连续物理移动。CPU 时间为 update 耗时；帧间隔还包含 SDK 的显示与调度。

## Round one: Is chunking effective?

## 第一轮：先验证分块是否有效

|Cache<br>缓存|Course<br>关卡|Mean CPU ms<br>平均 CPU ms|Worst CPU ms<br>最慢 CPU ms|Updates over 33.33 ms<br>超过 33.33 ms 帧数|
|---|---:|---:|---:|---:|
| Whole map | 1 | 8.126 | 41.428 | 1 |
| 整图 | 1 | 8.126 | 41.428 | 1 |
| Whole map | 2 | 14.294 | 52.520 | 1 |
| 整图 | 2 | 14.294 | 52.520 | 1 |
| Whole map | 14 | 30.945 | 457.302 | 39 |
| 整图 | 14 | 30.945 | 457.302 | 39 |
| Chunked | 1 | 10.190 | 15.865 | 0 |
| 分块 | 1 | 10.190 | 15.865 | 0 |
| Chunked | 2 | 16.369 | 25.499 | 0 |
| 分块 | 2 | 16.369 | 25.499 | 0 |
| Chunked | 14 | 30.671 | 139.595 | 46 |
| 分块 | 14 | 30.671 | 139.595 | 46 |

The later chunk pass reused occlusion caches, so its smaller spikes cannot all be attributed to chunking. Course 14 had a visible tile-cache miss requiring immediate generation.

分块在后一轮复用了已有遮挡缓存，因此不能把尖峰较低全部归功于分块。第 14 关有一次可见图块缓存未命中，需要当帧生成图块。

## Round two: Prepare caches and cull distant machinery

## 第二轮：提前准备缓存，裁剪远处机关

Slope geometry/HUD prepare on entry. Offscreen draws skip with 32-pixel margins plus conservative rotation/wall/sign bounds. Mechanism timing, collision, and motion continue.

将坡面遮挡几何、HUD 缓存移至关卡准备阶段；屏幕外机关跳过绘制，保留 32 像素余量及考虑旋转、墙高和标牌的保守包围范围。机关的计时、碰撞和移动仍持续计算。

|Cache<br>缓存|Course<br>关卡|Mean CPU ms<br>平均 CPU ms|Worst CPU ms<br>最慢 CPU ms|Updates over 33.33 ms<br>超过 33.33 ms 帧数|Maximum interval ms<br>最大帧间隔 ms|
|---|---:|---:|---:|---:|---:|
| Whole map | 1 | 7.599 | 10.955 | 0 | 34.846 |
| 整图 | 1 | 7.599 | 10.955 | 0 | 34.846 |
| Whole map | 2 | 13.688 | 23.474 | 0 | 35.357 |
| 整图 | 2 | 13.688 | 23.474 | 0 | 35.357 |
| Whole map | 14 | 22.003 | 100.101 | 1 | 101.112 |
| 整图 | 14 | 22.003 | 100.101 | 1 | 101.112 |
| Chunked | 1 | 9.913 | 14.954 | 0 | 34.092 |
| 分块 | 1 | 9.913 | 14.954 | 0 | 34.092 |
| Chunked | 2 | 16.020 | 25.677 | 0 | 35.862 |
| 分块 | 2 | 16.020 | 25.677 | 0 | 35.862 |
| Chunked | 14 | 24.756 | 129.726 | 7 | 131.870 |
| 分块 | 14 | 24.756 | 129.726 | 7 | 131.870 |

Release therefore retains static whole-map caching: terrain generates once on entry, then one image translates while SDK clips outside pixels—not full-geometry redraw each frame. The 128-pixel chunks plus surrounding ring remain a disabled experiment.

因此发布配置继续使用静态整图缓存：地形只在进入关卡时生成一次，运行时通过一张缓存图平移显示，SDK 裁剪屏幕外像素；并非每帧重画全地图几何。128 像素分块、周边一圈预取的实现保留为实验，默认不启用。

## Round three: Longer Course 14 sample

## 第三轮：延长第 14 关采样

Whole-map 540 frames: mean 23.097 ms, worst 313.346, two above 33.33, maximum interval 321.094. Frame 31 took 33.520 near (113.2,176) with five occluders; frame 269 took 313.346 near (1233.1,80) with none. Slope occlusion alone cannot explain the latter; cause remained unknown.

整图模式 540 帧：平均 23.097 ms，最慢 313.346 ms，2 帧超过 33.33 ms，最大帧间隔 321.094 ms。第 31 帧 33.520 ms，球坐标约 (113.2,176)，有 5 个候选遮挡体；第 269 帧 313.346 ms，坐标约 (1233.1,80)，没有候选遮挡体。后者不能仅用坡面遮挡解释，原因尚未确定。

A planned all-idle-time GC comparison lost USB/COM4 before results, so that GC change stayed out of release and was not credited with fixing spikes. Repeated empty tables were removed in no-mechanism scenes; host regressions passed, final hardware retest pending.

尝试安排“利用全部帧内空闲时间回收垃圾”的后续对照，但 USB 连接中断，COM4 不再可用，未获得结果。因此该 GC 参数改动未纳入发布代码，不能声称它解决了尖峰。移除了无机关场景在循环中反复创建的空表；该小改动已过主机回归，仍待最终真机复测。

## Input and display

## 输入与显示

- Code confirmed tutorial close read/discarded crank input and returned. It now processes direction/crank that frame without an A jump.

- 代码确认：教学关闭帧原先读取并丢弃摇柄变化后直接返回；现同帧继续处理方向与摇柄，A 不同时触发跳跃。

- Regression: A + held Right + 90° crank moves immediately and continues next frame without another direction press.

- 自动回归：A + 持续右方向 + 90 度摇柄同帧开始移动；下一帧不再按一次方向也继续移动。

- Zero propulsion intentionally leaves D-pad without force. `Turn clockwise for POWER` explains still/low-force state without changing physics.

- 零推进力度下，方向键本身不驱动小球。静止且力度不足时显示 `Turn clockwise for POWER`，物理规则不变。

- Simulator found a long class label crowding speed; it became `ROLL`.

- 模拟器检查发现课堂 HUD 的长标签挤到速度数字，改为 `ROLL`。

- All 14 course loops, collision, jumps, platforms, and two class courses pass; both SDK builds pass.

- 完整 14 关主循环、碰撞、跳跃、移动平台和课堂两关回归通过。SDK 两种配置编译通过。

## Limits and follow-up

## 限制与后续

Early-course data uses full-game courses, not a sustained classroom-route test. Complex spikes remain; no independently reproduced catching-corner issue justifies collision changes. After reconnecting, run sustained class inputs, record locations, and profile long-course spikes.

本轮前两关数据来自完整版的相应关卡，不等同于课堂短路线的长时间真机测试。复杂关卡偶发卡顿尚未完全解决；“卡角”没有独立复现证据，不据此修改碰撞规则。下一步应在真机重新连接后进行课堂版持续操作测试，记录具体卡顿位置，并针对长关尖峰分段计时。
