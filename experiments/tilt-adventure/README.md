# Sky Hamster Tilt — 0.1.0

Independent tilt-control edition based on the full Sky Hamster 0.6.7 source at commit 9d2d7d9. The original root source and nine control experiments are unchanged. A source snapshot is saved locally as `builds/sky-hamster-before-tilt.zip` (repository root); Git history also preserves the baseline.

## Play loop

Title → continue or select one of 17 courses → hold still to calibrate → roll / jump / use machines → checkpoint or failure → retry → course result and saved best time → next course → final journey screen → title or replay. All courses remain selectable for playtesting. Progress, last course and best times use the separate `com.wangyibo.skyhamster.tilt` save namespace.

## Controls

- Tilt: screen-relative thrust. Greater tilt increases force, not a forced target speed; momentum and slope gravity remain.
- Quick upward lift: jump on jump-enabled courses. A is the button alternative. Jump impulse is fixed, preserving horizontal velocity.
- A: confirm; on a cannon, fire. On a bridge station, turning the crank directly moves the bridge.
- B: leave a control station/cannon. Move more than 32 world units away before it can capture the ball again. In menus, return; at results, retry.
- D-pad UP: route map and pause. A/B resumes.
- D-pad DOWN: recalibrate at the current comfortable grip angle; play pauses during calibration.
- Crank: rotate a manual bridge or aim a cannon while docked. It no longer accelerates the ball or charges a jump.
- System menu: level select, map/pause, title/sound.

Slow down below 35 world units/second and enter within 17 units of a station to dock automatically. Tilt movement is suspended while docked. Cannon aim is limited to ±60 degrees around its initial heading; dots preview the ballistic path.

## Course content

Original 14 courses retained. 15 Crank Crossing introduces manual bridge rotation. 16 Cannon Clouds introduces capture, aim, fire and landing. 17 Final Flight combines cannon, checkpoint, gap and timed gate. The first four courses do not allow jumping.

## Visuals and hardware

New monochrome hamster/sky-track title artwork with low-amplitude floating animation and small local sparkles. Launcher card has a short highlighted animation, plus a list icon and launch image. Full-screen strobing is not used.

Playdate exposes a three-axis accelerometer, not a gyroscope or a reliable position tracker. Lift detection uses a filtered acceleration impulse, quiet re-arming and a 0.75 second cooldown. Real grip, sensitivity and false positives still need physical playtesting; A remains available. Prefer a comfortable moderately tilted grip rather than holding the screen perfectly vertical.

## Build and verification

Run `./build.ps1` with the Playdate SDK installed; optional `PLAYDATE_SDK_PATH` overrides its location. Output: root `builds/sky-hamster-tilt.pdx`.

Run `python tests/check_tilt.py` (requires lupa). Tests cover neutral drift, proportional tilt, lift re-arming, dock exit/re-entry, bridge rotation, actual cannon flight/landing, update paths for 17 courses, map return, retry, progress saving and final ending. Existing collision and physics checks are also run.

SDK compilation passed after the SDK update. Simulator title, tutorial and gameplay HUD were visually checked. Hardware install initially blocked by another Simulator process holding COM4; see device-status.md for the latest outcome. Automated tests do not establish physical sensor feel or real-device frame rate.

## References

- Accelerometer and launcher asset requirements: https://sdk.play.date/3.1.1/
- Cover/presentation references: https://play.date/games/crankin/ and https://play.date/games/mars-after-midnight/
- Original title asset retained at `art/title-original.png`; runtime 400×240 monochrome conversion is `source/title-art.png`.
