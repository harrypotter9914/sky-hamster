# Mechanism art — 0.10.6

Mode: built-in image generation. Three selected originals are stored alongside this document. The following normalized prompt specifications describe the final asset set; they are reproduction briefs, not a verbatim transcript of tool calls.

## Material atlas

Output: `mechanical-surfaces-original.png`; opaque 4-column by 2-row atlas. A unified monochrome sky-workshop style for a 400 × 240 Playdate ball game. Eight separate orthographic square material panels, reading left to right: pale deck boards in riveted steel; heavy X-braced side beam; split trapdoor hatch; vertical industrial gate; conveyor tread; circular bearing plate; control socket; parallel carriage rail. Crisp black outlines, pale readable surfaces, generous chunky structure. No floating gear icons, labels, lettering, perspective scene, characters or unrelated objects. Textures must map to real collision surfaces instead of painting oversized platforms over the scene.

## Structural parts

Output: `mechanical-structures-original.png`; transparent 2 × 2 atlas, consistent isometric view. Top left: telescoping lift pillar with a substantial foot and piston. Top right: under-platform carriage/bogie with rollers and an axle, no walking deck. Bottom left: cannon pedestal consisting of a round stepped foot and curved saddle cheeks, no cannon barrel and no square block. Bottom right: compact enclosed gearbox with an exposed wheel position integrated into its housing. Same riveted black metal and clean white highlights as the material atlas. Strong silhouettes at small native sizes, no text, no background, no loose decorative gear above the structure.

## Cannon barrel

Output: `cannon-v2-original.png`; transparent horizontal barrel, muzzle pointing right. Oversized rounded cannon tube wide enough for a hamster ball, large hollow muzzle, broad reinforcing bands and bright readable rim. Consistent monochrome material language. Barrel only: no base, wheels, ground, smoke, labels or scenery. Allow rotation in the game without baking a particular pedestal into the barrel.

## Production export and animation

`prepare-structures.ps1` crops the atlas cells, trims transparent part bounds, fits target sizes and thresholds to the Playdate black/white palette. Eight surface images are 64 × 64. Parts: pillar 48 × 72, bogie 60 × 36, cradle 70 × 58, gearbox 28 × 30 and barrel 76 × 34. Final files are in `../source/structures/`.

`structures.lua` projects the generated panels onto actual top and side faces. Side thickness matches the existing platform slab; rail/gearbox/support parts stay below or beside the standing surface. Animated components remain separate: housed gears use 16 orientations, belts scroll their surface, lift pillars extend with actual height, hatch leaves fold below the rim, and only the cannon barrel recoils. The original fan, nozzle, spring, magnet and winch illustrations remain in use, with matching structural bases and updated surroundings.

Tutorials reuse the same renderer for the moving deck, lift, rotor, gate, sweeper, trap and conveyor. These are runtime animations assembled from generated parts, not independently generated full-screen frames. Native screenshots are required to inspect the final 1-bit result; the large originals alone do not demonstrate readability.
