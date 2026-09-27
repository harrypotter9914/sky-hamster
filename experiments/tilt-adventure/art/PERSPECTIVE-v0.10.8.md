# v0.10.8 spatial artwork

The game uses the orthographic mapping `screenX = .9(x-y)`, `screenY = .45(x+y)-.65z`. The cannon model projects circular cross-sections in a tilted tube plane. Its rings therefore become ellipses, and its cylinder foreshortens as it turns toward the viewer. A flat bitmap rotation cannot reproduce that behavior.

`source/cannon_model.lua` rasterizes the tube, bands, hollow muzzle and pins into 61 cached views. The round pedestal is a separate fixed layer. The tube's forward axis is tangent to the shared exit trajectory. The visible mouth center, projectile center and guide origin use the same model. This iteration uses code-native solid rendering; it does not claim newly generated bitmap artwork. Existing generated road and machinery materials remain in use.

Fan housings use a projected cylinder in a vertical plane. Three blades spin inside that same plane; when the fan becomes edge-on, the disk narrows. The stand and footing remain on the road. The wind effect starts above the road at the outlet.

Lifts use an open rear landing and separate support posts. The tall solid backdrop from v0.10.7 is intentionally removed. Ground slabs and machinery retain distinct layers, including foreground slab overlap at the near rotating-bridge bank. Native previews and the 12-family audit are stored beside this document.
