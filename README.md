# Sky Hamster — v0.5.7

Playdate 单人控球原型，Lua 编写。游戏设计：Wang Yibo。

9 月 10 日课堂请使用 **Sky Hamster Core Test**，只测试短路线中的推进与惯性。运行 `./build.ps1 -Classroom` 构建；下述默认工程仍保留完整版。见 [课堂试玩计划](docs/classroom-playtest.md)。

当前共 14 关：前四关练习滚动，第五关引入跳跃，第八关起介绍定时挡板、开合地板、移动平台和旋转地板，最后两关组合多种机制。方向键控制推进方向，顺摇增加 POWER，逆摇增加 JUMP，A 跳跃，B 重试；系统菜单提供分页选关和暂停地图。

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
