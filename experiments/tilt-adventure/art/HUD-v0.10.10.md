# 顶部机械仪表板

顶部固定为 400×43 像素。关卡牌、计时、掉落次数在上排；投影倾斜方向、力度、跳跃恢复、实际速度在下排。底部控制栏和中间世界画面不改动。当前倾斜版本的跳跃条是恢复进度，不是早期方案的弹簧蓄力。

六枚图标使用内置 imagegen 生成，原始图为 `hud-emblems-v0.10.10-original.png`。`export_hud.py` 将六格素材裁切、缩放、二值化并居中输出为 `../source/hud-{flag,tilt,jump,speed,clock,falls}.png`，每枚 18×18，内容不超过 16×16。运行时不缩放。固定边框和数据排版使用原生像素绘制，保留清晰文本和真实数值。

新增字体来自现有 Playdate SDK 的 Roobert 资源：11 Bold 用于关卡名，11 Mono Condensed 用于等宽读数，9 Mono Condensed 用于短标签。原字体文件与图集保留名称。底栏继续使用既有字体和缓存图像。

力度条 15 格、跳跃条 9 格，空格保留下沿刻度。各格状态提前缓存；计时、速度、掉落数仅在整数变化时重绘共享读数图。力度方向点仍对应斜视地图投影。

原生对照图：`hud-before-after-v0.10.10.png`。全部 44 个关卡牌：`hud-course-audit-v0.10.10.png`。

## 生成提示词（内置工具）

Use case: stylized-concept. Create a production sprite atlas for Sky Hamster, a black and white 1-bit Playdate game about a hamster in a glass marble rolling on sky-island stone paths and clockwork platforms. EXACTLY SIX isolated square HUD emblem sprites, arranged in a perfectly regular 3-column by 2-row grid on white background, each cell with generous equal margin, no text, no dividers. Top row left: a waving checkered finish flag on a stout short pole; top middle: a charming chunky mechanical compass dial with an upward arrow, indicating tilt thrust; top right: a coiled spring propelling a round marble upward. Bottom row left: a round glass marble rolling right with two short speed trails; bottom middle: a chunky pocket stopwatch with top button; bottom right: a small hamster face inside a round marble with a small down chevron below, indicating falls. Art direction: adorable premium monochrome handheld pixel art, bold pixel silhouettes, large deliberate black-and-white clusters, consistent thick outlines and white interior highlights. Strict pure black and white, NO gray, gradients, antialiasing or texture noise. All sprites front-facing flat emblem icons with the same visual weight and scale, usable as tiny 18x18 pixel sprites when exported. Design each at an implied 18x18 logical pixel grid enlarged with nearest-neighbor block pixels. No tiny facial detail or narrow lines. No letters, numbers, extra elements, shadows outside emblem. This is the actual reusable HUD sprite sheet, not a mockup.
