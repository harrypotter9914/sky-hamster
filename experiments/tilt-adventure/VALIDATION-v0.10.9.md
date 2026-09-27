# 0.10.9 — All-course device performance and USB wakefulness

## Measurement method

The physical Playdate runs the full game's update, physics, renderer, HUD and audio. The isolated workload replaces only player input, positions the ball at reproducible locations, suppresses progress writes, and records frame intervals and update cost through serial. It does not replace gameplay art with simplified test graphics. Profiling builds remain separate from the normal release and use the same installation folder temporarily.

Coverage is 44 courses and 303 scenes: one 180-frame sorted-road traversal per course, three 120-frame local camera samples, all 92 mechanism instances and all 35 control stations. The road traversal deliberately jumps between tiles to stress camera/cache changes. Local samples move the camera over a short region; machinery samples exercise the actual moving platforms, and control samples supply crank input. Loading, report serialization and course changes are outside the interval measurement. Each scene reports average FPS, 95th-percentile frame interval, longest frame, update costs, terrain misses and Lua heap size.

This is reproducible hardware sampling across all courses, not a human completion of every route or every possible gesture. Frame-time spikes and slow sampled locations are retained in the report rather than hidden behind a campaign-wide average.

The first baseline was interrupted to add firmware auto-lock prevention; its complete courses 1–12 are combined with the restarted courses 13–44. Source gameplay in both baseline parts is 0.10.8. The normal game's save data is never overwritten by the workload.

## Changes prompted by the run

- Dense spring/obstacle areas spent time scanning irrelevant mechanism families in each physics substep. Nearby views now preserve the original order separately for support, solid collisions and force fields. Original full-course physics results remain the comparison reference.
- Ground height at the same position is reused within a control-update epoch, with a supported lift's current elevation read live. Support lookup directly preserves the original lift-first / deck / terrain precedence instead of going through nested view wrappers. Course changes clear these derived caches.
- Fixed lift landing posts were reprojected and textured every frame. Their materials and world geometry now render to a cached bitmap during loading; moving pillars and carriage animation remain live.
- Fan headings could allocate and rasterize a new housing while the crank turned. All 72 existing heading views are prepared when a fan course loads. Blade and gust animation remain live.
- The ball hidden inside a loaded cannon was still rasterized and masked. That invisible work is now skipped.
- Acquiring/releasing stations could rebuild the bottom control panel. Keycaps and per-mode panels are cached, and the course's station modes and lock badges are prepared during loading.
- Long routes repeatedly created terrain chunks after camera relocation. Chunks are now 256×256, reducing the largest route from 94 smaller chunks to 39 (approximately 624 KB including monochrome masks). Current routes prepare and retain sparse chunks during loading, while each frame draws only visible chunks. Future maps above 64 chunks retain the bounded streaming path. Prepared maps skip irrelevant eviction bookkeeping.
- Repeated height queries now use precomputed slope coefficients and an indexed search with a last-segment fast path. Duplicate-x height steps and lift exit lips keep their original semantics. World rasterization is clipped to the exposed area between the opaque HUD panels.
- Leaving a course now releases its derived geometry, occlusion, render-view and physics-cell caches. Course definitions, progress and checkpoints remain intact, and the next visit rebuilds these caches in the loader.

## USB and sleep

`Awake.update` polls `playdate.getPowerStatus().USB` once a second and changes `setAutoLockDisabled` only when USB state changes. A fully charged device with USB connected stays awake; battery-only use restores the firmware timer without continually resetting it. The policy runs before gameplay/menu branches and during loading, and refreshes immediately on resume. It does not prevent a deliberate press of the hardware Lock button.

The API is game-level and firmware clears its override when the game exits. For the requested system-wide behavior, the device's own USB `help` listed `autolock <always|onBattery>`. `autolock onBattery` was sent successfully. After leaving the test game and opening the device's actual Settings application, **Auto Lock → Off while charging** was visibly confirmed; see `tests/device-autolock-setting-v0.10.9.png`. This is the firmware preference, independent of the game package. Manual locking remains available. The corresponding preference is also described in the [Playdate developer forum](https://devforum.play.date/t/device-will-no-longer-sleep-autolock-when-powered/8712).

The Settings application was then left untouched for **191.8 seconds**, with no device commands or button input during that interval. COM4 remained present and the subsequent framebuffer capture still showed the active Settings page, not the lock screen (`tests/device-autolock-idle-v0.10.9.png`). The battery was already at 100%, so this also checks USB-powered behavior after charging completes. This is an observed idle test beyond the normal three-minute timeout, not a claim of indefinite unattended testing.

## Regression and visual evidence

- `tests/perf-regression-v0.10.9.log`: full physics/controls/audio/geometry regression chain; 72,154 indexed height samples exactly match original values/slopes; 4,779 prepared terrain views match streaming draw order and positions with zero visible misses; current maximum 39 chunks; larger-map fallback verified. Lift supports and every fan heading allocate no new bitmaps while moving. Leaving/returning to a course releases/rebuilds derived caches.
- `tests/check_awake.py`: powered USB at full charge, disconnect, unchanged battery timer, polling interval, resume and absent API checks.
- `tests/perf-native-pixels-v0.10.9.json`: 211 native SDK exports compared to 0.10.8. 210 are byte-identical. The highest lift pose differs by eight support-edge pixels due to cached raster rounding; the actual frame was visually inspected. Materials, geometry and painter order remain unchanged.

## Hardware results and release restoration

Both full-coverage captures are complete: **44 courses / 303 scenes**, no reported runtime errors. The device-written `tests/device-report-v0.10.9.json` independently records `device: true`, `complete: true` and all 303 stages. The tested source/assets are recorded in `tests/perf-source-v0.10.9.json`.

| Measurement | 0.10.8 baseline | 0.10.9 |
| --- | ---: | ---: |
| Road traversal stress, scene-average FPS range | 24.84–30.13 | 27.35–30.22 |
| Local/machinery/control scene-average FPS range | 18.94–30.26 | 20.77–30.36 |
| Scenes averaging at least 29 FPS | 261 / 303 | 286 / 303 |
| Longest road-stress frame | 109 ms | 100 ms |
| Longest local/machinery/control frame | 75 ms | 73 ms |
| Maximum sampled Lua heap | 5,539 KB | 2,971 KB |

All **132 local camera samples** averaged **29.15–30.36 FPS**. The 92 mechanism-center samples ranged **20.77–30.17 FPS**, and 35 control-station samples **24.11–30.21 FPS**. Every final scene recorded **zero visible terrain cache misses**. Lua heap figures do not include all native image/audio memory.

**Remaining limits:** this is not stable 30 FPS everywhere. Route 44's dense conveyor and three neighboring gates still average approximately **20.8–21.1 FPS** in mechanism-center stress samples; route 33's heaviest gate averages **24.61 FPS**, versus **22.44** before. Brief long frames remain. The workload repeatedly places the ball at each mechanism's center, including solid barriers, so those samples intentionally stress collision and occlusion rather than simulate an unobstructed human route. No visual feature, sound family or physics substep was removed to improve the result.

The [per-course comparison](tests/PERFORMANCE-v0.10.9.md) lists all 44 routes and the slowest scenes. Raw logs and parsed JSON/CSV are `tests/device-all-v0.10.8.*` and `tests/device-all-v0.10.9.*`. Intermediate diagnostic captures (`device-profile*`, `device-candidate44*`) are retained as work history, not presented as final-release results.

The normal **0.10.9 / build 45** package was then rebuilt, installed over `/Games/sky-hamster-tilt.pdx` and launched through COM4. `tests/device-release-v0.10.9.log` confirms the USB wakefulness policy, all three startup checks and `READY: startup loading complete`. `tests/device-title-v0.10.9.png` is the subsequent physical-device framebuffer showing the normal title screen. The performance workload is no longer the running game. No version-named duplicate was created, and player progress was preserved.

Release archive: `sky-hamster-v0.10.9.zip`, 1790285 bytes; SHA-256 `79a8cc2a6155b626715e37c4bcae33455e98e7d659235b251fdf43afd8a3ee70`. The ZIP contains the normal `sky-hamster-tilt.pdx` package.

The restored normal title was subsequently left untouched for **219.7 seconds**. COM4 and framebuffer capture still worked, and `tests/device-title-idle-v0.10.9.png` confirms the active title after the normal inactivity timeout.
