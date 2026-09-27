# 0.10.7 — Aiming, flush docking and lift depth

## Changes

- Cannon barrels visibly turn with the projected launch tangent. The 61 poses cover the existing −60° to +60° aim range at 2° intervals; recoil follows the same direction. Launch physics are unchanged.
- Ferry endpoints now meet measured road edges, rather than overlapping the bank. Rotating bridges fit the actual gap; short sliding end shoes retract enough to clear the banks during rotation and close flush at alignment.
- All six lifts retain a lower left entrance and gain a connected upper rear exit. The former front-facing layout hid the platform when the upper road was correctly drawn in front. Moving the exit rearward makes both the shaft and the height difference readable. Upper banks have deep masonry sides, consistent collision thickness and updated terrain-cache bounds.
- Rails, bearings and lift supports render beneath roads; decks render above them, with nearby upper ledges reapplied where necessary. Tile corners use their own tile plane, avoiding a false slope where the upper landing begins.
- Manual-machine tutorials animate the crank attached to the Playdate itself. Automatic ferries and rotating bridges show autonomous motion without a crank instruction. Their demonstrations reuse joined roads and actual machinery artwork.

## Checks completed

`python tests/check_joinery.py` passes the full prior regression chain plus 3,439 moving geometry samples without road intersections, 342 supported bank-seam samples, all six connected lift exits and 121 cannon/trajectory tangent comparisons. The host renderer is mocked; these checks do not establish visual quality or hardware frame rate.

SDK production and review builds compile. The native Simulator exported lift low/mid/high states, ferry endpoints and transit, five bridge angles, a 61-frame cannon sweep and 90 tutorial animation frames. Selected native images were inspected. Both production rotor image tables load with 180 frames each. See `tests/joinery-native-v0.10.7.json`, [joined structures](art/joins-v0.10.7.png), [cannon animation](art/cannon-v0.10.7.gif), and [attached crank animation](art/crank-v0.10.7.gif).

The optimized six-stage motion workload also completes in the native Simulator, including the previously failing cannon stage; `tests/joinery-motion-simulator-v0.10.7.json` records `device: false`. This confirms execution, not hardware performance.

## Hardware findings and remaining verification

The initial hardware draft ran eight normal camera samples at 26.21–30.21 FPS. A dedicated moving-machinery workload then exposed roughly 23 FPS during continuously rotating bridges. See `tests/joinery-perf-draft-v0.10.7.log` and `tests/joinery-motion-draft-v0.10.7.log`. The latter stopped at the cannon because the benchmark assumed every course had a mechanisms table; that QA-only nil-table bug was fixed.

The final renderer uses offline SDK-rasterized bridge frames instead of projecting their detailed materials every frame. It chooses the nearest 1° visual pose (maximum 0.5° visual difference); physical pose and collision remain continuous. Unneeded bridge tables are released when changing courses. Lower machinery rendering now uses a short dedicated list, and upper-lip height checks avoid an additional wrapper on every floor query. Details and reproducible export scripts are in [art notes](art/JOINTS-v0.10.7.md).

**Final optimized hardware performance and normal-release installation are pending USB reconnection.** The Playdate disappeared from USB/COM after the draft workload; subsequent install attempts reported no device. The last successful transfer in this iteration was a temporary diagnostic build in `/Games/sky-hamster-tilt.pdx`. Restore the normal release there with `./install.ps1` after reconnection. No final hardware FPS claim, full human playthrough claim or successful final-install claim is made here.
