# 0.10.6 — Physical-looking machinery and relative rolling

## Behavior and art

Generated material atlas, mechanical part atlas and cannon barrel are stored in `art/`; thirteen production bitmaps live in `source/structures/`. See [art specifications](art/STRUCTURES-v0.10.6.md) and [native review sheet](art/mechanisms-v0.10.6-review.png).

Deck tops follow their real collision footprint and the existing 12-pixel slab thickness. Moving ferries gain a bogie, twin rails and framed deck; lifts gain a telescopic support and housed transmission. Automatic boards no longer use a gear icon floating above the standing surface. Rotor bearings, retracting bridge supports, framed trapdoors, shutter faces, conveyors and smaller device bases share materials. Hatches fold below the rim as the timed opening begins and ends. Fan, spring, nozzle, magnet, winch and switch illustrations retain their existing animations. Cannon art uses a round stepped base and curved cradle; only its barrel recoils.

The ball's roll animation now uses displacement after platform carry, not total world displacement. Passive ferry and rotor transport no longer rotates the ball; its own surface motion still does. Jump launch momentum, course geometry, timings, audio files and control rules are unchanged.

Tutorials reuse the current machinery renderer for lift, ferry/slider, rotor, trap, gate, sweeper and belt. Native review caught a trap gearbox intruding into the caption row; the demonstration layout was moved up. Long rotating decks use full swept projection bounds so diagonal poses are not clipped.

## Verification

- SDK release and review builds compile. Native Simulator exported the existing UI/world review set plus 40 new machinery states; selected native 400 × 240 frames were visually inspected. This is a visual review, not a full human playthrough.
- `python tests/check_relative_roll.py` passes the complete host regression chain, plus passive/active relative rolling on ferry and rotor, 73 long-bridge rotation bounds and 36 seconds each of gate/hatch/belt animation without new image allocations after preparation.
- Existing slope, collision, platform lip, jump, docking, cannon route, tutorial, navigation, audio event and hearing-bound checks pass. Host graphics are mocked, so they do not replace native visual inspection.

## Performance findings and fixes

The first draft dropped to 25.20 FPS in the heaviest sample (`tests/mechanisms-perf-draft-v0.10.6.log`; seven completed rows captured before profiling). Per-kind hardware timing identified gate and trap rendering as large costs, about 3.54 and 2.29 ms per measured frame in that instrumented workload. Static base caching alone was insufficient. The raw intermediate profiles are retained.

The final renderer prepares gate raster heights, hatch leaves and belt frames during loading. Rails, bases and deck images are reused; gear orientations are prepared once. Gate raster height is rounded to the nearest screen pixel, while collision keeps continuous physical height. It does not change opening thresholds or time. Structural caches from the previous course are released. Rendering still uses the existing conservative screen index and live world time.

Final uninstrumented physical Playdate workload: same eight camera samples as 0.10.5, 179 timed intervals each, audio enabled. Source: `tests/mechanisms-perf-v0.10.6.log`.

| Scene | 0.10.5 FPS | 0.10.6 FPS | Frame p95 ms | Longest frame ms |
| --- | --- | --- | --- | --- |
| 1 | 30.06 | 30.22 | 35 | 37 |
| 2 | 29.94 | 29.98 | 36 | 40 |
| 3 | 29.84 | 29.80 | 36 | 45 |
| 4 | 29.85 | 29.90 | 36 | 41 |
| 5 | 28.41 | 29.02 | 38 | 49 |
| 6 | 27.70 | 28.82 | 38 | 40 |
| 7 | 29.82 | 30.03 | 36 | 44 |
| 8 | 29.81 | 30.06 | 36 | 38 |

Final range is 28.82–30.22 FPS, compared with 27.70–30.06 in 0.10.5. The heaviest selected scene is 28.82 FPS after the draft's 25.20. The longest final sampled frame is 49 ms. These short workloads do not guarantee constant 30 FPS, cover every possible camera position, or replace checking gesture feel on the device.

## Installation

The normal v0.10.6 / build 42 release replaces the temporary diagnostics at `/Games/sky-hamster-tilt.pdx`, preserving the bundle ID and player data. See `tests/device-release-v0.10.6.log` for startup evidence. No additional version-named game folder is installed.
