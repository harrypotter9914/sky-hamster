# Play Sky Hamster

[← Project home](../README.md)

## Download for Playdate

Official release: **[Sky Hamster on itch.io](https://hajimi9914.itch.io/sky-hamster)**. Download `sky-hamster-v0.12.12.zip`, containing `sky-hamster-tilt.pdx`. The identical file is also available in the [GitHub v0.12.12 release](https://github.com/harrypotter9914/sky-hamster/releases/tag/v0.12.12). This is not a Windows app or browser game.

### Wireless sideload

1. Download the ZIP.
2. Sign in to your Playdate account and open [Sideload](https://play.date/account/sideload/) with your device registered.
3. Upload the ZIP (or `.pdx`).
4. Refresh **Game Library** (or **Settings → Games** on earlier software) on Playdate, then download it.

### USB through Simulator

Extract the ZIP, open the `.pdx` in Playdate Simulator, connect/unlock hardware, and choose **Device → Upload Game to Device**. Keep the same game/bundle when updating. [Panic's official guide](https://help.play.date/games/sideloading/) also documents Data Disk installation.

## Current controls

| State | Input | Result |
| --- | --- | --- |
| Course entry | Hold comfortably and still | About 0.8 seconds of stable sampling establishes neutral. |
| Rolling | Tilt | Apply force. Counter-tilt helps brake without instant reversal. |
| Rolling | Down / Recenter | Recalibrate a stable grip; existing velocity is not reset. |
| Jump-enabled course | Quick lift along current screen normal, or A | Jump with momentum, subject to recovery. Settings can disable the gesture. |
| Rolling | Up / Map | Pause and inspect route, landmarks, and course sections. |
| Rolling | Left / Help | Replay relevant instruction without advancing the world. |
| Rolling | Right / Goal (Go in some teaching art) | Read objectives and machinery guidance. |
| Slow grounded entry to a control point | Automatic | Dock; LOCKED confirms state. |
| Docked | Crank | Change active machine position, orientation, extension, or route. |
| Docked cannon | A / Fire | Launch on the guide. A is not Jump here. |
| Docked | B / Release | UNLOCKED; leave the area before returning to redock. |
| Tutorial/menu | Displayed A/B hints | A advances/confirms; B returns where supported. |

This uses an **accelerometer**, not a gyroscope. Calibration supports different comfortable grips but cannot detect every rotation about gravity or distinguish every shake. A remains a reliable jumping alternative.

## Steering choice

**Road**, the new-game default, maps rightward tilt along the road axis, appearing down-right. **Screen** maps it to screen-right. **Settings → Steering** compares animated cards; Left/Right selects, A saves, B cancels. New Game introduces the choice after the goal. Change it later without resetting progress.

## Explore without unlocking every course

Choose **Settings directly on the title**, then hold **A+B about 2.5 seconds** to toggle hidden developer access. Press Playdate's round **Menu** button and choose **Level select** for all 53 courses, also available during play.

Repeat the chord or restart to leave. Test completions, best times, tutorials, and skipped positions do not overwrite normal progress. Ordinary play unlocks in order; completed routes remain replayable.

## Continue and retry

With progress, Start Game offers Continue/New Game. New Game confirms with Cancel selected first, resets progress/times/tutorial reads, retains preferences, and asks steering again. Falling offers retry from start/checkpoint. Finishing advances the journey; best times support replay.

For unreliable gestures, use A and recalibrate. Large late courses retain loading waits/slower scenes; [release evidence](RELEASE.md) states test scope.
