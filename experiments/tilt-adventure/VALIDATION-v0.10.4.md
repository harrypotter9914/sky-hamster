# Validation — v0.10.4 / build 40

## Passed

- Full `tests/check_audio_loading.py` suite: 44-course mechanics, calibration/lift, momentum, tutorials, navigation, spatial/render reference checks, mechanism events and all seven control-pad types.
- 35 distinct mono PCM samples; actual spring impact, gate/trap/jet transition pairs, distance cutoff, control motion/endpoints, voice limits, pause/effects/reset and six UI cues.
- Cooperative loading: work yields between frames, progress is monotonic, completion callback runs, course entry does not run physics/time.
- Native Simulator export of 72 loading frames at 400×240. Checked composition, generated meter rim, label/dots and upright hamster. Saved GIF and matching launch image.
- Native startup and final-course loading: `tests/loading-native-v0.10.4.json` reports complete, 58 startup updates and 90 course updates. These counts are not physical-device frame-rate measurements.
- SDK release compilation succeeded.

## Issue found and corrected

The first deferred-import bootstrap failed on the native runtime (`import() called outside of pdz loading`). Static imports now occur during initial loading. Audio/image resource preparation runs in the subsequent cooperative worker. The native startup test was repeated successfully after the correction. Host-only mocks had not exposed this SDK restriction.

## Device limitations

Final installation attempts returned `No Playdate device detected`. This corrected build has not been confirmed installed or performance-tested on hardware. The early draft installed before the bootstrap correction is not a validated final build. Do not treat that transfer as release validation. Reconnect the powered-on device and run `install.ps1`; it overwrites `/Games/sky-hamster-tilt.pdx`.

No claim is made that the physical speaker has been heard, that this revision sustains 30 FPS, or that all 44 courses were human-playtested. Previous hardware measurements remain historical and do not validate the added mixer. Saved settings, bundle ID and installation folder are preserved.
