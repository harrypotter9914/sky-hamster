# Sky Hamster 控制规则实验合集

用于 GAMEDSGN 530 设计变体探索与对比试玩。这里是独立实验区，不是正式游戏的新版本；仓库根目录的正式游戏保持不变。

基于 v0.6.7 及设计心路历程重新制作。原型不是历史版本原件，也不能作为已完成玩家测试的证据。设计：Wang Yibo；代码、打包与自动测试由 AI 辅助完成。

## 下载九个变体

[下载全部九版 ZIP](downloads/sky-hamster-nine-variants.zip?raw=true)。解压后会得到九个独立 `.pdx` 游戏文件夹。

| 编号 | 独立下载 | 规则 |
| --- | --- | --- |
| Variation 1 | [目标速度](downloads/sky-hamster-speed.zip?raw=true) | 摇柄设定目标速度，方向键控制方向。 |
| Variation 2 | [持续油门](downloads/sky-hamster-throttle.zip?raw=true) | 停摇仍保持推力，反方向有额外刹车。 |
| Variation 3 | [反摇刹车](downloads/sky-hamster-brake.zip?raw=true) | 顺摇推进，逆摇主动刹车，不倒退。 |
| Variation 4 | [累计转角转向](downloads/sky-hamster-steering.zip?raw=true) | 摇柄累计转动改变方向；按住 A 推进，松手滑行。 |
| Variation 5 | [反向清条](downloads/sky-hamster-latch.zip?raw=true) | 当前核心规则对照：高力度反向清空推进条。 |
| Variation 6 | [反向推力](downloads/sky-hamster-reverse.zip?raw=true) | 逆摇建立反向推力，可先减速再倒退。 |
| Variation 7 | [手动旋转轨道](downloads/sky-hamster-track.zip?raw=true) | 停到 CONTROL，按住 A 转摇柄接桥，再滚过去。 |
| Variation 8 | [归零才能转向](downloads/sky-hamster-lock.zip?raw=true) | 推进条有力时锁定方向，归零后才能换方向。 |
| Variation 9 | [绝对位置转向](downloads/sky-hamster-absolute.zip?raw=true) | 摇柄位置决定推力方向；按住 A 加速，松开保留惯性。 |

第 09 版松手不会立即停止，转动摇柄也不会凭空改变已有惯性；重新按 A 后，推力逐渐改变球的运动。04 每次重试重置朝向，09 保持绝对位置映射。

## 运行与实机安装

- 模拟器：解压 ZIP，用 Playdate Simulator 打开某个 `.pdx`。A 开始，B 重试，系统菜单选关。
- 实机：通过 USB 数据线连接并解锁 Playdate，在模拟器打开该游戏，再选择 Device → Upload Game to Device。九个 bundleID 不同，可同时安装。
- 网页侧载：使用 Playdate 账户的 Sideload 页面上传单个版本 ZIP；全九版合集需要先解压，再使用其中单个游戏或本页的单版 ZIP。

01–06、08–09 使用相同短赛道与可选坡道；07 是专用断桥关，通关时间不宜直接与其他版本比较。全部关闭跳跃和声音，聚焦控制规则。

## 源码与构建

本目录自带 `source/`、`variants/` 和构建脚本。在本目录设置 `PLAYDATE_SDK_PATH` 后执行：

```sh
bash build-variants.sh
```

生成的九个包位于 `builds/variants/`。构建脚本在临时目录组合各版配置，不改写正式游戏或公共源配置。实验仅需 Lua SDK；Mac/Linux 可使用此脚本。

详细历史来源、操作说明、比较问题与试玩表见 [实验说明](variants/README.md)。原始设计记录位于仓库的 [心路历程](../../docs/reflections/README.md)。

## 验证范围

九版通过 Playdate SDK 3.1.1 编译。已有五版与新增四版的规则测试通过，包含松手惯性、反向推力、方向锁定、手动桥接通和真实 update 流程通关；完整游戏原有回归测试也通过。已逐版检查模拟器启动画面。

真机安装与启动检查见 [编号与安装记录](device-variations.md)。启动检查不等于真实玩家对比测试，相关预测不能写成已获得的结果。

测试需要 Python 与 `lupa`：

```sh
python tests/run_checks.py
python tests/check_variants.py
python tests/check_extra_variants.py
```

Windows 构建：设置 `PLAYDATE_SDK_PATH` 后运行 `./build-variants.ps1`。设备列表、引导页和游戏 HUD 统一显示 Variation 1–9；内部规则标识与独立 bundleID 保留，方便追踪。
