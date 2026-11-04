[← Project home](../../../README.md) · [Journal index / 日志目录](../../../docs/JOURNAL.md)

# Eight rolling-rule comparison prototypes

# 八个控球规则比较原型

See the [collection](../README.md) for current controls/downloads. New 4 (direct) replaces retired old 4/9; 7 gains docking. There are not nine current variants.

当前操作与下载见 [合集说明](../README.md)。新 4（direct）替换退役的旧 4 与 9；7 加入吸附控制台。当前不是九个版本。

Reconstructed from v0.6.7 and records, not historical originals. These are questions awaiting testing, not established player findings.

这些是基于 v0.6.7 与设计记录重建的实验，不是历史原件。以下是待验证问题，不是已经获得的玩家测试结论。

|Number / ID<br>编号 / 标识|Origin and comparison question<br>来源与比较问题|
| --- | --- |
| 1 speed | v0.1 speed setting: does understandable control sacrifice slopes/momentum? |
| 1 speed | v0.1 速度设定：容易理解的控制是否牺牲坡道与动量体验？ |
| 2 throttle | v0.2 persistent throttle: will players max it once and stop cranking? |
| 2 throttle | v0.2 持续油门：会不会开局摇满后不再使用摇柄？ |
| 3 brake | Rejected v0.3 reverse brake: less frustration or less challenge? |
| 3 brake | v0.3 放弃的逆摇刹车：减少挫败还是消除挑战？ |
| 4 direct | Designer revision: crank immediately redirects velocity, not merely force. Does steering plus A speed feel natural? |
| 4 direct | 用户修订：摇柄必须立即改变已有速度方向，而非只改变推力。直观转向和 A 调速的分工是否自然？ |
| 5 latch | Does reversal clearing encourage planning or confusion? |
| 5 latch | 核心规则对照：反向清条促成规划还是令玩家困惑？ |
| 6 reverse | Negative force slows then reverses: can players distinguish force from speed? |
| 6 reverse | 负推力先减速再倒退：能否理解推力与速度的区别？ |
| 7 track | Auto-dock, A + crank, B release, rearm on leaving: are the two modes and cues understandable? |
| 7 track | 自动吸附，A + 摇柄控制机关，B 释放；离开后可重新吸附。能否理解两个模式和提示？ |
| 8 lock | Is waiting for zero before turning interesting planning? |
| 8 lock | 等推进条归零才转向：等待和规划是否有趣？ |

## Comparative playtesting

## 对比试玩

Use equal time on the shared flat course and rotate order to reduce learning effects; test slopes separately. For 07, compare mode switching, planning, and feel, not completion time directly.

同一平地关给各版相同时间，轮换顺序减少学习影响；坡道另测。07 用专用关，比较模式切换、路线规划、控球体验，不直接比较通关时间。

|Player / version / order<br>玩家 / 版本 / 顺序|Prediction<br>事前预测|Actions and falls<br>实际操作及掉落|Player's words<br>玩家原话|Diagnosis<br>诊断|Keep/change<br>保留或修改|
| --- | --- | --- | --- | --- | --- |
| To record | To record | To record | To record | To record | To record |
| 待填写 | 待填写 | 待填写 | 待填写 | 待填写 | 待填写 |

Observe whether players can explain crank meaning, whether new 4's direct steering matches expectation, whether 7's dock/release is discoverable, and whether retries change strategy.

观察玩家是否能说明摇柄控制什么、新 4 直接转向是否符合预期、7 是否能看到吸附提示并自行释放、再次尝试是否改变策略。

Run builds from the parent experiment directory. Simulator S=A, keyboard A=B. The formal game/default tasks remain unchanged. New 4 bundleID is com.wangyibo.skyhamster.variant.direct; 7 retains track.

构建脚本在父级实验目录运行。模拟器 S=A，键盘 A=B。正式游戏及其默认任务不变。新 4 bundleID 为 com.wangyibo.skyhamster.variant.direct；7 沿用 track 标识更新。
