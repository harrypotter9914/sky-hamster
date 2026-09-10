# Sky Hamster — v0.4.1

Playdate 单人控球原型，Lua 编写。设计：Wang Yibo；AI 辅助实现。

当前原始 source 快照：前四关关闭跳跃，第五关起引入跳跃；新增选关界面、教学提示、清晰 POWER/JUMP 条、架高标牌和地图标记。

## 构建
安装 Playdate SDK，并配置 PLAYDATE_SDK_PATH。使用 SDK 的 pdc 编译：

```powershell
& "$env:PLAYDATE_SDK_PATH/bin/pdc.exe" source builds/sky-hamster.pdx
```

用 Playdate Simulator 打开构建的 .pdx。编辑器配置来自 SquidGodDev 模板，见 ATTRIBUTION.md。

## 版本记录的真实性
这些 Git 提交是在归档时建立的，提交时间不是原始开发时间。0.1 与 0.4 有原始源码快照；0.2 与 0.3 是依据代码与对话记录重建的可运行比较版本。不能把重建版本当作当时逐字保留的代码。

## 设计心路历程

每个版本的设计思考、方案取舍和修改原因见 [心路历程目录](docs/reflections/README.md)。
