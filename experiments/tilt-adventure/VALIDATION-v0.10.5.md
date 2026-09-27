# Validation — v0.10.5 / build 41

## Audio coverage

All 45 source WAVs are valid, non-silent mono 22,050 Hz PCM16 without clipped samples. The physical Playdate successfully started and stopped all 45 assets, including every mechanism loop/event, UI cue, original game effect and music. Slow and fast rolling add two cases: 47 total, all passed. Continuous samples remained playing until stopped. See `tests/audio-device-v0.10.4.json`, `tests/audio-waveforms-v0.10.4.json` and `tests/device-audio-v0.10.4.log`. Audio files are unchanged in 0.10.5.

The full regression suite verifies spring impacts, all seven control-pad types, lock/release/fire, paired gate/trap/jet events, contact, distance cutoff, voice limits, pause, effects settings and reset cooldowns. New `tests/check_audio_bounds.py` checks 6,256 swept-range samples and compares loop requests, fade volumes and event timestamps against uncropped calculation over 44 courses, including distant exit/re-entry. All passed.

## Issue and correction

0.10.4 calculated poses/status for remote mechanisms and repeatedly called idle players. In the selected heavy hardware profiling workload, mechanism-audio updates averaged 4.58 ms. Conservative hearing bounds include full travel, width extension and fan regions. Returning objects use current world time. Idle stop calls, repeated playback queries and unchanged parameters are eliminated; family lookup is direct.

The intermediate culling pass measured 2.70 ms in the same instrumented workload (`audio-profile-v0.10.4.log` vs `audio-profile-v0.10.5.log`). The latter profile predates the final playback-query/volume caching refinement, so it is not presented as a final profiler result. Final uninstrumented scene measurements follow below.

## Physical-device scene comparison

Same eight normal-speed camera samples, 179 timed frame intervals each, audio enabled. These are scripted workload measurements, not human playthroughs. Profiling is disabled for this comparison.

| Scene | 0.10.4 FPS | 0.10.5 FPS | Final frame p95 ms | Final longest frame ms |
| --- | --- | --- | --- | --- |
| 1 | 29.97 | 30.06 | 36 | 53 |
| 2 | 29.70 | 29.94 | 36 | 39 |
| 3 | 28.90 | 29.84 | 36 | 46 |
| 4 | 29.78 | 29.85 | 36 | 42 |
| 5 | 27.50 | 28.41 | 46 | 50 |
| 6 | 26.02 | 27.70 | 46 | 60 |
| 7 | 29.75 | 29.82 | 37 | 44 |
| 8 | 29.85 | 29.81 | 37 | 44 |

Final range: 27.70–30.06 FPS. The heavier scene improves from 26.02 to 27.70 FPS. Occasional long frames remain (up to 60 ms here); this is not a guarantee of a perfect 30 FPS. See `tests/audio-perf-v0.10.5.log`.

## Release installation

The normal release is restored to the same `/Games/sky-hamster-tilt.pdx` folder after diagnostic workloads. Final startup evidence is recorded in `tests/device-release-v0.10.5.log`. Bundle ID and existing player preferences/saves remain unchanged. No additional version-named game folder is installed.

These checks establish file validity, native playback state and event behavior. They do not establish how the speaker sounds to a listener, rule out every possible simultaneous-voice mix artifact, or constitute a complete playthrough of all 44 courses.
