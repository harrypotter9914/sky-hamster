# 0.8.0 machinery assets

Prepared with the built-in image generation tool. Original PNGs are retained here. `prepare-machines.ps1` alpha-crops, fits, thresholds to one bit and preserves transparency using System.Drawing. Runtime dimensions: lift 116×86, slider 144×96, fan 52×52, bumper 44×44. Gameplay draws cached images at native size; tutorials cache smaller exports at startup. Existing cannon and Playdate artwork are reused.

## lift

Mode: generate; transparent background. Original: machine-lift-original.png. Runtime: ../source/machine-lift.png.

Use case: stylized-concept. Asset type: transparent game sprite for a 1-bit Playdate isometric rolling hamster game. ONE small mechanical elevator platform, a square deck seen in clean isometric projection 2:1 diamond, thick chamfered metal edges with black hazard stripes, a clear uncluttered light wood or steel deck with sparse rivets, a small chunky gear and crank station at BACK LEFT edge, short visible telescoping piston under the deck. No tall rails, no fences, no hamster, no lettering, no extra background. Black and white only, bold chunky pixel art, no gray, strong clean silhouette readable at 110x80 pixels. Transparent background. Platform should look polished and playful, not a checkerboard, viewed from upper front, diamond top wider than tall. Single entire object centered.

## slider

Mode: generate; transparent background. Original: machine-slider-original.png. Runtime: ../source/machine-slider.png.

Use case: stylized-concept. Asset type: transparent 1-bit Playdate game sprite. ONE compact crank-driven sliding ferry deck for an isometric sky hamster game, square 2:1 diamond top seen from above front, clean light deck of three wide wooden planks in a thick black metal chassis with chunky brass-style gears rendered black and white at the REAR edge. Small hand crank at rear corner; no long tracks beyond the object, no tall rails blocking the center, no checkerboard texture. Bold polished black-and-white pixel art, sparse detail readable at 110x64 pixels, white solid deck interior, black outlines and shaded side facets. No characters, text, scenery or cast shadow outside sprite. True transparent background, centered complete single object.

## fan

Mode: generate; transparent background. Original: machine-fan-original.png. Runtime: ../source/machine-fan.png.

Use case: stylized-concept. Asset type: transparent game obstacle sprite. ONE whimsical mechanical wind blower for a black-and-white isometric Playdate sky hamster game. Chunky round fan housing on a low sturdy bolted pedestal, three broad clearly visible propeller blades inside a thick protective circular ring, no thin cluttered wire mesh, aimed toward front-right. Clear bold monochrome pixel art, only solid black and white, charming toy-like proportions, readable at 52x52 pixels. White highlights separate fan blades from dark interior. No gusts, letters, background, floor, other objects or characters. Transparent background, complete object centered.

## bumper

Mode: generate; transparent background. Original: machine-bumper-original.png. Runtime: ../source/machine-bumper.png.

Use case: stylized-concept. Asset type: transparent obstacle sprite for 1-bit Playdate isometric rolling marble game. ONE spring bumper, squat round pinball-style mushroom cap on a visible thick spring and small bolted circular base, viewed from above at isometric angle. Wide white domed cap, thick black rim, one bold black ring design, stout mechanical spring and base. Polished chunky monochrome pixel art, black and white only, no gray or fine hatch, clear at 44x44 pixels. No text, stars, effects, characters, ground or background. Center complete single object, true transparent background.
