# Variation 1–9：编号与真机安装记录

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
