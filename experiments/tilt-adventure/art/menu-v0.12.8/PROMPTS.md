# 0.12.8 菜单素材

使用内置图像生成完成原图，保留所选母版；固定尺寸导出由 `../prepare-release-menu.py` 完成。运行时读取黑白 PNG，不进行生成或非等比缩放横版按钮。

## 提示词规格与所选结果

- `steering-frames.png`：纯黑白像素 Playdate 机器姿态图集，正面中立、左右前后翻转姿态；同一机器、右侧摇柄、无文字，另有玻璃仓鼠球滚动帧，白底、易于分离。实际输出为第一排四台、第二排五台、第三排三个球；导出九张 50×54 设备和三张 24×24 球。左翻采用可辨识的左倾姿态，不用方向错误的第五张。
- `card.png`：Sky Hamster 游戏风格的黑白像素机械卡片，金属角、铆钉、双线边缘，白色留空内页，无文字或场景。用于 180×140 操控对照卡片。
- `lock.png`：同款游戏风格的清晰粗线像素锁图标，透明背景，内部白色保留，用于 20×25 未解锁路线图标。
- `road.png`：同款游戏风格的斜视石砖道路小块，黑白像素纹理、厚边、透明背景，无文字和角色，用于 90×45 操控示意。
- `start-button.png`：独立生成的宽横版菜单框；生成规格为 7:1、最终 360×51，细双层边缘、四个小角帽与圆铆钉、下沿厚度、大块白色文字安全区。不是将竖向卡片压扁。按实际母版比例缩放并居中到 360×51 白底，水平与垂直笔画自然一致。

## 独立横版按钮的完整生成提示词

Use case: ui-mockup. Asset type: a SINGLE dedicated long horizontal menu button for the actual 400x240 one-bit Playdate game Sky Hamster. This is NOT a resized tall card. Design naturally for a wide 7:1 rectangle that will be used at 360 by 51 pixels. Charming polished chunky BLACK AND WHITE pixel-art sign frame matching a hamster glass-ball game, stone sky roads and little mechanical rivets. A long rounded WHITE rectangular face with crisp black double edge, four SMALL balanced metal corner caps, tiny circular rivets, a subtle solid black lower edge for thickness, no detailed squashed decoration. The frame should be only 3-4 pixels thick at native size, corners no larger than 8 native pixels. Large CLEAN blank white interior for text: safe rectangle must span at least 88 percent width and 70 percent height. Draw this as a thin wide sign with actual correct wide proportions, not a stretched ornate square. Center a single complete button on WHITE canvas. Wide landscape canvas; the actual button can be in a horizontal white band across its middle; its own proportions must be 7:1. No text, no letters, no icons, no balls, no art in the interior, no surrounding scenery, no gray, no gradient, no shadow outside. Consistent clean pixel-art stroke thickness on vertical and horizontal sides, not vertically compressed.

## 导出

导出目录：`../../source/menu-art/`。保留机器姿态共同画布，保留玻璃球轮廓内白色；仅使轮廓外白底透明。文字使用实际游戏字体绘制，避免生成文字在低分辨率下不可读。动画依照固定姿态帧切换，并以同一输入演示两种方向映射。
