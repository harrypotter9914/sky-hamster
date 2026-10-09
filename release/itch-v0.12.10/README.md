# 0.12.10 · 首次按键教学更新

游戏包：`../../builds/sky-hamster-v0.12.10.zip`，单一顶层 `sky-hamster-tilt.pdx`。可直接上传 Playdate Sideload；也可解压后用 SDK Simulator 打开 `.pdx`。完整 53 关，版本 0.12.10 / build 60。

首次目标、操控选择和移动之后，新增四页生成图示和真实试用：↑ Map 暂停查路线，← Help 重播当前关教学，→ Go 查看目标与路线提示，↓ Recenter 用稳定新握姿重设中立。返回原教学位置，A 可以直接继续。跳跃动画补充 A 备用方式；炮台中 A 仍为发射。

本轮原生检查先通过模拟器，再通过物理 Playdate。两端各 17 张截图严格解码并检查，首次说明行碰分隔线的问题修正后复测。真机正式包与本地构建逐文件一致，ZIP 解包字节一致，原存档和设备错误日志未改变。临时检查文件已归档清理，最终正式首页启动 PASS／READY 已记录。

本轮未更新 itch.io 下载，公开页面仍提供 0.12.9；本地新包和 GitHub 源码为 0.12.10，不能将两者混称同一下载版本。公开页面的既有操作表与 A 备用说明仍有效。后续更新下载时应使用本文件所列的新 ZIP，并同步页面版本。

范围、记录和生成图出处见 `../../experiments/tilt-adventure/VALIDATION-v0.12.10.md`、`hardware/`、`simulator/`、`../../experiments/tilt-adventure/art/tutorial-v0.12.10/`。本轮不改变关卡／手感，不声称重新测了全部 53 关帧率或完成真人逐关通关。
