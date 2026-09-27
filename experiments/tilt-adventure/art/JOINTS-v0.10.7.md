# v0.10.7 machinery poses and joins

This iteration reuses the generated v0.10.6 material panels, barrel and mechanical parts. No new image-generation output is claimed. Cannon art pivots at its rear saddle; the base stays fixed. Lift and ferry decks follow their collision footprint, with structural parts below the road layer.

Rotating-bridge frames are produced with the actual Playdate SDK renderer and current generated textures:

1. Run `tests/build-rotor-art.ps1` and open `builds/rotor-art.pdx` in the native Simulator.
2. Wait for `rotor-art-report.json` in its Simulator datastore to report 360 completed frames.
3. Run `python tests/pack-rotor-art.py`. It losslessly assembles those exports into two transparent 10 × 18 image tables.

The 160-unit bridge uses 228 × 136 cells and the 192-unit bridge uses 266 × 156 cells. Each table contains 180 one-degree poses; the bridge is symmetric after 180°. Production selects the nearest visual degree and keeps continuous collision geometry. Both frame shapes and the collision width use the same bank-clearance formula. At alignment, the bridge ends meet the banks exactly. The visible short metal shoes explain the slight width adjustment while turning.

`cannon-v0.10.7.gif` and `crank-v0.10.7.gif` are native review frames assembled as animation previews, enlarged 2× with nearest-neighbor sampling. `joins-v0.10.7.png` groups native 400 × 240 screenshots of the lift and manually controlled ferry.
