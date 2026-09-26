# Tilt Adventure 0.10.0 — visuals, animation and device validation

Release status: 0.10.0 / build 13 installed and launched successfully on the physical Playdate on 2026-09-26. The shipping bundle replaced the workload in `/Games/sky-hamster-tilt.pdx`; startup checks passed and no error was captured. Local release archive: repository-root `builds/sky-hamster-tilt-v0.4.0.zip`.

## What changed

The 44-course campaign is unchanged. Five workshop mechanisms now have dedicated black/white runtime sprites. Earlier machinery retains its existing artwork with animated components. Ordinary roads use pale irregular stone slabs, chipped joints and exposed dark sidewalls. The original game and classroom edition are unchanged.

| Mechanism | Appearance and motion |
|---|---|
| Conveyor | Dedicated drive motor/roller; belt markings move with transport direction; rotating transmission |
| Timed jet | Dedicated elbow nozzles; moving steam arcs appear only during the force window |
| Extending bridge | Dedicated cable winch and crank; visible deck grows with its support width |
| Paired gate | Dedicated switch pedestal; smooth mutually selected shutters; collision/occlusion follow current shutter height |
| Magnet | Dedicated horseshoe electromagnet and pedestal; pulsing field arcs |
| Lift | Existing detailed lift; moving column and platform; gear/handle follow accumulated physical crank angle |
| Manual ferry | Existing detailed chassis; deck travels with crank input; transmission follows input |
| Fan | Existing housing; separate cached rotating blades and advecting wavy airflow aligned to force direction |
| Spring bumper | Existing spring art; compression/rebound triggered by an incoming collision, not a perpetual timer |
| Cannon | Existing aim orientations; brief recoil and expanding smoke aligned with the barrel |
| Automatic ferry / rotating deck | Geometry-matched metal rails/panels; transmission follows travel/rotation and stops during pauses |
| Moving panel / timed gate | Riveted metal faces, warning stripes and driven gears; timed gate retracts smoothly |
| Vanishing floor | Existing reinforced deck and timing; blinking warning rivets before the gap opens |

Tutorials reuse the dedicated workshop sprites and moving components. The wind station sign was moved above the fan to expose its rotor. See [art sources, prompts and native screenshots](art/VISUALS-v0.10.0.md).

## Checks

- SDK compilation passed for the release, isolated native UI review and device workloads.
- `tests/check_physics_index.py` includes the full existing controls, UI, tutorials, campaign and physics regressions. Added cases verify crank stop/reverse, actual lift travel, impact-triggered spring state, half-open shutter clearance and height-matched collision.
- Indexed support, forces, wall contact and platform-side contact were compared against full-course reference queries across 44 courses, four time phases and seven offsets around every mechanism.
- Native Simulator exports cover new machinery at four animation phases, road surfaces, teaching frames, old machinery and existing UI states. A gameplay contact sheet is retained in `art/review-v040.png`.

## Hardware methodology

Physical Playdate detected on COM4. Test bundles were copied through its USB data disk and launched with `pdutil`. Native frame timestamps were captured from COM4; `playdate.getStats()` returned device statistics during each run. Each measured segment contains 179 frame intervals (180 updates) at a target refresh rate of 30 Hz.

The full-route workload teleports through sorted tiles to stress camera travel, cache misses and distant machinery. It deliberately moves faster and less naturally than a player. A separate workload samples eight areas at 90 world units/second. Both run actual drawing and game updates, but stub controls and position the ball automatically; neither establishes a full human playthrough, gesture feel or a guarantee of sustained 30 FPS everywhere.

## Full-route hardware results

| Route | Before FPS | After FPS | After p95 frame ms | After max frame ms |
|---|---:|---:|---:|---:|
| 14 Spring garden | 29.97 | 30.04 | 35 | 46 |
| 19 Going up | 30.04 | 30.12 | 36 | 37 |
| 24 Wind workshop | 29.83 | 30.10 | 36 | 42 |
| 30 Composite legacy course | 22.21 | 28.95 | 39 | 45 |
| 34 Moving stones | 29.25 | 29.92 | 37 | 43 |
| 36 Steam windows | 29.71 | 29.86 | 38 | 50 |
| 40 Choose a lane | 28.30 | 29.91 | 35 | 52 |
| 44 Grand expedition | 11.53 | 24.70 | 53 | 62 |

Route 44 worst frame improved from 156 ms to 62 ms. Route 34's initial 158 ms spike fell to 43 ms. Samples slightly above 30 FPS reflect millisecond timing and a short measurement window. Final stress Lua heap was approximately 1,869 KB on route 44; this is not total device/native bitmap memory.

Raw logs: `tests/device-workload-v040.log` (initial), `device-profile-v040.log` (instrumented diagnosis), `device-optimized-v040.log`, `device-refined-v040.log`, `device-smooth-v040.log` (intermediate iterations), and `device-final-stress-v040.log` / `device-final-smooth-v040.log` (final checks).

## Optimizations and remaining limits

Final normal-speed samples (90 world units/second, same 179 intervals each):

| Route / starting region (x, y) | FPS | p95 frame ms | Max frame ms |
|---|---:|---:|---:|
| 30 / (96,112) | 29.98 | 36 | 52 |
| 44 / (48,80), lift approach | 29.47 | 39 | 42 |
| 44 / (480,80), cannon/high road | 28.52 | 39 | 45 |
| 44 / (1264,80), bridge approach | 29.06 | 37 | 39 |
| 44 / (1752,112), ferry region | 27.65 | 49 | 53 |
| 44 / (2128,112), wind/spring/gate region | 26.34 | 49 | 60 |
| 44 / (4800,112), late workshop region | 29.68 | 39 | 47 |
| 44 / (5600,240), late workshop region | 29.81 | 39 | 41 |

The weakest normal-speed sample still averages 26.34 FPS with a 60 ms maximum interval. These results support an improvement, not a claim that all stutter is eliminated.

- Conservative swept bounds filter nearby physics objects, including full ferry travel, rotating extents, extending bridge reach, fan regions and magnet radius.
- Repeated support queries at identical position/time reuse a result; reset and every dock update invalidate it before changing machinery.
- Remote control stations are rejected before support queries.
- Unchanged metal deck/panel rasters are reused. Moving shutters reuse their bitmap allocation; position and shape remain live.
- Blade, gear and spring frames are prepared once. Road material projections and repeated tile appearances are prepared during course entry. During play, terrain chunks are assembled only around the screen and a margin; cold chunks are evicted.
- Actual stress testing still shows frame-time variation, especially in the final large course. This release improves performance substantially but is not certified stutter-free. Course-entry preprocessing occurs outside timed play. Physical crank/tilt feel and a complete 44-course human playthrough remain separate checks.
