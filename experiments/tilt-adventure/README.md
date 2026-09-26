# Sky Hamster Tilt — 0.1.6

Independent tilt-control edition based on the full Sky Hamster 0.6.7 source at commit 9d2d7d9. The original root source and nine control experiments are unchanged. A source snapshot is saved locally as `builds/sky-hamster-before-tilt.zip` (repository root); Git history also preserves the baseline.

## Play loop

Title → Start Game → first-encounter animated guides over the level → hold still to calibrate → roll / jump / use machines → checkpoint or failure → retry → course result and saved best time → next course → final journey screen → title or replay. All courses remain selectable for playtesting. Progress, last course and best times use the separate `com.wangyibo.skyhamster.tilt` save namespace.

## Controls

- Overhead compass: the arrow shows current screen-relative tilt thrust, not velocity. Its length grows with force; the central ring means neutral. Hidden while docked, falling, calibrating or viewing a tutorial.
- Tilt: screen-relative thrust. Greater tilt increases force, not a forced target speed; momentum and slope gravity remain.
- Quick upward lift: keep the device close to level and move the whole device upward quickly to jump on jump-enabled courses. Upright and large lateral shakes are rejected. A is the button alternative. Jump impulse is fixed, preserving horizontal velocity.
- A: confirm; on a cannon, fire. On a bridge station, turning the crank directly moves the bridge.
- B: leave a control station/cannon. Move more than 32 world units away before it can capture the ball again. In menus, return; in guides, replay; at results, retry.
- D-pad UP: route map and pause. A/B resumes.
- D-pad LEFT / Help: replay this course's control and mechanism guides. A advances; B returns immediately to the current run. Finishing the sequence resumes play.
- D-pad RIGHT / Goal: read this course's objective, checkpoint/jump rules and mechanism notes. A/right advances a page; left goes back a page; B resumes play.
- D-pad DOWN: recalibrate with the device lying flat, screen facing up; play pauses during calibration. Keep it still for 0.8 seconds. Upright and tilted poses are not accepted as neutral.
- Crank: rotate a manual bridge or aim a cannon while docked. It no longer accelerates the ball or charges a jump.
- System menu: level select, map/pause, title/settings.

Slow down below 35 world units/second and enter within 17 units of a station to dock automatically. Tilt movement is suspended while docked. Cannon aim is limited to ±60 degrees around its initial heading; dots preview the ballistic path.

## Course content

Original 14 courses retained. 15 Crank Crossing introduces manual bridge rotation. 16 Cannon Clouds introduces capture, aim, fire and landing. 17 Final Flight combines cannon, checkpoint, gap and timed gate. The first four courses do not allow jumping.

## Visuals and hardware

Textured stone-road title artwork with separately floating islands/clouds and a waving finish flag. The original wooden menu boards lift when selected; labels remain inside their borders. Launcher includes a static card, list icon and launch image. Full-screen strobing is not used.

Playdate exposes a three-axis accelerometer, not a gyroscope or a reliable position tracker. Lift detection uses a filtered acceleration impulse, quiet re-arming and a 0.75 second cooldown. Real grip, sensitivity and false positives still need physical playtesting; A remains available. Screen-up flat is the neutral pose. Lowering the right/left/top/bottom edge pushes the ball right/left/up/down on screen. Opposite tilt applies ordinary counter-force; it does not instantly reverse velocity.

## Build and verification

Run `./build.ps1` with the Playdate SDK installed; optional `PLAYDATE_SDK_PATH` overrides its location. Output: root `builds/sky-hamster-tilt.pdx`.

Run `python tests/check_tilt.py` (requires lupa). Tests cover neutral drift, proportional tilt, lift re-arming, dock exit/re-entry, bridge rotation, actual cannon flight/landing, update paths for 17 courses, map return, retry, progress saving and final ending. Existing collision and physics checks are also run.

SDK compilation passed after the SDK update. Simulator title, tutorial and gameplay HUD were visually checked. Hardware install initially blocked by another Simulator process holding COM4; see device-status.md for the latest outcome. Automated tests do not establish physical sensor feel or real-device frame rate.

## References

- Accelerometer and launcher asset requirements: https://sdk.play.date/3.1.1/
- Cover/presentation references: https://play.date/games/crankin/ and https://play.date/games/mars-after-midnight/
- Original title asset retained at `art/title-original.png`; runtime 400×240 monochrome conversion is `source/title-art.png`.

## UI refresh — 0.1.1

Home has only **Start Game** and **Settings**. Start Game continues the saved course; in-game system menu opens Level select, Map / pause, or Title / settings. Settings persist effects, music, scene animation and lift-to-jump. A remains a jump alternative when lift gestures are disabled.

The 400×240 title is a fixed one-bit scene, with separately cached islands, clouds and a four-frame flag. The HUD, selector, chart, tutorials, calibration and results share pixel icons and frames. Course previews show actual floor layouts, and selection remains column-first.

`art/prepare-title.ps1` exports the source illustration into one-bit runtime and launcher assets. Build with `build.ps1`. Host regression checks: `tests/check_tilt.py` (Python + lupa). Simulator UI export harness: `tests/ui_review.lua`, used only in a separate review bundle, never the shipping game. Real-device performance still needs verification.


## Materials and visual guides — 0.1.2

Stone roads now use staggered masonry instead of outlined square cells. Moving decks have steel rails and rivets; barriers have warning stripes. A shared oversized barrel with a small wooden saddle replaces the thin, wheeled cannon. Collision and jump rules are unchanged.

Body text uses the SDK's Asheville Sans 14 Bold. Home labels use the smaller font with extra spacing inside the original boards. The finish flag touches the road terminal around (393, 86).

Guides pause the real level under an animated popup. The arrival story has three picture panels. Paired device/result animations introduce tilt, lift, docking, crank bridges, cannons, gates, disappearing floors, ferries, rotors and sweepers. A acknowledges; B replays. Seen topics persist only after acknowledgement. Direct selection of later courses queues missing prerequisites; mixed courses do not repeat known mechanics.

Art masters, export scripts and prompts: `art/ASSETS.md`. Road texture, device poses and 17 cannon orientations are cached. Physical-device performance remains unverified.

Visual QA: `tests/build-review.ps1` builds an isolated review bundle using `tests/ui_review.lua`; test-only drawing hooks are injected into the build-directory copy, never production. The bundle exports native 400x240 GIF stills into its own simulator datastore. Host checks cover first encounters, persisted acknowledgements, replay, paused physics and every animation phase, in addition to the original 17-course regression checks.

Final title placement: the cannon and its solid saddle sit on the pale foreground paving to the hamster's right. The saddle exposes top/front/side faces, without decorative wheels or a circular platform. This gives the black barrel a clear contrasting background.

## Flat neutral — 0.1.3

Calibration now accepts only screen-up flat, held still for 0.8 seconds, with bounded sensor trim inside the motion deadzone. The former arbitrary-grip calibration could learn upright as neutral. Tests cover rejected poses, flat zero input, all four screen directions and inertial counter-steering. SDK build and host regressions passed. Installation over COM4 completed, followed by a run command echoed in the device log. Physical handling and frame rate still require hands-on verification.

## Tutorial storyboard and UI pass — 0.1.5

Ten tutorial topics now share a fixed, full-screen storyboard with separate heading, subtitle, demonstration, captions and button rows. Arrival uses three stills on one continuous road. Four-direction movement follows a continuous path; a level-device sprite translates upward for the jump example. Gates, disappearing floors, ferry, rotating deck, crank bridge and cannon have explicit waiting/action/result phases. The game stays paused under these tutorials.

Four transparent illustration masters supply five runtime assets: handheld, flat handheld, small/large hamster marble and finish trophy. They are reused in tutorials, calibration, failure, route results and campaign completion. HUD names have a width limit; the timer uses whole seconds in play (precise results remain). Stations at the starting position replace the overlapping START world callout; the map retains its start marker. Existing map layout and title art are preserved.

Updated guides replay once after upgrading from an older guide revision; progress, settings and records remain. SDK build and regression tests cover the complete campaign plus level upward impulses, single-trigger cooldown, lateral/upright rejection and rearming. The review bundle exports six phases of each of ten topics plus menu/results pages at 400×240. Physical gesture feel and frame rate require hardware playtesting.

Asset prompts, built-in generation mode and source names: `art/UI-ASSETS-v015.md`. Export with `art/prepare-ui.ps1` before building. Tutorial poses and miniature cannon orientations are cached; static imagery is not regenerated during play.

## Help and route goals — 0.1.6

The bottom control strip now uses two rows. LEFT Help and RIGHT Goal stay visible both while rolling and while docked. The upper row retains map/recenter/jump or crank/fire/release controls. Help and Goal freeze physics, mechanisms and the timer without resetting position, velocity or docking. Input used to close them cannot also jump, fire or leave a cannon. Manual guide replay does not change first-encounter acknowledgements. All 17 courses have tilt-specific notes, replacing obsolete crank-power instructions in this new view.
