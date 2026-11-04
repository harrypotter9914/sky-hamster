[← Project home](README.md) · [Journal index / 日志目录](docs/JOURNAL.md)

# Version changes

# 版本变化

## 2026-10-21 · itch.io free-selection instructions

## 2026-10-21 · itch.io 自由选关说明

- Added Play any of the 53 courses near the public introduction: hold A+B in Settings for built-in developer mode, enter a course, then Menu → Level select. Instructions explain disabling it and isolation from normal progress/scores.

- 在公开简介开头加入“Play any of the 53 courses”：Settings 长按 A+B 开启内置开发模式，进入一关后从 Menu → Level select 自由体验全部关卡，说明关闭方式及普通进度／成绩隔离。

- Sequential unlocking/order and the package/version remain unchanged. Instructions follow the published 0.12.9 entry restrictions rather than implying title/Settings selection worked there.

- 保留正常逐步解锁与关卡顺序，不更改游戏包或版本。说明按实际公开 0.12.9 的入口限制编写，避免玩家在主页或设置点选关无反应。

- Waited for Saved, revisited publicly, and retained screenshots/before-after notes. See the [page update](release/itch-v0.12.9/free-select-2026-10-21/README.md).

- 等待 Saved 后重新访问公开页验证，保留页面截图与前后说明。见 [页面更新记录](release/itch-v0.12.9/free-select-2026-10-21/README.md)。

## 0.12.12 — 2026-10-09

- All five Settings rows share centerlines for selection frame, ball cursor, icon, label, and ON/OFF or ROAD/SCREEN.

- 设置页五行统一中心线：选中框、球形光标、图标、标签与 ON／OFF、ROAD／SCREEN 垂直对齐。

- Spacing grows 22 → 26 pixels, with a 23-pixel selection frame and 91 × 19 switches, fixing low switches and overlap with Steering while retaining fonts/style.

- 行距 22 → 26 像素，选中框 23 像素高，右侧按钮统一 91×19；给上下行留白，修正开关向下偏移及与 Steering 重叠。字体与既有风格保留。

- Twelve native views cover each selected row, all ON/OFF, ROAD/SCREEN, and hidden developer state. Menu regressions passed; see [validation/installation](experiments/tilt-adventure/VALIDATION-v0.12.12.md).

- 逐行选中、全 ON、全 OFF、ROAD／SCREEN 及隐藏开发状态共 12 张原生画面复查。既有菜单流程回归通过；验证和安装记录见 [本轮记录](experiments/tilt-adventure/VALIDATION-v0.12.12.md)。

## 0.12.11 — 2026-10-09

- Removed duplicate New Game from Settings, retaining title Continue/New Game and reset confirmation.

- 删除 Settings 内重复的新游戏入口，保留首页 Continue / New Game 及重置确认。

- Developer entry stays hidden: hold A+B about 2.5 seconds in Settings. Enabled system-menu selection works from title/Settings and exposes all 53 courses. Disabling/restarting restores normal access; test scores, unlocks, and tutorial records remain isolated.

- 开发入口保持隐藏：Settings 内 A+B 长按约 2.5 秒切换，没有可见的开发者选项。启用后系统菜单可从主页和设置打开 Level select，53 关均可测试；关闭或重启恢复正常权限，测试成绩、解锁和教学记录与普通进度隔离。

- System shortcuts show only valid actions: none on normal title/loading; selection, map/pause, and title during play; Resume game on map; no invalid jumps from Help/Goal. B returns selection to its originating title, Settings, map, or course; ending cancellation returns to ending.

- 系统快捷菜单只显示当前能执行的操作：普通主页和加载无自定义项；游玩显示选关、地图／暂停和首页，地图提供 Resume game，帮助／目标页不提供无效跳转。选关 B 返回原主页、设置、地图或关卡；结局菜单取消回结局。

- Menus rebuild only when action sets change. Courses, art, feel, and instruction stay. See [validation](experiments/tilt-adventure/VALIDATION-v0.12.11.md).

- 菜单仅在动作集合变化时重建，保留关卡、美术、手感与教学。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.11.md)。

## 0.12.10 — 2026-10-09

- First instruction adds four generated Map/Help/Go/Recenter illustrations explaining purpose and timing. Matching directions try actual screens and return to the same lesson with ball/time paused.

- 首次教学补充 Map、Help、Go、Recenter 四页生成图示，说明用途与使用时机；按对应方向键试用真实页面，返回原教学位置，试用期间暂停球和计时。

- Help saves/restores the onboarding queue, prevents nested trials, and returns after reading or B. Old saves receive new lessons once without losing progress/scores.

- Help 暂存并恢复首次教学队列，禁止嵌套试用，读完或按 B 返回均可；旧存档补看新说明，已读后不在每关重复，保留进度与成绩。

- Jump animation explains fallback A, separating gameplay Jump, cannon Fire, and tutorial Next. Four fixed-size monochrome illustrations match the UI.

- 跳跃动画补充 A 备用方式，区分游玩中的 Jump、炮台中的 Fire 与教学内的 Next。独立生成四张固定尺寸黑白图，保持现有界面风格。

- Host, Simulator, and hardware trials passed; 17 native views on each side were reviewed. Text touching a divider was fixed and retested. Courses/feel unchanged. See [validation](experiments/tilt-adventure/VALIDATION-v0.12.10.md).

- 主机流程回归、模拟器与真机试用检查通过，两端各 17 张原生画面复查；发现说明碰到分隔线后修正重测。关卡与手感不变。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.10.md)。

## 0.12.9 — 2026-10-09

- Updated itch.io to the matching official ZIP, with jump/cannon/onboard-turntable GIFs, steering comparisons, newcomer guidance, unlocking, controls, sideloading, and credits. Images retain 5:3; free/optional donations remained at that historical point. Publishing changes did not change source. See [release record](release/itch-v0.12.9/PUBLICATION.md).

- itch.io 下载更新为同版本正式 ZIP；增加跳跃／炮台／板上转台 GIF 与两种操控动画对照，补充陌生玩家入门、正常解锁、操作表、侧载和来源说明。正文图片保持 5:3 比例，免费／自愿打赏不变。发布材料更新未修改游戏源码。见 [发布记录](release/itch-v0.12.9/PUBLICATION.md)。

- Three generated pixel cloud forms replace faint sketch outlines with volume, drifting edges, and prebaked shading.

- 关卡背景云改用三种生成的像素云团，加入内部层次、飘散边缘与预烘焙阴影，替换淡线简笔轮廓。

- Five clouds retain speed, parallax, animation toggle, and behind-road placement. Transparent native monochrome images require no runtime scaling/fading/allocation.

- 保留五朵云、漂移速度、视差、动画开关和道路后方绘制。图片预先转换为透明纯黑白原生尺寸，运行中不缩放、不淡化、不分配新图片。

- All 53 courses, controls, and title remain. Five Simulator scenes, loop, and menus passed; later final-package hardware checks covered 53 courses/761 scenes, 28 feature groups, and 47 audio playback checks. See [validation](experiments/tilt-adventure/VALIDATION-v0.12.9.md).

- 保留完整 53 关、操控和首页。模拟器五个代表场景、主循环和菜单回归通过；后续完成最终包真机 53 关 / 761 场景、28 功能组与 47 音频播放检查。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.9.md)。

## 0.12.8 — 2026-10-09

- Steering becomes an animated two-card screen: identical tilt shows Screen versus isometric Road, with Left/Right selection, A save, B cancel.

- Steering 改成独立双卡片动画页：同样的倾斜动作分别展示 Screen 的屏幕方向与 Road 的斜视道路轴，左右选中、A 保存、B 取消。

- With progress, Start opens Continue/New Game. Reset defaults to Cancel, clears progress/scores/tutorials while retaining audio and asking steering again. First play introduces the goal, defaults the comparison to Road, then confirms saving and future Settings changes.

- 首页已有进度时，Start Game 打开 Continue / New Game；新游戏仍默认取消，确认后重置进度、成绩和教程，保留声音设置，操控重新选择。首次开始进入第一关，先目标介绍，再默认选中 Road 的操控对照，确认保存后提示可随时在设置更改。

- New saves unlock sequentially with lock icons. Old current/completed records remain. Temporary hidden selection cannot write completion, scores, tutorials, or skipped position; restart returns to normal.

- 新存档按通关解锁后续路线，锁住的关卡显示独立锁图标并拒绝进入；旧存档当前关和已完成记录保留。隐藏的临时开发选关不会写入通关、成绩、教程或跳关进度，重启恢复普通模式。

- Continue/New Game get dedicated horizontal frames rather than compressed cards. New cards, poses, rolling ball, road samples, and locks export at fixed size without runtime scaling/generation.

- Continue／New Game 单独生成横版框，不压缩操控卡片；新增配套生成卡片、机器姿态、滚动球、道路样板和锁图标，固定尺寸预导出，不在动画中缩放或生成位图。

- The 53 courses and handling remain. See [validation](experiments/tilt-adventure/VALIDATION-v0.12.8.md) for release, automated, visual, and known hardware scope.

- 保留 53 关及当前手感。发布核查、自动测试范围、模拟器画面和已知真机限制见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.8.md)。

## 0.12.7 — 2026-10-02

- Restored the Mac playtest's Settings → Start New Game to main: confirmation resets progress, bests, and lessons from Course 1 while preserving audio/control preferences.

- 将 Mac 试玩版中的 Settings → Start New Game 正式补进主线：确认后重置进度、最佳成绩与教程记录，从第一关重看指引；保留音效、音乐和操作偏好。

- Cancel is default; B returns and Left/Right cannot start anew. Six rows retain both Steering mappings.

- 确认页默认取消，B 返回设置；左右键不会触发新游戏。设置保留 Steering 两种映射，重新排齐六行。

- Acceleration, reverse braking, and all 53 courses from 0.12.6 remain, with real menu-event/save-reload regressions.

- 保留 0.12.6 的加速、反向刹车及完整 53 关。加入实际菜单事件和重新载入存档的回归检查。

- The earlier Mac feature existed only locally/on hardware; merging it prevents loss when installing from another device.

- Mac 上的该功能曾仅修改本地并安装，没有进入远端主线；本轮补入正式版本，避免换设备安装时遗漏。


## 0.12.6 — 2026-09-30

- Acceleration returns close to 0.12.4, with only subtle small-angle refinement and no excessive tilt for full force. Strong reverse braking, both mappings, and neutral settling remain.

- 将加速恢复到接近 0.12.4，只保留轻微的小角度细化；满推力不再需要过度倾斜。增强反向刹车、两种方向模式及中立收速保留。

- Near-linear input and neutral-only settling no longer drag forward propulsion; reverse coefficient unchanged.

- 输入曲线接近原来的线性响应；中立收速不再拖慢正常前推。反向助力系数不变。

- At fixed flat 10°/15°/20° input, one-second speeds are about 94%/97%/98% of the original; full force returns near 26°.

- 平地固定输入 10°／15°／20°，一秒后速度为原版约 94%／97%／98%；满推力角度恢复到约 26°。

- See this version's validation for Simulator/hardware checks, installation, and save verification.

- 模拟器与真机检查、实际安装和存档核验见本版验证记录。

## 0.12.5 — 2026-09-30

- Stranger feedback motivates finer small inputs, opposing-tilt brake assistance, faster neutral settling, Screen/Road choice with consistent arrows/tutorials, and low-contrast clouds.

- 根据陌生人试玩反馈调整倾斜手感：小幅度输入更细腻、反向倾斜辅助刹车、中立后更快收速；设置新增 Screen／Road 两种方向模式，并同步箭头和教学。增加低对比远景云层。

- Same-direction active force eases at speed, retaining downhill/airborne momentum and avoiding instant stops. Jump/cannon trajectories remain.

- 高速时逐渐减弱同向主动推进，保留下坡和空中动量；不采用瞬间停球。跳跃与炮台轨迹保持原算法。

- Screen was default at this stage, switchable/saved in Settings → Steering. Progress/settings remain; new instruction replays once.

- 默认 Screen，可在 Settings → Steering 切换并保存；原有进度、设置和记录保留，新操控说明重播一次。

- Both mappings completed real tilt routes, 15 Simulator/hardware image comparisons, and seven-course hardware samples; see validation/performance notes.

- 两种模式真实倾斜路线测试、模拟器／真机 15 张画面对照，以及真机 7 关专项抽测；详见本版验证和性能记录。

## 0.12.4 — 2026-09-29

- Wind covers road width; magnetic edges broaden and fast crossings are continuously detected. Adjustable wind assists slopes with GO/WAIT and ground-direction feedback, retaining gradual force and opposing input.

- 风场覆盖整段路宽，磁场扩大有效边缘、连续检测高速穿越；旋转风机改为顺风爬坡，增加 GO／WAIT 与地面方向提示。保留渐进加速和反向倾斜控制。

- Ordinary wind rises about 18.5%; default peak magnetism rises 10%, with useful edge force and no entry impulse.

- 普通风力较上一版增加约 18.5%，磁力峰值默认增加 10%，边缘力量不再衰减到几乎为零。没有入场瞬时冲量。

- Fan lessons/reviews/finales use wind slopes with extended descents where higher. Progress/settings stay; affected old bests reset.

- 更新旋转风教学与后续复习／终局风坡；较高风坡延长下坡段。保留进度与设置，重置受改动影响的旧最佳时间。

- Thirty-nine native frames and seven-course/61-scene hardware checks are documented in `experiments/tilt-adventure/VALIDATION-v0.12.4.md`.

- 原生 39 帧画面检查及真机 7 关、61 场景专项测试；数字和限制见 `experiments/tilt-adventure/VALIDATION-v0.12.4.md`。

## 0.12.3 — 2026-09-29

- Reviewed all 53 courses, reworking 19 cumulative reviews, five tutorials, and four finales while preserving progression and every-mechanism coverage in each finale.

- 审查全部 53 关；重组 19 个累计复习关、调整 5 个教学关及四个终局关，保留递进教学与最后四关全机制覆盖。

- Final three courses use 6/6/10 cannons, offset receivers, braking space, and relays; level switchbacks permit ordinary rolling.

- 最终三关大炮增至 6／6／10 门，使用双侧斜向落点、接收刹车台和连续炮击；水平折返平台让急弯可以正常滚动通过。

- Conveyor/jet/magnet lessons become distinct; branch, island, ferry, and bridge combinations vary. Edited layouts reset stale bests, retaining identity, progress, and settings.

- 传送带、喷气、磁力教学名称区分；分路、跳岛、渡板与转桥组合改变。改图关卡清除过期最佳时间，关卡身份、通关进度和设置保留。

- Ordered road-image matching and analytic bounds reduce temporary tables/index work; bounded nearby preparation remains, and builds verify export source snapshots.

- 道路图片顺序匹配减少临时表，解析边界减少区块索引计算；保持有界的相机附近图片准备，构建校验导出时的源码快照。

- Scope, measurements, and limits: `experiments/tilt-adventure/VALIDATION-v0.12.3.md`.

- 验证和真机测试范围、数字及限制见 `experiments/tilt-adventure/VALIDATION-v0.12.3.md`。

Numbering continues the full-game sequence, then at 0.12.9; see the [version table](docs/VERSIONS.md). (Historical status, not the latest version.)

统一沿完整版顺序递增，当前 0.12.9；新旧编号见 [版本总表](docs/VERSIONS.md)。

## v0.12.2

Long courses initially prepare nearby road imagery, fill further chunks in small batches during play, and release distant images. Collision is ready first; fast travel/checkpoint returns cannot fall because of texture cache state. Original SDK rendering prebakes fixed roads and cannon/fan angles, preserving visuals. Loading processes multiple small steps within a time budget.

长关进场只准备相机附近道路，后续在游玩时按小批次补齐，远处图像可释放；完整碰撞地图仍先就绪，快速移动或检查点回退不以图片缓存决定是否掉落。固定道路、大炮和风机角度图像由原 SDK 绘制器预生成，画面保持一致；加载器按时间预算处理多个小步骤。

Indexes accelerate landing/road occlusion queries, distant controls/audio avoid repetition, and fixed sign projections are reused. Source fingerprints prevent stale textures. Hardware loading/FPS comparisons and limits are in [validation](experiments/tilt-adventure/VALIDATION-v0.12.2.md).

接岸和道路遮挡改用索引查找，远处控制点与音效状态减少重复查询，固定路标投影复用。资源源文件指纹纳入构建，防止错用旧贴图。真机加载与帧率对比、具体限制见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.2.md)。

## v0.12.1

Hardware error logs confirmed long-course loading exceeded the ten-second run-loop watchdog. Route generation, docking scans, and terrain-occlusion preparation now yield across frames. Long-course saves first show title; Start prepares the map. Test planning/loading likewise yields and records time instead of draining everything in one frame.

真机错误日志确认长关加载曾触发“运行循环超过 10 秒”的系统保护。路线生成、平台接岸扫描和地形遮挡准备改为分批执行；存档停在长关时也先进入首页，按 Start 后再生成地图。测试工具的规划与加载同样分帧执行，单独记录加载耗时，避免在一帧内排空整个流程。

All 53 courses/machinery remain. Earlier USB silence now has crash evidence; hardware retest and normal installation are in [validation](experiments/tilt-adventure/VALIDATION-v0.12.1.md).

保留 53 关和全部机关。此前的 USB 无响应现有明确崩溃证据，具体真机复测与正常安装结果见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.1.md)。

## v0.12.0

Reorganized 53 courses into 20 teaching stages: short introductions followed by cumulative review. Onboard turning moves into progression rather than ending it. The four finales have 21/23/25/28 encounters each, covering all machinery and slopes, valleys, narrow roads, switchbacks, gaps, islands, height changes, diagonal ferries, and cannon flight; the last two add local combinations. Checkpoints divide segments and the map browses them.

重新组织为 53 关、20 个教学阶段：先短关学习新机制，再通过累计复习关结合之前学过的玩法。板上转向移入教学流程，不再占据结尾。最后四关分别包含 21、23、25、28 段遭遇，每关都覆盖全部机关以及坡道、谷地、窄路、回头弯、断口、小岛、高低台、斜向渡板和炮台飞行；后两关增加局部复合障碍。段间设检查点，地图可以按段浏览。

Long-course geometry generates on entry and releases on exit; road caches prepare in advance. Stable course IDs migrate completions; unchanged bests stay, rebuilt routes invalidate old times. Scripted real-engine completion passed all four finales and 232 docking checks. USB became unresponsive, leaving final FPS, native review, and normal installation pending—not proof of hardware smoothness. See [campaign](experiments/tilt-adventure/CAMPAIGN-v0.12.0.md) and [validation](experiments/tilt-adventure/VALIDATION-v0.12.0.md).

长关几何按进入时生成，离开后释放，道路缓存提前准备。旧通关进度按稳定关卡 ID 迁移；未改变布局的纪录保留，重建路线的旧最佳时间失效。四条终局路线通过真实引擎的脚本连续通关检查，232 处接岸检查通过。真机 USB 失去响应，最终帧率、原生画面复核与正常包恢复安装仍待完成；不据此宣称真机流畅。详见 [关卡顺序](experiments/tilt-adventure/CAMPAIGN-v0.12.0.md) 和 [验证记录](experiments/tilt-adventure/VALIDATION-v0.12.0.md)。

## v0.11.0

Double-gate lanes have separate numbers and GO/WAIT from actual transition openings. Plates, leaders, compact markers, and names avoid ball/compass and follow jump height; the fixed divider gets no redundant sign.

双闸门两条通道各有编号和独立 GO／WAIT，切换途中按实际开口判断。牌面、引线、紧凑标记、原有名称牌共同避让球及方向罗盘，跳跃时按当前高度调整；固定隔墙不显示多余通行牌。

Edge support uses the radius-9 circular footprint, allowing equal-height narrow seams instead of center-only falls. Rotation stays continuous; ports show check GO/cross WAIT. Lifts, ferries, telescoping bridges, gates, disappearing floors, two-lane barriers, and jets also report actual geometry/height while avoiding names, ball, and other signs.

小球边缘支撑按半径 9 的圆形占地计算，同高度窄缝不再只按球心掉落。旋转保留无级角度，接岸口分别显示对勾 GO／叉号 WAIT；提示还覆盖升降台、渡板、伸缩桥、闸门、消失地板、移动挡板的两条通道和间歇喷气。提示检查真实几何与高度，避让名称牌、球和其他提示。

Added Courses 45–48: onboard turning, successive turns, shore recall plus onboard control, and turntable/ferry/wind combinations. Turntables rotate continuously within square voids with shore clearance; two controls share angle. Instruction shows boarding, crank, GO, and B release. Wind rises only 8% using swept contact duration. Top-surface clipping prevents corner texture overflow. See [validation](experiments/tilt-adventure/VALIDATION-v0.11.0.md).

新增 45–48 关：板上转向、连续转向、岸边召回与板上操作、转台／渡板／风区综合路线。新转台在方形空区内连续旋转，端部避让岸边；两个控制点共用当前角度。教学展示先上板、摇柄转动、出口可通行、B 解除后离开。风力仅增加 8%，按扫过风区的时长施力。道路纹理裁切到顶面，避免拐角越界。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.11.0.md)。

## v0.10.12

Vertical springs become low circular bumpers: radius 18 → 14, sidewall height 10. Only real side contact causes radial rebound; airborne/top crossings do not. Redundant square bases are removed and assets, anchors, and occlusion agree. Contact triggers a 0.36-second ring expansion/recovery and elastic sound; visual expansion never enlarges collision. Tutorials update too. See [validation](experiments/tilt-adventure/VALIDATION-v0.10.12.md).

竖直弹簧改成低矮圆形弹力护圈，底座半径从 18 缩至 14，侧壁高度统一为 10。球真正碰到侧壁才径向反弹；跳过顶部、落在顶部范围内的空中过程不产生横向推力。取消多余方形底座，素材、地面定位和遮挡统一。真实撞击启动 0.36 秒整圈外扩／回弹及专属弹性音效，视觉外扩不放大碰撞范围。教学图和说明同步更新。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.12.md)。

## v0.10.11

Springs actively rebound radially rather than lossy reflection, including slow/glancing contact, without retriggering after separation; jumping over remains. Current art masks and 3D foreground volumes occlude balls behind springs, fans, cannons, magnets, nozzles, and consoles. Platform masks match 12-pixel thickness, including belt bases. Foreground labels stay readable.

弹簧从损耗反射改为按接触点径向弹出，慢速和擦边也有明确外推；分离后不重复触发，跳跃越过规则保留。弹簧、风机、炮台、磁铁、喷气嘴及控制台使用当前美术轮廓与三维前景体积共同遮挡小球。平台侧面遮罩匹配 12 像素实体厚度，传送带等底板补入遮挡。机关标签移到前景，保持可读。

Tests include 7,488 directional spring contacts, 408 native direction/animation images, and hardware samples in Courses 14/27/44. See [validation](experiments/tilt-adventure/VALIDATION-v0.10.11.md).

7,488 次全方向弹簧接触回归、408 张原生方向／动画截图，以及第 14、27、44 关真机抽测。详见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.11.md)。

## v0.10.10

The upper HUD becomes a mechanical dashboard: inverted course plate, consistent flag/tilt/spring/ball/time/fall icons, fixed-width numbers, and segmented ticks. It retains name, force/direction, jump recovery, time, deaths, and actual speed, compacting large values. Size stays 400 × 43; lower HUD/gameplay stay. Frames/ticks cache; integer changes update readings. See [validation](experiments/tilt-adventure/VALIDATION-v0.10.10.md).

顶部 HUD 改成机械仪表板：反白关卡牌、统一的旗帜／倾斜／弹簧／滚动球／计时／掉落图标、固定宽度读数和分段刻度。保留关卡名、力度与方向、跳跃恢复、计时、死亡次数和真实速度；大数值采用紧凑格式。顶部仍为 400×43，底栏及玩法不改动。静态框架与刻度缓存，读数按整数变化更新。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.10.md)。

## v0.10.9

Hardware retesting covers roads, local motion, every mechanism/control across 44 courses. Nearby indexes separate support/collision/fields; fixed lift columns cache, fan directions preload, and cannon-hidden balls skip rendering. Input icons and context hints cache/warm on entry. USB wake applies to title/loading/play, restoring locking unplugged.

按照 44 关道路、局部移动视角、每个机关及控制点进行真机复测。物理索引按支撑、碰撞、力场分别筛选；固定升降支柱缓存，风机朝向在加载时准备，隐藏在炮内的球不再重复绘制。按键图标和机关提示条缓存，进入关卡时预热。USB 供电时首页、加载和游戏保持唤醒，拔线后恢复自动锁屏。

Road chunks merge/preload, exit releases derived caches, indexed height queries replace scans, and HUD-hidden draws skip. Device Auto Lock is also Off while charging, including outside the game.

道路缓存块合并并提前准备，离开关卡释放派生缓存；地面高度改用索引查询，跳过 HUD 背后的绘制。真机系统自动锁屏也设为“Off while charging”，退出游戏后同样适用。

Measurements, comparisons, and test boundaries: [validation](experiments/tilt-adventure/VALIDATION-v0.10.9.md).

完整测量、优化前后对照及测试边界见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.9.md)。

## v0.10.8

Fixed near-end machinery covering foreground roads. Six lifts retain rear exits but replace solid walls with open platforms and independent supports. Projected cylindrical barrels shorten toward the viewer and show the muzzle. Aim, smoke, and launched ball share muzzle coordinates while landing ranges remain. Tutorials match and loaded balls enter the barrel. Fan heads/blades project with wind direction.

修复旋转桥与其他机关近端侧面盖住前景道路的问题。六处升降台保留后侧出口，移除整面高墙，改成留空的高台和独立细支撑。炮管改为立体圆筒投影，转向镜头时缩短并露出炮口；预瞄线、烟雾与发射出的球共用炮口坐标，原有弹道落点保持一致。炮台教学同步更新，装填时球收入炮内。风机机头与叶片也按风向投影。

Twelve mechanism types and manual/automatic lessons gained foreground/trajectory regressions. First hardware results exposed tile-by-tile foreground redraw cost; merged caches/loading prewarm preserved native images. See [validation](experiments/tilt-adventure/VALIDATION-v0.10.8.md).

检查 12 类机关及手动／自动教学，新增前景道路和弹道回归。真机初稿暴露逐块重画道路的性能开销，随后加入合并缓存和加载时预热，原生导出画面保持一致。具体测量与安装状态见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.8.md)。

## v0.10.7

Cannon barrels turn with trajectories over fixed bases; ferry stops use shore edges; bridge ends retract while turning and reconnect aligned. Six upper lift exits move rearward, with thick upper sides and corrected layering/collision/cache bounds. Tutorial cranks physically rotate; automatic boards use separate lessons.

炮管随瞄准航线实际转动，底座保持固定；渡板停靠点按道路边缘重新计算，旋转桥端部在转动时避让道路，对齐时闭合接缝。六处升降台的上层出口移到后侧，加入有厚度的高台侧壁并修正分层、碰撞和地形缓存范围。教学让机身摇柄真正旋转，自动移动板不再混用手动教学。

Initial hardware bridges ran around 23 FPS, prompting prebaked per-degree textures while physics remains continuous. Geometry/native checks passed; USB interrupted final hardware/normal installation. See [validation](experiments/tilt-adventure/VALIDATION-v0.10.7.md).

专项真机初稿暴露连续转桥约 23 帧的开销，随后把详细贴图预生成成逐度画面，物理仍使用连续角度。几何回归与原生画面检查通过；最终真机复测和正常游戏覆盖安装因 USB 断开待完成。见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.7.md)。

## v0.10.6

Moving boards gain thick frames, beams, carriages, and twin rails; lifts gain telescoping columns and side transmissions. Rotating/telescoping bridges, floors, barriers, belts, and bases share riveted metal/light panels. Floors fold below frames and gears sit in housings. Cannons use round mounts, curved cradles, and thick barrels with barrel-only recoil. Tutorials reuse formal art.

移动板加入厚边框、承重侧梁、滑车和双导轨；升降台加入伸缩支柱与侧面传动箱。旋转板、伸缩桥、消失地板、挡板、传送带及小机关底座统一采用铆钉金属和浅色板材。消失地板在边框下折叠开合，齿轮放进侧面传动箱。炮台换成圆形承座、弧形支架与粗炮管，发射时只有炮管后坐。相关教学使用正式素材。

Fixed rolling caused solely by platform translation/rotation, retaining active roll and launch momentum, with relative-motion regressions. Fixed rails/bases/panels cache; gears/structures prepare on loading and release on exit. Hardware results/limits: [validation](experiments/tilt-adventure/VALIDATION-v0.10.6.md).

修复球只随平台平移或旋转时错误自转，主动滚动与原有起跳动量保留。新增相对滚动回归。固定导轨、底座和面板缓存，加载时准备齿轮帧与关卡结构，切关释放上关结构缓存。真机测量和已知限制见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.6.md)。

## v0.10.5

All 45 audio files and two rolling speeds passed 47 hardware start/stop checks. To reduce audio cost, conservative audible bounds cover full travel/fan zones, re-entry restores current-time state, and idle stops, loop queries, and unchanged volume/rate writes are reduced. Assets/timing/physics stay. Added 6,256 boundary checks and 44-course audio-trace comparisons. See [hardware record](experiments/tilt-adventure/VALIDATION-v0.10.5.md).

真机逐项验证 45 个音频素材及滚动声快慢两档，共 47 项播放和停止检查通过。发现复杂场景中声音模块额外耗时较高，因此加入保守的听觉范围筛选，包含移动机关整个行程及风机作用区；远处机关重新靠近时按当前时间恢复状态。减少空闲播放器的 stop、循环播放状态查询及不变的音量／速率设置。声音素材、机关时序和物理规则不变。新增 6,256 个范围检查及 44 关筛选前后的声音轨迹对照，详见 [真机记录](experiments/tilt-adventure/VALIDATION-v0.10.5.md)。

## v0.10.4

Added 35 audio assets: 13 operation loops, 16 mechanism events, and six interface cues. Lifts, shuttles, bridges, fans, cannons, springs, gates, floors, jets, belts, and magnets sound by state, including locking/release. Attenuation, concurrency caps, and pause cleanup limit stacking; rolling timbre remains.

为机关和界面新增 35 个独立音频素材：13 类运转循环、16 类机关事件和 6 类界面反馈。升降台、横移台、旋转桥、风机、炮台、弹簧、闸门、地板、喷气、传送带和磁力区按各自状态发声，锁定与解除也有反馈。距离衰减、并发上限及暂停清理限制声音堆叠；原有滚动音色保留。

Loading gains starry art, eight hamster-running frames, cycling dots, and a cloud-wing bar. Startup audio and course materials/index/cache prepare across frames; retries/next courses share it. Fixed forbidden runtime import; static launch matches animation frame one. No new courses or physics changes. See [record](experiments/tilt-adventure/VALIDATION-v0.10.4.md).

加载界面改成专用星空插画、八帧仓鼠跑动、循环 Loading 省略点和云翼进度条。启动音频准备与进关的材质、索引、缓存准备分帧执行，失败重试及下一关也使用同一界面。修复原生 SDK 不允许更新循环内 import 的问题；启动静态图与动画首帧一致。没有新增关卡或修改物理手感。验证与设备状态见 [0.10.4 记录](experiments/tilt-adventure/VALIDATION-v0.10.4.md)。

## v0.10.3

Added dedicated launcher cover, ball avatar, and loading art, including selected state. Separate title/launcher exports prevent overwrites. A fixed-directory installer replaces old builds; eight variants and three old/test packages moved to computer archive. Bytecode matches 0.10.2. Installation/startup passed; see [validation](experiments/tilt-adventure/VALIDATION-v0.10.3.md).

新增真机启动器专用封面、仓鼠球小图标与加载画面，选中时也保持新封面。标题素材导出与启动器素材分开，避免相互覆盖。增加固定目录覆盖安装脚本；真机移走 8 个变体及 3 个旧版／测试包，归档到电脑，仅保留当前项目安装。玩法字节码与 0.10.2 一致。安装和启动检查通过，详见 [验证记录](experiments/tilt-adventure/VALIDATION-v0.10.3.md)。

## v0.10.2

Jump threshold falls 0.65g → 0.48g with slight diagonal tolerance, current screen-normal detection, cooldown, anti-repeat, and tilt isolation. All-direction tilt force increases only 3%; comparison braking distance shortens about 2–3%. Coasting, gravity, and landing momentum remain. Added grip/update-rate/braking regressions. See experiments/tilt-adventure/VALIDATION-v0.10.2.md.

抬机跳跃的加速度脉冲门槛从 0.65g 降至 0.48g，稍微放宽斜向抬起的容差，继续按当前机器屏幕法线判断，保留冷却、防连跳及抬起期间的方向隔离。倾斜推力在所有方向仅增加 3%，对照测试的反向制动距离缩短约 2%～3%；无输入滑行、坡道重力及落地动量不变。新增多握姿、多更新频率与制动距离回归检查。详见 experiments/tilt-adventure/VALIDATION-v0.10.2.md。

## v0.10.1

Retained 0.10.0 art, animation, timing, and physics steps while adding conservative screen indexes, terrain-window reuse, consolidated positions, and shared exact draw results. Thirty-three native images match 0.10.0 pixel for pixel; terrain caches compare across 2,400 frames. Hardware record: experiments/tilt-adventure/VALIDATION-v0.10.1.md.

保留 0.10.0 的美术、动画、机关时序和物理步数，继续减少重复工作：增加保守的屏幕区域索引，复用地形窗口列表，合并机关位置计算并在同一次绘制中共享精确结果。固定的 33 张原生画面与 0.10.0 逐像素一致，另有 2,400 帧地形缓存对照检查。真机对比记录见 experiments/tilt-adventure/VALIDATION-v0.10.1.md。

## v0.10.0

Dedicated belt/jet/telescoping-bridge/double-gate/magnet art and irregular stone retain clear edge thickness. Crank-synchronized gears/handles, blades/air, impact springs, recoil/smoke, and height-correct gates animate. Tutorials reuse art. Hardware cost motivates nearby queries, support reuse, metal-image caching, and road preprocessing. See experiments/tilt-adventure/VALIDATION-v0.10.0.md.

为传送带、间歇喷气、伸缩桥、双路闸门和磁力区补齐专用美术；道路改为不规则石板，保留清晰的边缘厚度。新增摇柄同步齿轮与摇把、叶片和风流、碰撞弹簧回弹、炮台后坐和烟圈，闸门动画同步碰撞及遮挡高度。教学复用正式机关素材。针对真机测试发现的复杂关卡开销，增加附近机关查询、支撑结果复用、金属机关图像缓存和道路图块预处理。完整记录见 experiments/tilt-adventure/VALIDATION-v0.10.0.md。

## v0.9.0

Added conveyors, intermittent jets, crank-extending bridges, double gates, and magnetism across 11 new courses, totaling 44. Each has teaching/practice and the finale now has seven checkpoints. Numbers/saves stay, with context hints, animation, and regressions. See experiments/tilt-adventure/WORKSHOP-v0.9.0.md.

继续增加玩法种类：传送带、间歇喷气、摇柄伸缩桥、双路闸门和磁力区。新增 11 关，总数 44；每种新机制有教学和练习，最终长关扩展为七个检查点。保留现有编号和存档。新增上下文提示、机关动画及行为回归检查。详情见 experiments/tilt-adventure/WORKSHOP-v0.9.0.md。

## v0.8.0

The tilt experiment grows to 33 courses with lifts, crank shuttles, adjustable wind, and spring bumpers, reordered from basics through jumps, hazards, controls, cannons, and combinations. Five finale checkpoints, migrated scores, dedicated art/lessons/HUD, chunked roads, and spatial occlusion indexes are added. See experiments/tilt-adventure/REFLECTION.md and VALIDATION-v0.8.0.md. Earlier full/classroom builds remain unchanged.

独立倾斜实验版扩展为 33 关，新增升降台、摇柄横移台、风向控制和弹簧撞块，按基础控球、跳跃、障碍、可控机关、炮台和综合关重新排序。最终关设置五个检查点；保留旧成绩并迁移关卡编号。新增机关素材、首次出现教学和上下文 HUD，启用道路分块缓存与遮挡空间索引。详细过程见 experiments/tilt-adventure/REFLECTION.md，验证与真机连接状态见 VALIDATION-v0.8.0.md。原完整版及课堂版未改动。

## v0.7.9

Current-pose jumping and landing momentum fix. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

当前朝向跳跃与落地动量修复。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.8

Lower input icons and alignment. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

底栏按键图标与对齐。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.7

Arbitrary-grip calibration and road-axis steering. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

任意握姿校准与道路方向映射。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.6

Anytime Help and course goals. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

随时查看帮助与关卡目标。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.5

Tutorial animation and UI refinement. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

教学动画与界面细化。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.4

Overhead input direction. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

球顶方向指示。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.3

Flat-neutral calibration. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

平放操控校准。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.2

Road materials and first-encounter lessons. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

道路材质与首次机制教学。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.1

Integrated title, Settings, and pixel interface. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

整合标题、设置与像素界面。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.7.0

Tilt control and complete loop. Details: [design reflections](experiments/tilt-adventure/REFLECTION.md).

倾斜控球与完整游戏循环。详细过程见 [设计心路历程](experiments/tilt-adventure/REFLECTION.md)。

## v0.6.7

Kept 0.6.6 timbre, volume, and speed mapping, shortening contact spacing from 105–165 to 70–110 ms, about 50% denser, for more continuous slow rolling.

保留 0.6.6 音色、音量与速度映射，仅把滚动接触间隔从 105–165 ms 缩短为 70–110 ms，平均密度提高约 50%，使低速滚动更连贯。

## v0.6.6

Responding to overly dense/strong electronic-speech-like slow sound, contact density drops about 90%, resonance shortens, pitch randomness narrows, and low-speed volume/peaks decrease.

针对低速声音过密、过强且像电子语音的反馈，将基础接触密度降低约九成，共鸣衰减缩短，缩小随机音高变化，并降低低速音量和峰值。

## v0.6.5

Replaced recorded excerpts with synthesized pure rolling contacts: short resonance, no drop or noise bed; density, pitch, and volume follow speed. Class build unchanged.

去掉录音截取，重新合成纯滚动接触声：短衰减共鸣、不加掉落声或噪声底；随球速调整接触密度、音高和音量。课堂版不变。

## v0.6.4

Broken-glass feedback led to a real tile-floor marble recording, extracting continuous roll and treating low/high bands and seams. Other audio/music/control remain; class build stays 0.5.8-core.

根据滚动声像碎玻璃杂音的反馈，改用真实瓷砖滚珠录音，截取连续滚动段并处理低频、高频与循环接缝。其他音效、音乐及操作不变；课堂版保持 0.5.8-core。

## v0.6.3

Remade rolling after listening: removed sustained bass, pitched resonance, and regular beats in favor of irregular short contacts and occasional doubles. Fine rattles replace beeps/thuds. Player volume curve and other sounds stay.

根据试听反馈重做滚动采样：去掉低频持续音、带音高的共鸣和规则节拍，改成不规则的短接触颗粒与偶发双碰声。目标是细碎的“咯啦”滚动，而不是“嘟嘟/咚咚”。播放器音量曲线及其他声音不变。

## v0.6.2

Raised full-game rolling volume and added bright short contacts for audible low-speed glass-like rolling. Other audio/music stay; includes 0.6.1 return/label fixes.

提高完整版滚动音量，加入短促、较明亮的接触声，使低速滚动更容易听清，向玻璃珠滚动的质感调整。其他声音和音乐不变，包含 0.6.1 的选关返回与标签修复。

## v0.6.1

Floating labels draw after the ball and prefer off-track space; ground markers remain below. Direction chooses on preparation to avoid jumping labels. Selection cancel restores its title/game/tutorial/map origin without resetting progress.

点位悬浮标签改在球之后绘制，优先放到赛道外侧，地面标记仍在球下方；标签方向在关卡准备时确定，避免随移动跳动。选关记录入口，取消后返回原主菜单、游戏、教学或地图状态，不重置关卡进度。

## v0.6.0

Only the full game gains a separate title, audio switches, and failure/retry screen. Rolling, jump, landing, falling, wall, charge ticks, checkpoints, finish, and menus get feedback plus quiet looping music. Samples are pregenerated. Classroom stays on deployed 0.5.8 edge fixes without these additions.

仅完整版新增独立开始画面、音效/音乐开关与失败重试界面；滚动、跳跃、落地、掉落、撞墙、蓄跳刻度、检查点、终点和菜单各有声音反馈，附低音量循环音乐。音频预先合成，运行时播放采样。课堂版继续使用先部署的 0.5.8 边缘修复，不加入这些功能。

## v0.5.8

Fixed frozen horizontal position and screen-only falling. Falls retain world coordinates, inertia, gravity, and side collision while the camera stays at the edge. Full/class builds both receive it; four-direction hardware checks passed.

修复滚出边缘后横向位置冻结、只移动屏幕图像导致的穿模观感。掉落继续使用世界坐标、水平惯性、重力和平台侧面碰撞，相机停留在边缘；完整版与课堂版同时获得修复。真机四向出边缘检查通过。

## v0.5.7

Linked hundred-millisecond hardware spikes to bulk collection. Occlusion polygons reuse buffers, distant machinery culls before shape construction, stationary data reuses, and idle-time collection runs. Sustained 450-frame tests in Courses 13/14/class had no game update above 33.33 ms, near 30 FPS. Scope/limits: [performance record](docs/performance-v0.5.7.md).

定位真机数百毫秒尖峰与集中垃圾回收的关系。遮挡多边形改用固定缓冲区，屏幕外机关在构造遮挡体之前剔除，未移动机关复用已有遮挡数据，并利用帧内空闲时间回收。真机第 13、14 关及课堂短关各 450 帧持续输入测试均无超过 33.33 ms 的游戏更新，约 30 FPS。过程和限制见 [性能记录](docs/performance-v0.5.7.md)。

## v0.5.6

Fixed crank input discarded on tutorial close, added zero-force guidance, prewarmed slope/HUD caches, culled offscreen machinery, and reduced allocation. Hardware comparisons retained whole-map caching with chunking off by default. Shortened the classroom label. Complex spikes remain; see [round-by-round record](docs/performance-v0.5.6.md).

修复教学关闭帧丢弃摇柄输入，增加零力度提示；提前准备坡面遮挡与 HUD 缓存，裁剪屏幕外机关，减少临时分配。真机比较后保留整图缓存，分块实验默认关闭。课堂标签避免挤到速度数字。复杂关仍存在偶发尖峰，详见 [逐轮记录](docs/performance-v0.5.6.md)。

## v0.5.5

Added a separate classroom core configuration: short flat route and optional slope, no jumps/dynamic machinery, retaining the full game and optimizations. Added September 10 predictions, observation sheets, and scope-reduction reflection.

增加独立课堂核心试玩配置：短平地路线和可选坡道，关闭跳跃与动态机关；保留完整版本和性能优化。补充 9 月 10 日测试预测、观察记录表和本次收缩范围的思考。

## v0.5.4

Hardware optimization caches tracks, occlusion bounds, and HUD, skips unobstructed masks, and replaces Lua pixel rays/sampling with native polygons. Collision/gameplay stay. Fourteen short hardware checks approach 30 FPS, though Course 13 has one update above 33.3 ms. See [performance](docs/performance-v0.5.4.md) and [reflection](docs/reflections/v0.5.4.md).

真机性能优化：缓存静态赛道、遮挡范围和 HUD；无遮挡时跳过遮罩；使用原生多边形代替 Lua 逐像素射线与图像采样。保留原有碰撞与玩法。14 关短时真机检查接近 30 FPS，第 13 关仍有单次超出 33.3 ms 的更新。完整过程见 [性能记录](docs/performance-v0.5.4.md) 与 [心路历程](docs/reflections/v0.5.4.md)。

## v0.5.3

Selection orders down columns: left 1/2/3, right 4/5/6 on every page. Up/Down stay in-column; Left/Right switch columns and page at edges. Last-page 13/14 both sit left. Navigation-boundary regressions added.

选关改为按列排序：左列 1/2/3，右列 4/5/6，每页保持相同规则。上下在同列移动，左右切换列，在页面边缘继续左右即可翻页。最后一页只有 13/14，均位于左列。补充导航边界回归检查。

## v0.5.2

Corrected local ball/barrier/platform occlusion; shadows/charge lines no longer appear on barrier faces. Low jumps collide with sidewalls, rebound slightly, and keep falling; sufficiently high landings stay unchanged. Added depth/low-jump/normal-landing regressions.

修正球与挡板、平台的局部遮挡，球不再始终覆盖场景；影子和蓄力线条不再画在挡板脸上。补上低空跳跃撞平台侧壁的碰撞与轻微回弹，球会继续下落；高度足够的落地不受影响。新增前后遮挡、低跳撞边与正常落地回归检查。

## v0.5.1

Timed and moving barriers become complete solids with four sides/top instead of one raised face, matching collision height and avoiding apparent walkable sides. Blocking/pushing/cycles stay. Build/regressions passed; Simulator closed and hardware installed.

修正定时挡板和移动推板的外观：由单面竖板改成有四个侧面与顶面的完整实体，显示高度与碰撞高度一致，避免把另一侧误认为能踩的地面。保留既有阻挡、推动与开关周期。编译及回归检查通过，已关闭模拟器并安装到连接的 Playdate。

## v0.5.0

Eight additions bring 14 courses: repeated jumps, timed barriers, folding floors, ferries, rotating floors, moving barriers, and two long combinations. Dynamic support, riding, obstacle collision, paginated selection, maps, and first instruction expand; force/jump rules stay. See [release notes](docs/v0.5.0.md) and [reflection](docs/reflections/v0.5.0.md).

新增 8 关，总计 14 关：连续跳跃、定时挡板、开合地板、往返平台、旋转地板、移动挡板，以及两条综合长路线。加入动态支撑、平台载球和障碍碰撞，扩展分页选关、机关地图和首次教学。保留既有力度与跳跃规则。详见 [版本说明](docs/v0.5.0.md) 和 [设计心路历程](docs/reflections/v0.5.0.md)。

## v0.4.1

Jump instruction appears only in Course 5; Course 6 starts directly and Course 1 keeps basics. No new mechanics. SDK compilation passed; hardware was not retested.

跳跃新技能教学仅在第 5 关出现，第 6 关直接开始。第 1 关的基础教学保留。此修正避免后续跳跃关重复介绍已获得的能力；没有新增玩法。SDK 编译通过，未重新进行真机验证。

## v0.1.0

Original main-v01.lua.bak snapshot: crank target speed, direction input, inertia, floating tracks, checkpoints, and retry.

原始 main-v01.lua.bak 快照。摇柄设定目标速度；方向输入、惯性、浮空赛道、检查点和失败重试。

## v0.2.0

Reconstruction, not a complete historical snapshot: persistent force replaces target speed, gravity is independent, four slope/turn tests, and strong reverse braking remains. Compatibility code recreates behavior, not an exact historical source copy.

重建版本（不是当时完整快照）：目标速度改为持续推进力度；重力独立于油门；四个坡道/转弯测试关；保留强反向刹车。为重现历史行为使用了兼容适配代码，不能视为逐字还原。

## v0.3.0

Reconstruction, not a complete historical snapshot: clockwise accumulated force/rapid retraction, counterclockwise jump charge/A jump, high-force reversal clearing, no brake bonus, six courses, and rotating hamster. UI rolls back from records, not an exact copy.

重建版本（不是当时完整快照）：顺摇累积推进力度，停摇快速回缩；逆摇蓄跳，A 起跳；高力度大幅反向清空推进条；取消额外刹车；六关及滚动仓鼠。界面根据迭代记录回退，不能视为逐字还原。

## v0.4.0

Original source snapshot at this stage: jumping off for four courses, introduced from fifth; selection, teaching, clear POWER/JUMP bars, raised signs, and map markers.

当前原始 source 快照：前四关关闭跳跃，第五关起引入跳跃；新增选关界面、教学提示、清晰 POWER/JUMP 条、架高标牌和地图标记。
