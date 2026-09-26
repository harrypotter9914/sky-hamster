# Sky Hamster — v0.10.2

Playdate 单人控球原型，Lua 编写。游戏设计：Wang Yibo。

当前完整版延续原有版本序列：**0.6.7 → 0.7.x → 0.8.0 → 0.9.0 → 0.10.2**。倾斜操控是同一款游戏的后续迭代，不再单独从 0.1 编号。完整对应表见 [版本总表](docs/VERSIONS.md)。

当前包含 44 关：倾斜控球、抬机跳跃、摇柄操控机关、炮台及综合长关，包含标题、设置、教学、选关、检查点和结算循环。最新源码位于 [experiments/tilt-adventure](experiments/tilt-adventure/README.md)，保留原目录和存档标识以兼容已有构建与真机存档。

构建当前完整版：

```powershell
./experiments/tilt-adventure/build.ps1
```

输出为 `builds/sky-hamster-tilt.pdx`。当前设计记录见 [完整版设计心路历程](experiments/tilt-adventure/REFLECTION.md)。后续修复从 0.10.3 继续，新增一批玩法时升至 0.11.0。

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
