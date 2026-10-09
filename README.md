# Sky Hamster — v0.12.8

Playdate 单人控球原型，Lua 编写。游戏设计：Wang Yibo。

公开测试版已发布：[itch.io — Sky Hamster](https://hajimi9914.itch.io/sky-hamster)，免费，可自愿打赏。当前下载版本为 0.12.8；页面素材、说明和下载校验见 [发布记录](release/itch-v0.12.8/PUBLICATION.md)。

当前完整版延续原有版本序列：**0.6.7 → 0.7.x → 0.8.0 → 0.9.0 → 0.10.x → 0.11.0 → 0.12.x**。倾斜操控是同一款游戏的后续迭代，不再单独从 0.1 编号。完整对应表见 [版本总表](docs/VERSIONS.md)。

0.12.8 新游戏在目标介绍后选择操控，默认 Road，确认后提示可随时在设置更改；继续／新游戏使用独立生成的横版按钮。加入生成素材的操控对照动画页、首页继续／新游戏选择和按通关解锁的选关；临时开发入口与普通进度隔离。仍为完整 53 关，适合公开测试，复杂关加载及掉帧限制见 [发布核查](docs/RELEASE-READINESS-v0.12.8.md) 和 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.12.8.md)。

0.12.7 将 Mac 试玩版中的 Settings → Start New Game 正式补进主线：确认后重置进度、最佳成绩与教程记录，从第一关重看指引；保留音效、音乐和操作偏好。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.7.md)。

0.12.6 将加速恢复到接近 0.12.4，只保留轻微的小角度细化；满推力不再需要过度倾斜。增强反向刹车、两种方向模式及中立收速保留。见 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.12.6.md)。

0.12.5 根据陌生人试玩反馈调整倾斜手感：小幅度输入更细腻、反向倾斜辅助刹车、中立后更快收速；设置新增 Screen／Road 两种方向模式，并同步箭头和教学。增加低对比远景云层。见 [试玩反馈与验证](experiments/tilt-adventure/VALIDATION-v0.12.5.md)。

0.12.4 风场覆盖整段路宽，磁场扩大有效边缘、连续检测高速穿越；旋转风机改为顺风爬坡，增加 GO／WAIT 与地面方向提示。保留渐进加速和反向倾斜控制。见 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.12.4.md)。

0.12.3 审查全部 53 关，重做 19 个累计复习关、调整 5 个专项教学关和四个终局关。最终三关分别有 6／6／10 门大炮，加入斜向落点、可刹车的接收台、水平折返平台及分路组合；保留稳定关卡身份与已有进度，改图关卡的旧最佳时间清除。见 [关卡检查与处置表](experiments/tilt-adventure/CAMPAIGN-v0.12.3.md) 和 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.12.3.md)。

0.12.x 将关卡重排为 20 个教学阶段与四个全机制远征，共 53 关。每阶段先教学，再累计复习此前机制；最后四关有 21、23、25、28 段挑战。0.12.2 提前打包固定道路、大炮和风机图片，并按相机位置逐步准备长关道路区块，缩短进关等待；碰撞地图先完整就绪。接岸、遮挡候选、远处控制点与声音查询使用索引，保留原有画面和玩法。见 [完整顺序表](experiments/tilt-adventure/CAMPAIGN-v0.12.0.md) 和 [0.12.2 验证](experiments/tilt-adventure/VALIDATION-v0.12.2.md)。

0.11.0 增加按小球圆形占地判断的接缝容错，以及接岸口、闸门、消失地板、移动挡板和喷气口的 GO／WAIT 提示。增加四关板上转台与双控制点路线；风力增加 8%，快速穿越风区也受到作用。见 [设计与验证](experiments/tilt-adventure/VALIDATION-v0.11.0.md)。

0.10.12 将竖直弹簧替换为低矮圆形弹力护圈，统一底座、碰撞与遮挡，增加触碰后外扩回弹动画。见 [接触位置与动画验证](experiments/tilt-adventure/VALIDATION-v0.10.12.md)。

0.10.11 修复弹簧擦边时反弹不明显及背面遮挡缺失，补充风机、炮台等实体轮廓和平台侧面遮挡。见 [方向／动画审查与验证](experiments/tilt-adventure/VALIDATION-v0.10.11.md)。

0.10.10 将顶部状态栏整理为机械仪表板，增加统一像素图标、关卡牌、分段刻度和等宽数字。所有信息保留，底部操作栏与游戏画面尺寸不变。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.10.md)。

0.10.9 增加 USB 供电时保持唤醒，并针对全关卡真机复测优化物理查询、固定支撑和操作提示缓存。复测数据与范围见 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.10.9.md)。

0.10.8 修正机关近端与前景道路的绘制顺序，升降台改用留空支撑。炮管按立体圆筒投影，炮口、预瞄线和发射位置统一，风机机头也随风向转动。详见 [本轮验证](experiments/tilt-adventure/VALIDATION-v0.10.8.md)。

当前包含 53 关：倾斜控球、抬机跳跃、摇柄操控机关、炮台、板上转台及综合长关，包含标题、设置、教学、选关、检查点和结算循环。最新源码位于 [experiments/tilt-adventure](experiments/tilt-adventure/README.md)，保留原目录和存档标识，按关卡 ID 迁移已有进度。

构建当前完整版：

```powershell
./experiments/tilt-adventure/build.ps1
```

输出为 `builds/sky-hamster-tilt.pdx`。真机更新执行 `./experiments/tilt-adventure/install.ps1`，始终覆盖同一个安装目录；历史 ZIP 只放在电脑和 GitHub。修改地图或相关绘制代码后，按 [预生成流程](experiments/tilt-adventure/art/RUNTIME-v0.12.2.md) 更新资源。当前设计记录见 [完整版设计心路历程](experiments/tilt-adventure/REFLECTION.md)。后续修复从 0.12.8 继续。

## 0.6.7 及课堂版归档

以下为旧操控版本的说明；根目录 `source/` 和 `build.ps1` 保留用于复现这一历史版本。

9 月 10 日课堂请使用已安装的 **Sky Hamster Core Test 0.5.8-core**，包含边缘掉落修复，只测试推进与惯性。完整版 0.6.0 新增声音、独立开始画面和失败重试界面。`./build.ps1 -Classroom` 仍可生成关闭这些功能、排除音频资产的课堂配置。见 [课堂试玩计划](docs/classroom-playtest.md)。

当前共 14 关：前四关练习滚动，第五关引入跳跃，第八关起介绍定时挡板、开合地板、移动平台和旋转地板，最后两关组合多种机制。方向键控制推进方向，顺摇增加 POWER，逆摇增加 JUMP，A 跳跃，B 重试；系统菜单提供分页选关和暂停地图。

完整版从独立标题菜单进入；音效和音乐可分别开关，系统菜单的 Title / sound 可返回设置。掉落失败后 A 从起点或检查点重试，B 选关。课堂配置没有声音、标题菜单或失败面板，继续自动重试。

## 构建
安装 Playdate SDK，并配置 PLAYDATE_SDK_PATH。使用 SDK 的 pdc 编译：

```powershell
& "$env:PLAYDATE_SDK_PATH/bin/pdc.exe" source builds/sky-hamster.pdx
```

用 Playdate Simulator 打开构建的 .pdx。

## 版本记录的真实性
这些 Git 提交是在归档时建立的，提交时间不是原始开发时间。0.1 与 0.4 有原始源码快照；0.2 与 0.3 是依据代码与对话记录重建的可运行比较版本。不能把重建版本当作当时逐字保留的代码。

## 设计心路历程

每个版本的设计思考、方案取舍和修改原因见 [心路历程目录](docs/reflections/README.md)。
