# Tilt 0.4.2 — easier lift and small steering adjustment

Date: 2026-09-26. Build 15. This patch changes the tilt edition only.

## Final tuning

- Screen-normal lift residual: greater than 0.48 g, previously 0.65 g (26% lower threshold). This is acceleration above the filtered sensor estimate, not measured hand speed.
- Transverse residual limit: magnitude below 0.50 g, previously 0.40 g. The screen-normal pulse must also dominate the transverse component, so a mostly sideways shake does not qualify.
- Current device Z remains the reference at every reading, independently of the calibrated neutral grip. Quiet rearming, the 0.75 s cooldown, the 0.22 s steering isolation, airborne restrictions and A fallback are retained.
- Tilt thrust: 150 → 154.5 units/s² at full input, a 3% increase applied equally in every direction. Counter-steering becomes slightly more effective; forward acceleration is also 3% stronger before resistance. There is no special reverse multiplier or instant velocity reversal.
- Unpowered resistance, slope gravity, jump impulse and landing momentum are unchanged. No course, artwork or animation changes.

## Findings and verification

An initial increase in rolling resistance (friction 7 → 7.5, drag 0.16 → 0.17) failed the existing high-momentum climb regression. Smaller resistance increases also failed that boundary case. Those edits were reverted; the final change preserves unpowered momentum and adjusts ordinary steering force instead. Physics.step now reads its existing tuning table rather than duplicating four constants internally.

`python tests/check_feel.py` passed. It includes the complete prior regression suite, all 44 courses' mechanism checks, landing/cannon behavior, indexed collision comparisons and 2,400 terrain-cache comparison frames.

New sensor tests execute the real Lua detector with synthetic accelerometer readings: 7 grips × 3 update rates (20/30/50 Hz) × 3 transverse offsets = 63 moderate-lift combinations. A 0.55 g residual triggers in each combination; rising pulse shapes and a changed grip after calibration also trigger. Small bumps, downward pulses, large lateral shakes and gradual steering do not trigger in the tested traces. Checks retain quiet rearming, cooldown, a single trigger and steering isolation. These are sampled cases, not proof against every physical motion.

Flat-ground stopping measurements use the real integrator, fixed counter-input and 1/1200 s analysis steps. Values are world units, not pixels. Steering-filter latency is excluded. Existing game-update tests separately check retained landing momentum.

| Initial speed | Counter-input | Previous distance | New distance | Reduction |
| --- | --- | --- | --- | --- |
| 60 | 50% | 20.3765 | 19.8701 | 2.49% |
| 60 | 100% | 11.0187 | 10.7232 | 2.68% |
| 120 | 50% | 76.1311 | 74.3580 | 2.33% |
| 120 | 100% | 42.4356 | 41.3385 | 2.59% |
| 200 | 50% | 194.6430 | 190.4489 | 2.15% |
| 200 | 100% | 112.3610 | 109.5856 | 2.47% |

With no input, stopping times and distances at all three speeds are exactly unchanged. A ball travelling at 200 units/s remains above 190 after one 1/30 s frame of full counter-input.

## Build and hardware

SDK build passed: `builds/sky-hamster-tilt.pdx`, version 0.4.2 / build 15. Local version archive: `builds/sky-hamster-tilt-v0.4.2.zip`.

The first installation attempt returned `No Playdate device detected.` After USB reconnection, installation succeeded through COM4 / F:, replacing the existing `sky-hamster-tilt.pdx`. The normal release was launched at `/Games/sky-hamster-tilt.pdx`; the captured startup log reports passing physics/mechanism/occlusion checks with no captured error. See `tests/device-release-v042.log`.

Physical sensitivity and false-trigger behavior still require a hands-on test. Installation and startup checks do not measure human gesture feel; no new hardware frame-rate or complete playthrough claim is made here.
