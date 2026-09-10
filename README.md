# Sky Hamster — v0.2.0

Playdate 单人控球原型，Lua 编写。设计：Wang Yibo；AI 辅助实现。

重建版本（不是当时完整快照）：目标速度改为持续推进力度；重力独立于油门；四个坡道/转弯测试关；保留强反向刹车。为重现历史行为使用了兼容适配代码，不能视为逐字还原。

## 构建
安装 Playdate SDK，并配置 PLAYDATE_SDK_PATH。使用 SDK 的 pdc 编译：

```powershell
& "$env:PLAYDATE_SDK_PATH/bin/pdc.exe" source builds/sky-hamster.pdx
```

用 Playdate Simulator 打开构建的 .pdx。编辑器配置来自 SquidGodDev 模板，见 ATTRIBUTION.md。

## 版本记录的真实性
这些 Git 提交是在归档时建立的，提交时间不是原始开发时间。0.1 与 0.4 有原始源码快照；0.2 与 0.3 是依据代码与对话记录重建的可运行比较版本。不能把重建版本当作当时逐字保留的代码。
