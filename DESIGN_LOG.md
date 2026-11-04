[← Project home](README.md) · [Journal index / 日志目录](docs/JOURNAL.md)

> Archive metadata: first recorded Git author timestamp `2026-09-09T20:53:06-04:00`. This dates the surviving record, not necessarily the original design work. Version identifiers in the headings are retained.
>
> 归档元数据：最早记录的 Git 作者时间为 `2026-09-09T20:53:06-04:00`。这是现存记录的时间，不一定是原始设计发生时间；保留标题中的版本编号。

# Sky Hamster: Design iteration record

# Sky Hamster：设计迭代记录

This retrospective draws on the development conversation and surviving files. Issues and trade-offs originate in designer feedback, not necessarily completed external playtests. No participant counts, results, or development dates were invented.

这是一份根据本次开发对话和现存文件整理的回顾记录。问题与取舍来自设计者的反馈，不等于已经完成的外部玩家测试；没有补造测试人数、结果或开发日期。

## 0.1: First validate staying on the road

## 0.1：先验证控球不掉下去

The first idea was a Hamsterball-inspired floating track focused on inertia, narrow roads, and avoiding falls. A fixed isometric view and code-drawn monochrome visuals avoided full 3D production cost in the first prototype.

最初想做受《仓鼠球》启发的浮空赛道，重点是惯性、狭窄路线和不掉落。采用固定斜视角与代码绘制的黑白画面，避免在第一个原型中承担完整 3D 制作成本。

Initially the crank set target speed and the D-pad changed direction, with checkpoints, timing, and retry. The designer questioned whether a zero target would interfere with downhill motion and momentum through valleys. Those questions led to the next revision.

最初让摇柄设定目标速度，方向键改变运动方向，加入检查点、计时和重试。设计者随后指出：目标速度如果是零，会不会妨碍下坡？冲过谷底再爬坡是否能保留动量？这些问题促成下一轮修改。

## 0.2: Replace speed setting with propulsion force

## 0.2：把速度设定改为推进力度

The crank now controls force, with independent slope gravity and zero-throttle descents. Four courses examine turning, natural descent, valley climbing, and a narrow post-descent turn. Persistent throttle and extra opposing braking remained at this stage.

将摇柄控制量改成推进力度，坡度重力独立施加，零油门仍可下坡。用四个关卡分别观察转弯、自然下坡、谷底冲坡和下坡后的狭窄弯道。此阶段仍保留持续油门和额外的反向刹车。

A new problem: maximum force plus strong D-pad braking made sustained crank use unnecessary. The designer wanted the crank to remain necessary, not set once at startup.

新问题：把力度一直设为最大，再依靠方向键强力刹车，摇柄就不需要持续参与。设计者希望“摇柄有必要”，而不是开局设置一次。

## 0.3: Sustained crank involvement, separate propulsion and jumping

## 0.3：让摇柄持续参与，并分离推进与跳跃

- Clockwise accumulated rotation raises POWER rather than setting speed; after a short pause it retracts rapidly.

- 顺时针按累计转角增加 POWER，不直接设置球速；停摇后短暂等待，再快速回缩。

- Counterclockwise charges a jump; A jumps. Charge fades more slowly, and clockwise input does not directly spend it.

- 逆时针为跳跃蓄力；A 起跳。跳跃蓄力回缩更慢，顺摇不会直接消耗它。

- Gravity and inertia remain; reverse propulsion uses ordinary force without a braking bonus.

- 重力与惯性保留；反方向推进使用普通推力，没有额外刹车加成。

- Above the 60% POWER latch, a large reversal clears the bar and accepts the new direction, requiring fresh cranking. This tests force, not velocity; low-force or small corrections do not clear it.

- POWER 超过 60% 卡扣时，大幅反向输入清空推进条并接受新方向，需要重新摇动加力。判断的是力度，不是球的速度。低力度转向和小幅调整不清空。

- Gap and landing courses were added, with hamster/ball lines rotating during motion.

- 增加跳跃间隙关、落点控制关，仓鼠和球的线条随移动滚动。

Rejected alternatives included direct reverse-crank braking, reverse thrust, and direct track rotation. The first two could make slowing too easy; the third shifts attention from the ball to the track. Moving tracks remained a possible later external obstacle, not implemented in this round.

讨论过但未采用的方案：逆摇直接刹车、逆摇提供反向推进、让玩家直接旋转赛道。原因是前两种可能让减速过于直接，后者会把注意力从控球转移到轨道操作。运动轨道可以作为以后外部障碍，但本次未实现。

Requiring zero force before any direction change was also discussed. Conditional high-force reversal clearing avoids imposing a wait on every turn.

也讨论过“必须等力度归零才能换方向”。最终采用高力度大幅反向清条，避免对所有转弯一律施加等待。

## 0.4: Stage the learning process

## 0.4：把学习过程分阶段呈现

Courses 1–4 focus on propulsion, inertia, corners, and slopes, hiding/disabling jumping; Courses 5–6 introduce reverse-crank charging and A jumps.

前四关专注推进、惯性、转弯和坡道，关闭跳跃输入和显示；第 5、6 关再介绍逆摇蓄力与 A 跳跃。

Immediate menu switching became a selection screen with D-pad choice, A confirm, and B return. Teaching cards, POWER/JUMP gauges, raised start/checkpoint/finish signs, and leaders accompany the retained paused map. Completion marks were still session-only, without permanent saves.

将系统菜单中的立即切关改为独立选关界面，方向键选择、A 确认、B 返回。加入教学卡、POWER/JUMP 仪表、起点/检查点/终点的架高标牌与指示线，保留暂停地图。完成标记仅保存在当前运行会话，尚未加入永久存档。

These changes address the designer's confusion over CW/CCW/Charge, diagonal direction labels, and ground-level signs. Learn ball control before a second action.

这些改动回应了设计者对 CW、CCW、Charge、斜向方向说明和贴地标签难理解的反馈。目标是让玩家先学会控球，再加入第二个动作。

## Still requiring actual playtests at this stage

## 当前仍需真实试玩验证

Latch thresholds, force retraction, charge decay, and landing tolerance require hands-on adjustment. This record contains no quantified conclusions about completion rate, learning time, or readability gains.

卡扣阈值、推进条回缩速度、跳跃蓄力衰减和落点容错是否舒适，需要玩家实际操作后再调整。关卡通过率、学习时间与可读性改善尚没有在此记录中形成量化结论。

## Archive and verification scope

## 归档与验证范围

All four releases compiled with local Playdate SDK 3.1.1 pdc. Compilation is not full completion or hardware verification of each version. Sources 0.2–0.4 contain startup physics assertions; this archive round did not rerun every Simulator test.

四个发布版本均使用本机 Playdate SDK 3.1.1 的 pdc 成功编译。编译验证不等于完整通关或每个版本的真机验证。0.2–0.4 源码带有启动时物理回归断言；本轮归档尚未重新执行模拟器里的全部测试。

Version 0.1 main.lua came from saved main-v01.lua.bak; 0.4 Lua came from the current project. Complete original 0.2/0.3 snapshots were missing, so these are reconstructed comparisons of confirmed mechanics, with potentially different UI/internal organization. Version 0.2 disables jumping through adaptation but retains unreachable jump branches/rendering. Commit dates reflect archiving, not original development dates.

0.1 的 main.lua 来自保存的 main-v01.lua.bak；0.4 的 Lua 源码来自当前工程。0.2、0.3 缺少完整原始快照，采用重建比较版本：重现已确定的核心机制，界面和内部组织可能与历史实现不同。0.2 使用适配代码关闭跳跃，仍保留部分不会进入的跳跃渲染/分支结构。提交日期统一反映本次归档时间。

Game design: Wang Yibo.

游戏设计：Wang Yibo。
