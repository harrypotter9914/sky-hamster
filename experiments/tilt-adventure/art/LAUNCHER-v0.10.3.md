# 0.10.3 — 真机启动器封面

新增独立封面：左侧 SKY HAMSTER 标题，右侧仓鼠球、浮空石路和月亮。没有空白菜单木牌。列表模式使用单独的圆球仓鼠头像，保证小尺寸仍能辨识。

## 素材与导出

- `launcher-cover-original.png`：封面原图，参考当前 `source/title-scene.png` 的角色与石路风格。
- `launcher-icon-original.png`：专门的小图标原图。
- `../source/launcher/card.png`：350×155，全黑白、不透明。
- `../source/launcher/icon.png`：32×32，全黑白、不透明。
- `../source/launcher/launchImage.png`：400×240，封面按原生像素居中。
- `card-highlighted/1.png` 至 `3.png` 与静态封面一致，保证选中后不会回到旧的木牌缩略图；不宣称有新增封面动画。

使用 `prepare-launcher.ps1` 确定性缩放并导出黑白图片。`prepare-title.ps1` 只处理游戏内标题画面，避免重新导出标题时覆盖专用封面。SDK 的 pdxinfo 保留 `imagePath=launcher`，编译后对应资源为 `.pdi`。列表模式显示图标和名称，卡片模式显示大封面，这是系统两种视图的区别。

## 制作提示词

模式：内置图像生成工具。成品原图已保存到本项目，下面记录最终使用的提示词。第一张图标候选对比度不足，未采用；第二张采用实心黑色五官，缩到 32×32 后仍然清楚。

### 封面

Use case: stylized-concept. Asset type: finished Playdate launcher cover card, ultra-wide 350:155 aspect ratio, strictly black-and-white 1-bit pixel art. Reference image: the attached current Sky Hamster title scene supplies the exact cute hamster-in-clear-ball character, chunky irregular stone floating road, moonlit sky, bold playful SKY HAMSTER lettering and overall art direction. Create a NEW dedicated launcher cover, not a screenshot or menu. The only text is 'SKY HAMSTER', large, bold and extremely readable, occupying the left half with comfortable spacing, no subtitle. A happy hamster in a transparent round ball dominates the right foreground, rolling on a thick isometric stone platform, with a simple winding road into the starry sky and one distant moon. Make the ball silhouette, hamster ears, eyes and paws clear at thumbnail size. Keep the scene uncluttered: bold outlines, broad white surfaces, sparse deliberate pixel stipple, no noisy fine detail, no grayscale or color. No empty wooden menu boards, no buttons, no UI, no thin microtext, no watermarks. Full-bleed art, leave enough margin around all text and ears for a 350 by 155 px card. The final result must be a coherent polished cover that matches the reference game. Render in the specified wide aspect ratio.

### 图标

Create a clean, bold monochrome game app icon of a cute hamster face inside a circular glass ball, centered on a solid black square background. Simple flat sticker illustration designed to be legible after shrinking to 32x32 pixels. The hamster head is solid white, with two solid BLACK oval eyes, a BLACK nose and BLACK smiling mouth, and two round ears with BLACK inner ear centers. Surround the face with a thick black gap, then a thick white circular ring suggesting the ball. A small white highlight on the upper right of the ring. Strong simple geometry, broad solid shapes, no fine fur, no texture, no stippling, no thin outlines inside the white face, no gradients, no transparency, no text, no other objects. All facial features MUST be solid black and clearly visible against the white face. Friendly hamster proportions, full face looking forward. Pure white and pure black only. Leave a small black margin around the ball.
