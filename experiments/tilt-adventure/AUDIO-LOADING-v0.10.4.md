# Audio and loading — 0.10.4

The existing rolling, jump, fall, landing, wall, checkpoint, finish and music assets remain. New samples are deterministic synthesis from `../../tools/make_mechanism_audio.py`: 22,050 Hz, mono, 16-bit, 35 distinct PCM payloads.

| Mechanism/action | Feedback |
| --- | --- |
| Station lock / B release | Different latch and release clicks |
| Lift | Loaded motor loop; endpoint stop |
| Automatic ferry / crank slider | Different transport and sliding-rail loops |
| Automatic rotor / crank bridge | Different rotating and gear-drive loops |
| Retracting bridge | Winch loop synchronized with changing width |
| Fan / crank aiming | Airflow and separate direction-adjustment loop |
| Cannon aiming / firing | Aim loop and ratchet; separate launch report |
| Spring bumper | Elastic rebound only on a real collision |
| Sweeper | Rotating sweep loop |
| Gate / paired switch | Open/close strokes and switch detent |
| Trap floor | Warning, opening and closing cues |
| Jet | On/off transients and pressurized-air loop |
| Conveyor | Belt loop and first-contact cue |
| Magnet | Field loop and influence-entry cue |
| Menu / settings / guide / calibration | Move, confirm, back, toggle, unlock, ready |

Nearby ambience selects at most two families, plus one actively cranked family. One-shot events have four priority-limited voices. Distance attenuation and aggregate volume limits control stacking. Samples load once; synthesis is offline. Pausing, leaving play, turning effects off and changing course stop mechanism players. These budgets do not count pre-existing rolling/music/gameplay players.

Loading uses `art/loading-sky-original.png` and `art/loading-run-original.png`, packed by `art/prepare-loading.ps1` into native monochrome resources. Eight image poses play at 12 poses per second with gentle 30 Hz drift. The hamster stays upright; the whole image never spins. Loading has a fixed label plus a 0/1/2/3 dot cycle. The illustrated winged meter fills from completed work. Native preview: `art/loading-preview.gif`.

SDK imports must finish in the initial pdz-load phase. The launcher image covers that phase and matches animation frame zero. Deferred images and audio load during the subsequent animation. Course tiles, terrain indexing and nearby chunk preparation yield in batches. Progress follows completed work, not a fabricated percentage timer. Loading freezes gameplay; no extra minimum display delay is imposed.

Entry paths: startup, Start Game/course selection, next course, failure retry and course-result retry. Instant help/settings/map changes remain immediate.
