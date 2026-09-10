# 开发模板与许可核查

核查日期：2026-09-09。

## 模板提供了什么

项目起点是 [SquidGodDev/playdate-template](https://github.com/SquidGodDev/playdate-template)，本地初始提交为 `456b0987fa247611278069609fab4d6da552abea`。它主要提供 VS Code 构建、调试、Lua 补全配置，以及一个摇柄移动图形的演示。

当前 `source/main.lua` 已替换该演示的移动与绘图逻辑；`physics.lua`、`courses.lua`、`ui.lua`、`physics_tests.lua` 不在原模板文件树中。通用的 Playdate API 调用仍然存在。

当前 `.vscode/extensions.json`、`.vscode/launch.json`、`.vscode/tasks.json` 和 LuaCATS 的 `library/stub.lua` 与本地模板副本内容一致。仓库也保存了原模板 README，因此不能把整个仓库描述为没有第三方文件。

## 许可结论的范围

- 原仓库当前没有根目录许可证，也没有发现整个模板的明确商用授权或禁止商用声明。README 明确鼓励用它创建项目，但其中 MIT 许可说明针对附带的 notpeter/playdate-luacats，不能据此推断整个模板为 MIT。
- [GitHub 的许可说明](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)指出：公开可见不等于自动获得任意复制、修改或分发授权。因此，目前不能确认所有模板文件的商用再分发许可。
- LuaCATS 附带 MIT 许可，允许包括销售在内的使用，但需保留相应许可声明；它还附带 Playdate SDK 许可文件，应一并保留。具体范围以该组件的许可证为准。
- [Playdate SDK 许可](https://play.date/dev/sdk-license/)允许开发者拥有并分发所开发的程序。这支持在 itch.io 分发游戏，但不代替对其他第三方内容的授权核查。

## 对发布的实际影响

当前构建命令只把 `source` 编译为 `.pdx`，不会把 `.vscode` 编辑器配置和模板 README 打进游戏。分发游戏包与公开整个源码仓库，是两个不同的文件范围。

该游戏不依赖原模板演示才能运行。可以依据 Playdate SDK 和编辑器文档重新编写构建配置，继续保留游戏玩法。若要保留并分发许可未明确的模板文件，可向原作者确认授权；若选择替换，应真正替换相关内容，而不是只更改署名。本次仅核查和补充说明，未执行配置替换。
