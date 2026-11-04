[← Project home](../README.md) · [Journal index / 日志目录](JOURNAL.md)

> Historical record: rules, counts, tests, and pending work refer to this version, not the current release.
>
> 历史记录：规则、数量、测试与待办均对应当时版本，并非当前发布状态。

# 0.5.4 performance record

# 0.5.4 性能测试记录

Device: this USB-connected Playdate (COM4). Host comparison: Python / Lua 5.4. Target: 30 FPS.

设备：本次 USB 连接的 Playdate（COM4）。主机对照：Python / Lua 5.4。目标刷新率：30 FPS。

## First compare occlusion calculation

## 我先比较了遮挡计算

Same device/positions, old logic from released v0.5.3. Each scene repeats ten times; values are means per invocation including initial cache creation, not whole-frame or completion FPS.

同一设备、同一组位置，旧逻辑来自已发布的 v0.5.3。每种场景重复 10 次，表内是每次平均耗时，包含初次缓存建立。它不是整帧耗时或通关帧率。

|Scene<br>场景|Old logic<br>旧逻辑|Initial caching<br>第一轮缓存|Round 2: polygon masks<br>第二轮：多边形遮罩|
| --- | ---: | ---: | ---: |
| Long-course flat ground | 527.963 ms | 15.397 ms | 17.177 ms |
| 长关平地 | 527.963 ms | 15.397 ms | 17.177 ms |
| Behind barrier | 598.872 ms | 60.000 ms | 10.965 ms |
| 挡板后 | 598.872 ms | 60.000 ms | 10.965 ms |
| Low-jump platform edge | 291.232 ms | 119.651 ms | 12.561 ms |
| 低跳平台边缘 | 291.232 ms | 119.651 ms | 12.561 ms |

Rerunning old logic in round two gave 544.673 / 603.501 / 308.993 ms, showing variation. New logic includes native polygon drawing; old comparison excludes its pixel-by-pixel SDK reads. Ratios cannot be called whole-game speedups.

第二轮重新运行的旧逻辑分别为 544.673 / 603.501 / 308.993 ms，说明不同轮次会有波动。第二轮新逻辑还包含原生多边形绘制；旧逻辑的比较没有包含旧版每像素 SDK 图像读取，因此不能把比值直接换算为游戏整体提速倍数。

## Then compare complete updates

## 我再比较了完整更新流程

At fixed positions, warm ten frames then measure 100. These are short automated scenes, not manual completion. CPU measures Lua update; FPS uses actual frame intervals.

固定测试位置，每个场景先运行 10 帧，再测量 100 帧；这是短时自动场景，不是完整人工通关。CPU 指 Lua update 执行耗时，FPS 由帧间实际时间计算。

|Scene<br>场景|After polygon masks FPS<br>多边形遮罩后 FPS|After track caching FPS<br>静态赛道缓存后 FPS|
| --- | ---: | ---: |
| 14 Long-course start | 23.05 | 28.93 |
| 14 长关起点 | 23.05 | 28.93 |
| 08 Near barrier | 24.63 | 27.11 |
| 08 挡板附近 | 24.63 | 27.11 |
| 11 Outer rotating-platform end | 27.50 | 30.08 |
| 11 旋转平台外端 | 27.50 | 30.08 |

These results led to more HUD caching and removal of unnecessary static-occlusion filtering. Final results follow.

这些结果促使我继续缓存 HUD，减少无意义的静态遮挡筛选。最终结果将记录在下方。

## Finally check each course on hardware

## 我最后逐关检查了真机

Update 60 frames from each start, discard ten and measure 50; separately sample Course 8's barrier and Course 11's outer platform. Short windows/timing differences can estimate slightly above the 30 target.

每关从起点正常更新 60 帧，舍弃前 10 帧，统计后 50 帧；另测第 8 关挡板附近和第 11 关旋转平台外端。短窗口及计时差异会使估算 FPS 略高于目标 30。

|Scene<br>场景|Mean update<br>平均 update|Worst update<br>最大 update|FPS<br>FPS|
| --- | ---: | ---: | ---: |
| 01 | 7.387 ms | 8.609 ms | 30.30 |
| 01 | 7.387 ms | 8.609 ms | 30.30 |
| 02 | 20.441 ms | 26.255 ms | 30.42 |
| 02 | 20.441 ms | 26.255 ms | 30.42 |
| 03 | 21.172 ms | 26.207 ms | 30.36 |
| 03 | 21.172 ms | 26.207 ms | 30.36 |
| 04 | 18.323 ms | 25.723 ms | 30.50 |
| 04 | 18.323 ms | 25.723 ms | 30.50 |
| 05 | 7.411 ms | 8.658 ms | 30.32 |
| 05 | 7.411 ms | 8.658 ms | 30.32 |
| 06 | 7.390 ms | 8.720 ms | 30.31 |
| 06 | 7.390 ms | 8.720 ms | 30.31 |
| 07 | 7.445 ms | 8.705 ms | 30.30 |
| 07 | 7.445 ms | 8.705 ms | 30.30 |
| 08 | 13.408 ms | 15.450 ms | 30.26 |
| 08 | 13.408 ms | 15.450 ms | 30.26 |
| 09 | 13.054 ms | 15.331 ms | 30.30 |
| 09 | 13.054 ms | 15.331 ms | 30.30 |
| 10 | 10.695 ms | 11.784 ms | 30.30 |
| 10 | 10.695 ms | 11.784 ms | 30.30 |
| 11 | 10.744 ms | 12.421 ms | 30.28 |
| 11 | 10.744 ms | 12.421 ms | 30.28 |
| 12 | 18.190 ms | 20.212 ms | 30.31 |
| 12 | 18.190 ms | 20.212 ms | 30.31 |
| 13 | 29.191 ms | 36.451 ms | 29.94 |
| 13 | 29.191 ms | 36.451 ms | 29.94 |
| 14 | 22.334 ms | 24.445 ms | 30.30 |
| 14 | 22.334 ms | 24.445 ms | 30.30 |
| 08 Near barrier | 17.774 ms | 19.703 ms | 30.30 |
| 08 挡板附近 | 17.774 ms | 19.703 ms | 30.30 |
| 11 Outer rotating-platform end | 11.465 ms | 13.046 ms | 30.30 |
| 11 旋转平台外端 | 11.465 ms | 13.046 ms | 30.30 |

Remaining: Course 13 had an update over budget. Short tests cannot prove every complete route, jump state, or long session avoids drops. Entry cache construction is excluded from these steady-state statistics.

我记录的剩余问题：第 13 关有单次更新超过目标帧预算；本轮短测不能证明完整通关、所有跳跃状态和长时间运行都不会掉帧。进入关卡时构建缓存的开销不包含在这些稳定阶段统计中。

## Check that optimization preserved appearance

## 我怎样检查效果没有被优化破坏

- Compare old rays/new polygon regions across flats, slopes, front/back walls, low jumps, rotating platforms, and times. SDK edge rasterization may round differently.

- 对比旧射线结果和新的多边形区域，覆盖平地、坡道、墙前后、低空跳跃、旋转平台及多个时间点；边界像素由 SDK 栅格化，允许边缘取整差异。

- Run all 14 real course update paths, checking selection, pause, jumps, sides, landings, riding, and finish.

- 运行 14 关的真实更新流程，检查选关、暂停、跳跃、撞边、落地、平台载球与终点。

- Hardware diagnostic builds measure only and are not distributed game packages.

- 真机上的诊断构建只用于测量，不包含在发布的游戏包中。
