# 0.7.2 asset notes

The title road and oversized cannon were produced with the built-in image generation tool. Runtime exports use deterministic resizing, one-bit thresholding and alpha preservation, with no per-frame image scaling in gameplay.

- Title master: `title-v3-original.png`; export: `../source/title-scene.png`; script: `prepare-title.ps1`.
- Cannon master: `cannon-barrel-original.png`; exports: `../source/cannon-barrel.png` and `../source/cannon-title.png`; script: `prepare-cannon.ps1`.
- UI font: Playdate SDK resources, `Asheville / Asheville Sans 14 Bold`. Original font and atlas retained under `../source/fonts/` with the runtime basename `ui-bold`.
- Pixel device poses, UI icons, road masonry, bridge rails and hazard markings are native drawing assets. Cannon aim poses are cached at level entry.

## Title edit prompt

Use case: precise-object-edit. Edit this existing Sky Hamster title illustration, preserve the exact composition, logo SKY HAMSTER / TILT ADVENTURE, cute hamster ball, black night sky, moon location, and both blank menu signs at left. ONLY improve road and stone material readability for an actual 400x240 ONE-BIT Playdate game screen. Road must be clearly textured cut-stone paving, with strong BLACK mortar lines, black hairline cracks, chamfered edges and deliberate chunky black stipple/shadow pixels on white. The winding road on the right currently washes out to solid white at small size: fix this. Make top paving and cliff sides distinct. Use strictly BLACK and WHITE, NO GRAY shading or gradients that disappear when thresholded. Keep stone chips, masonry joints and tread readable when reduced to 400x240. Avoid excessive fine noise. Do not add clouds, flags, cannons or any new objects: those are independent game sprites. Preserve the logo and hamster, black sky and overall scene layout. Both signs must remain blank white inside with strong dark borders. Output landscape same 5:3 composition, high contrast polished pixel art.

## Cannon prompt

Asset: polished black-and-white pixel-art cannon BARREL sprite for a cute hamster-in-a-glass-ball Playdate game. Transparent background. Draw a single SHORT, VERY FAT, oversized cylindrical toy cannon barrel, pointing horizontally RIGHT and seen in three-quarter view so the large round open muzzle is visible. The barrel must be wide enough to swallow a hamster ball: short length, huge circular bore, thick rounded muzzle lip, bulbous closed rear, two broad iron bands, clean rounded chunky silhouette, a few bold white glints on black metal and sparse one-bit hatching. Charming storybook / retro platformer design matching Sky Hamster: black and white only, no gray gradient, no colors, crisp intentional pixels that stay readable at 64x48. Absolutely no wheels, no chassis, no circular platform, no stand, no balls, no smoke, no text, no other objects. The isolated fat barrel will be mounted on a separate small wooden saddle in code. Center it with a small transparent margin. NOT a long thin military artillery tube; a cute oversized stubby barrel cannon.
