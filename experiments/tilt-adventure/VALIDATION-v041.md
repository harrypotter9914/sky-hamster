# Tilt Adventure 0.4.1 — preserve effects, remove repeated work

Release 0.4.1 / build 14 was installed and launched successfully on the physical Playdate on 2026-09-26 after testing. The workload was replaced at `/Games/sky-hamster-tilt.pdx`. Startup checks passed with no captured error. Local archive: repository-root `builds/sky-hamster-tilt-v0.4.1.zip`.

## Scope

No textures, animation frames, effects, courses, controls, physics substeps or target refresh rate were removed or reduced. This patch changes lookup and reuse paths:

1. Conservative screen-space bounds include each mechanism's full movement, rotation, height, labels and effects. Camera-cell views preserve original mechanism order and filter distant draw/occlusion candidates. Offscreen motion is still evaluated from world time when it returns.
2. Terrain retains its visible/nearby chunk lists while the camera remains in the same chunk window. The same chunks are drawn in the same order and at the same fractional positions. Prefetch still builds at most one extra chunk each frame, and eviction behavior is unchanged.
3. The historical pose wrappers are flattened into one equivalent dispatch. Within a single render pass, art and occlusion reuse the exact pose for the same world time. Physics and queries for other times calculate independently; there is no angle/frame quantization.
4. Floor-height queries inspect nearby lifts directly. Other mechanism types cannot override course height, so their support queries are unnecessary on this path.

## Correctness and appearance

`tests/check_render_optimization.py` includes the full existing regression suite plus:

- 2,400 terrain frames against the checked-in 0.4.0 reference: identical drawn chunks, order, subpixel positions, cache misses and eviction counts.
- Visibility coverage across all 44 courses, sampled camera cells and four motion phases.
- Exact pose equality against the historical wrapper chain, with and without per-render reuse.
- Floor-height equality across mechanism boundaries, time phases and partly raised lifts.

Native SDK review exports passed `tests/check_native_frames.py`: all 33 fixed gameplay frames are pixel-identical to the 0.4.0 baseline at commit `376f332`. Reference RGB hashes are retained in `tests/fixtures/v040-frame-hashes.json`. This is direct evidence for the sampled scenes, not a claim that every possible future frame was exhaustively compared.

The SDK release and isolated review/workload packages compile successfully. No diagnostic wrappers enter the shipping source. Tests run on the physical Playdate via COM4; production is reinstalled after workloads finish.

## Hardware comparison methodology

Use `tests/build-perf.ps1` for the full-route camera/cache stress workload, or add `-Smooth` for the same eight 90-world-unit/second scenes used in 0.4.0. Each segment reports 179 frame intervals at a target 30 Hz. These are automated camera/physics/render workloads with stubbed inputs, not complete human playthroughs or gesture-feel tests.

`-Profile` is diagnostic only, sampling the busy wind/spring/gate area. Nested layer timings include their children and must not be summed. Early exploratory diagnostic logs included course-entry preparation; the final diagnostic harness resets counters after selection. Release comparisons use uninstrumented frame intervals instead.

Baseline logs: `device-final-stress-v040.log` and `device-final-smooth-v040.log`. Final patch logs: `device-final-stress-v041.log` and `device-final-smooth-v041.log`. Other `v041` logs capture intermediate investigations and are not the final release comparison.

## Full-route camera/cache stress results

| Route | 0.4.0 FPS | 0.4.1 FPS | 0.4.1 p95 frame ms | 0.4.1 max frame ms |
|---|---:|---:|---:|---:|
| 14 | 30.04 | 30.03 | 35 | 44 |
| 19 | 30.12 | 30.10 | 36 | 37 |
| 24 | 30.10 | 29.99 | 35 | 41 |
| 30 | 28.95 | 29.29 | 38 | 46 |
| 34 | 29.92 | 29.92 | 37 | 50 |
| 36 | 29.86 | 29.95 | 38 | 43 |
| 40 | 29.91 | 29.98 | 36 | 56 |
| 44 | 24.70 | 26.71 | 49 | 60 |

The final course gains about 8% average FPS in this workload. Its p95 frame interval falls from 53 to 49 ms and maximum from 62 to 60 ms. Individual maxima do not improve in every short sample. Lua heap at the final report rises from approximately 1,869 KB to 2,009 KB as expected from additional cached views/lists.

## Normal-speed hardware samples

| Route / starting region | 0.4.0 FPS | 0.4.1 FPS | 0.4.1 p95 frame ms | 0.4.1 max frame ms |
|---|---:|---:|---:|---:|
| 30 / (96,112) | 29.98 | 30.00 | 35 | 52 |
| 44 / (48,80), lift | 29.47 | 30.01 | 35 | 40 |
| 44 / (480,80), high road | 28.52 | 30.00 | 36 | 39 |
| 44 / (1264,80), bridge | 29.06 | 29.99 | 35 | 40 |
| 44 / (1752,112), ferry | 27.65 | 29.33 | 43 | 47 |
| 44 / (2128,112), wind/spring/gate | 26.34 | 29.17 | 44 | 55 |
| 44 / (4800,112), late workshop | 29.68 | 29.86 | 36 | 42 |
| 44 / (5600,240), late workshop | 29.81 | 29.95 | 36 | 41 |

The previously weakest normal-speed scene improves from 26.34 to 29.17 FPS; its p95 falls from 49 to 44 ms. These final samples are approximately 29–30 FPS, while brief long frames remain.

## Limits

Caching trades a small amount of memory for less repeated work. The existing terrain eviction remains in place. Reported Lua heap values do not include all native bitmap/system memory. Short samples can read slightly above 30 FPS due to millisecond timing. Frame-time spikes, course-entry preparation, physical controls and a complete human playthrough must be distinguished from average frame rate; these measurements do not establish that every scene is stutter-free.
