# 0.8.0 validation

## Passed

- Playdate SDK 3.1.2 build, including native Lua compilation and all image assets.
- Existing physics, tilt calibration, jump gesture, landing momentum, menu return, keycap and docking regressions.
- 33 course start/goal/checkpoint support checks and all course update/UI paths.
- Old-save migration; new saves do not migrate twice.
- Lift endpoint clamping, low-deck rejection of a high bank, carrying the player upward, releasing onto the upper road.
- Manual ferry moves both deck and docking point; release prevents immediate capture.
- Wind force changes direction with crank input; later wind-control tutorial appears even after ordinary wind teaching.
- Spring bumper rebounds contact but permits a jump above its collision height.
- Actual game update fires and lands the new cannon routes, including elevated launch positions.
- Five final checkpoints advance and retry at the latest one.
- SDK simulator exports of new machinery, all new tutorials at multiple phases, maps and dock HUD states; inspected at 400×240.
- The native Simulator completed the six-route workload without runtime errors (1,080 updates total). Raw report: `tests/simulator-workload-v020.json`, explicitly marked `device: false`. The deliberately accelerated final-route scan produced 14 visible chunk misses; this is a remaining hardware measurement target, not a claim of zero-stutter operation.

## Problems found and corrected

1. Reordering courses initially invalidated tests referring to old numeric positions. Legacy fixtures now resolve through the migration map, while the all-course loop covers every new index.
2. The second cannon in Cannon Relay initially landed short of its receiving island. The island begins one tile earlier; actual ballistic landing is now checked.
3. Startup regression checks ran after campaign expansion, incorrectly treating lift ledges as continuous ramps. Existing regression fixtures now run before expansion, followed by the separate expanded campaign suite.
4. A winding route initially crossed its own exit and allowed a shortcut. The finish moved inward, eliminating that crossing.
5. Ordinary wind teaching would suppress the later wind-dial lesson. The control lesson now has its own saved identity.

## Performance changes

Static terrain uses 128×128 pixel chunks. Visible chunks are drawn with one surrounding margin, at most one additional nearby chunk prepared per frame, and old image entries evicted beyond the cache budget. Long routes no longer allocate one very wide full-map bitmap.

Terrain occlusion boxes are indexed in projected 128-pixel buckets. Each ball query visits only overlapping buckets and deduplicates boxes, rather than scanning the entire course. Distant mechanisms are culled before drawing; generated machinery sprites and tutorial reductions are cached. Existing spare-frame garbage collection and reusable mask geometry remain enabled.

## Hardware status

0.7.9 was installed and launched on COM4 earlier in this session. The subsequent 0.8.0 hardware workload installation returned `No Playdate device detected`; Windows also showed no Playdate serial device or mounted volume at that check. No 0.8.0 real-device FPS or physical playthrough is claimed yet.

`tests/build-perf.ps1` creates an isolated workload source copy and outputs `builds/tilt-perf/sky-hamster-tilt.pdx`. It deliberately uses the release installation filename to avoid accumulating another game entry. The script replaces only test inputs and storage in that copy, scans six demanding routes for 180 frames each, and prints frame intervals, update costs, chunk misses and Lua memory. After measurement, reinstall `builds/sky-hamster-tilt.pdx` to restore the normal game.

This workload is a camera/cache stress test, not automatic proof that all routes are human-playable. Physical gesture feel, completion difficulty and long-session hardware behavior still need direct playtesting.
