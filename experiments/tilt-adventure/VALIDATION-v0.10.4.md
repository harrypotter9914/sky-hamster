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

## Subsequent physical-device verification

After USB reconnection, the corrected 0.10.4 release installed and started successfully. `tests/device-release-v0.10.4.log` contains the startup PASS checks and READY marker. The temporary audio workload verified all 45 assets plus slow/fast rolling (47 cases): `tests/audio-device-v0.10.4.json`. All 45 source WAVs are valid, non-silent mono PCM without clipped samples: `tests/audio-waveforms-v0.10.4.json`.

The eight normal-speed hardware scenes measured 26.02–29.97 FPS with audio, exposing a regression in heavier areas. `tests/device-audio-v0.10.4.log` records this baseline. Profiling measured mechanism-audio update at approximately 4.58 ms in the selected heavy scene. This led to the separate 0.10.5 optimization; see VALIDATION-v0.10.5.md.

Playback-state checks do not establish speaker sound quality. These are automated workloads, not human playthroughs of all 44 courses. Saved preferences and the installation folder are preserved.
