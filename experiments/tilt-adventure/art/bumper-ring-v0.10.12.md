# 圆形弹力护圈

本版把竖直弹簧替换为低矮圆形护圈，保留四周碰撞后径向反弹。接触点以地面底座为中心，外沿半径 14，高度 10；球碰撞半径 9。美术打包到 48×36 透明画布，地面锚点 (24,24)，主体 36×25。取消额外方形装饰底座，避免出现第二个不对应碰撞的边界。

撞击使用同一个 `hitAt` 事件启动声音与 0.36 秒外扩／回弹动画。八帧在加载时准备，最大外扩 14%。外扩仅用于表现，不增加碰撞半径。遮挡采用当前帧对应的外形与高度。靠近、擦过有效范围之外、跳过顶部都不会启动声音或动画。

原素材：`bumper-ring-v0.10.12-original.png`。游戏素材：`../source/machine-ring.png`。生产打包脚本：`export_bumper.py`。原生动画检查：`ring-pulse-strip-v0.10.12.png`、`ring-pulse-v0.10.12.gif`。

## 素材提示词

Create ONE game sprite asset for a 1-bit black and white Playdate game, transparent background. Low squat circular mechanical pinball bumper / elastic bumper ring, viewed from isometric overhead camera (ground circles project as ellipses with width:height exactly 2:1). NOT a tall vertical coil spring, NOT a jump pad. A very low circular fixed metal foot at ground level, with a thick white rubber elastic ring surrounding its entire vertical SIDE circumference; small dark recessed center with a simple metal hub. The horizontal sides receive impacts from a rolling marble from any direction and rebound sideways. Visual design like a cute finely crafted miniature mechanical toy, crisp chunky pixel clusters, white faces black outlines, restrained black shadow on near side, tiny 4 radial seams maximum; no text, no arrows, no surrounding floor tile, no grid, no detached shadow, no perspective background. Designed to be recognizable at only 36 pixels wide and 25 pixels tall, avoid fine texture and thin busy lines. Frame the full sprite centered with generous transparent margins. The base foot and outer ring have the SAME diameter, no projecting ledge. Circular base diameter 28 world units, total height only 10 world units, camera projection horizontal scale .9, ground vertical scale .45, height vertical scale .65. Emphasize a broad clean horizontal bumper ring around a short drum, no top button or vertical spring. All opaque pixels must be pure black or pure white. Deliver transparent PNG sprite.
