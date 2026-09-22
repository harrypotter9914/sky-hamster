# 当前八版与历史安装记录

## 2026-09-22：替换转向方案与吸附控制台

- 旧 Variation 4（steering）和 9（absolute）从当前合集与设备 Games 目录移除，Mac 留有可恢复备份；其他游戏和存档目录未改。
- 新 Variation 4（direct）使用摇柄绝对屏幕方向，立即重定向已有速度；A 加速，松手滑行。独立 bundleID，experiment-1.1.0 / build 3。
- Variation 7（track）进入控制点自动吸附、停止；按住 A 才能转机关；B 释放；离开外圈后可重新吸附。沿用 track bundleID，experiment-1.1.0 / build 3。
- 八版重新编译、ZIP 校验通过；三组 Python/Lua 回归脚本通过。真实 update 测试覆盖即时转向、滑行、吸附/释放/再次进入以及过桥完成。
- 八个游戏均已复制到所连接 Playdate 的 Games 目录，并核对 main.pdz 和 pdxinfo 与本次构建一致。旧 4/9 不再位于 Games 中。新 4 和 7 已分别通过串口启动，返回三组启动 PASS。
- 模拟器已显示两个新版本；真机新 4 已进入游戏并通过 A 加速。7 通过串口按键与摇柄输入实际进入吸附，屏幕显示 HOLD A / DOCKED；按住 A 转桥、松开 A 继续停住，B 释放后显示 FREE / Leave CONTROL, then return to dock。已读取设备 framebuffer 核对这些画面；重新吸附和完整过桥由真实 update 自动测试覆盖。启动与这些交互检查不代表完整人工手感测试。

## 以下为 2026-09-19 的历史记录（旧九版，不是当前合集）

日期：2026-09-19。实验版本 experiment-1.0.1，buildNumber 2。

我希望九个控制方案统一用英文编号，方便在真机上逐个找到并对比。因此保留原有顺序和规则，将设备名称、引导页及 HUD 统一为 Variation 1–9，不改变控制机制。

| 名称 | 规则 | 内部标识 | 真机安装 / 启动 |
|---|---|---|---|
| Variation 1 | 目标速度 | speed | 通过 |
| Variation 2 | 持续油门 | throttle | 通过 |
| Variation 3 | 反摇刹车 | brake | 通过 |
| Variation 4 | 累计转角转向 | steering | 通过 |
| Variation 5 | 力度卡扣 | latch | 通过 |
| Variation 6 | 正反推力 | reverse | 通过 |
| Variation 7 | 手动转桥 | track | 通过 |
| Variation 8 | 方向锁定 | lock | 通过 |
| Variation 9 | 绝对角度转向 | absolute | 通过 |

九版均通过 SDK 构建；check_variants.py 和 check_extra_variants.py 全部通过，覆盖控制差异、惯性、重试、选关和手动桥通过等。每个包实际安装至同一台 Playdate，并逐一执行启动、读取串口，均返回三组启动 PASS。独立 bundleID 与 ZIP 完整性检查通过。没有进行九版手动通关或玩家手感测试，不能将启动通过视为完整试玩结果。原课堂版及完整版保持不变。

本轮下载包同步重建，文件名保留规则标识，设备中显示编号名称。
