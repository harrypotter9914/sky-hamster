# Development Journal / 开发日志

[← Project home](../README.md) · [Version table / 版本总表](VERSIONS.md) · [Changelog / 更新记录](../CHANGELOG.md)

**Current game: Sky Hamster v0.12.12, build 62, 53 courses.** Read the present design on the homepage; these records preserve the decisions that led there.

**当前游戏：Sky Hamster v0.12.12，build 62，53 关。** 首页介绍现行设计；这些记录保留走到当前版本的决定。

English precedes the corresponding Chinese paragraph, list item, or table row. Original Chinese experience, uncertainty, numbers, code, and paths remain. Existing file addresses are retained.

英文在对应的中文段落、列表项或表格行之前。保留原中文的具体经历、不确定性、数据、代码与路径，并沿用已有文件地址。

## Choose a thread / 选择阅读路径

| Read / 阅读 | Scope / 范围 |
| --- | --- |
| [Early reflections: 0.1–0.6.7](reflections/README.md) | From target speed to active propulsion, charged jumping, staged teaching, and rolling sound.<br>从目标速度到持续推进、蓄力跳跃、阶段教学与滚动声音。 |
| [Continuing full-game journal: 0.7–0.12.12](../experiments/tilt-adventure/REFLECTION.md) | Tilt, calibration, crank machinery, contact/occlusion, progression, publishing, and hardware trade-offs; section contents included.<br>倾斜、校准、摇柄机关、接触与遮挡、进度、发布和硬件取舍；内含章节目录。 |
| [Early design iteration overview](../DESIGN_LOG.md) | Decisions and rejected alternatives; explicitly identifies reconstructed snapshots.<br>决定与放弃的方案；明确标注重建快照。 |
| [Control experiments](../experiments/control-variants/README.md) | Eight reconstructed alternatives and comparison questions, with English/Chinese rules.<br>八个重建的操作变体与比较问题，规则英中对照。 |
| [Version changes](../CHANGELOG.md) | Full version-by-version changes; historical defaults remain historical.<br>逐版变化，保留当时的默认值。 |
| [Classroom test plan](classroom-playtest.md) | Predictions and observation sheet, not invented results.<br>预测与观察表，不是补造的测试结果。 |

## Performance retrospectives / 性能复盘

- [0.5.4 — From pixel rays to SDK masks](performance-v0.5.4.md): repeated measurements and remaining slow frames.
  [0.5.4 — 从逐像素射线到 SDK 遮罩](performance-v0.5.4.md)：逐轮测量与仍然较慢的帧。
- [0.5.6 — Chunking was not automatically faster](performance-v0.5.6.md): input loss versus insufficient force, cache comparisons.
  [0.5.6 — 分块不必然更快](performance-v0.5.6.md)：区分输入丢失与力度不足，比较缓存。
- [0.5.7 — Allocation spikes](performance-v0.5.7.md): sustained inputs, GC evidence, reused workspaces.
  [0.5.7 — 分配尖峰](performance-v0.5.7.md)：持续输入、GC 证据与工作区复用。
- [Later hardware preparation and loading](../experiments/tilt-adventure/REFLECTION.md#user-content-entry-12): collision first, images near the camera.
  [后期硬件准备与加载](../experiments/tilt-adventure/REFLECTION.md#user-content-entry-12)：碰撞先就绪，图像围绕相机准备。

## How to read dates and authorship / 时间与署名说明

These are first-person records of Yibo Wang's design decisions and observations, retrospectively organized with tool assistance from conversations and surviving project files. Code, art production, capture, and automated measurements also used assistance; see [Credits](../CREDITS.md). Do not read a scripted check as an external player's experience.

这些第一人称记录呈现王奕博的设计决定与观察，依据对话和现存工程文件、在工具协助下回顾整理。代码、美术制作、录制与自动测量也使用协助，见 [来源说明](../CREDITS.md)。脚本检查不代表外部玩家的经历。

Git timestamps document surviving archives, not necessarily the date of the original design conversation. Where a source gives a date or version, it is retained; unknown development dates are not guessed. The 0.2/0.3 comparison builds are reconstructions. The continuing journal keeps its original entry order, including later additions to earlier sections.

Git 时间标记现存归档，不一定是原始设计讨论发生时间。原记录给出的日期与版本保留，未知开发日期不猜测。0.2/0.3 比较包是重建版本。后续日志保留原有条目顺序，包括后来补入早期章节的内容。

Technical validation files and raw logs remain independent evidence in their original locations/languages. The bilingual reflections and release notes link them without changing an earlier pending check into a completed one. [Current release evidence](RELEASE.md).

技术验证文档和原始日志仍在原位置，以原有语言作为独立证据保留。双语心得与版本说明提供入口，不会把早期的“待验证”改成“已完成”。见 [当前发布证据](RELEASE.md)。

## Early release notes / 早期版本说明

[0.1](v0.1.0.md) · [0.2](v0.2.0.md) · [0.3](v0.3.0.md) · [0.4](v0.4.0.md) · [0.4.1](v0.4.1.md) · [0.5](v0.5.0.md) · [0.5.1](v0.5.1.md) · [0.5.2](v0.5.2.md) · [0.5.3](v0.5.3.md) · [0.5.4](v0.5.4.md) · [0.5.5](v0.5.5.md) · [0.5.6](v0.5.6.md) · [0.5.7](v0.5.7.md) · [0.5.8](v0.5.8.md) · [0.6](v0.6.0.md) · [0.6.1](v0.6.1.md) · [0.6.2](v0.6.2.md) · [0.6.3](v0.6.3.md) · [0.6.4](v0.6.4.md) · [0.6.5](v0.6.5.md) · [0.6.6](v0.6.6.md) · [0.6.7](v0.6.7.md)
