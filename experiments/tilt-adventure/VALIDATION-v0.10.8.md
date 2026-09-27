# 0.10.8 — Foreground joins and solid aiming

## What changed

The v0.10.7 geometry checks proved the bridge did not intersect a road in world space. They did not prove correct drawing order: the near bridge skirt was still painted over the foreground road. `DepthOrder` now selects axis-separated road slabs in front of each mechanism. Mechanisms paint from back to front, followed by their foreground road cover. Supporting tiles are excluded, so the road under a machine does not erase it.

All six lift landings keep their connected rear exits. The full-height masonry backdrop has been removed; ordinary thin landing slabs rest on two narrow stationary posts outside the lift's travel footprint. The center lifting column remains independent. Walking surface heights and endpoint connections stay unchanged.

The cannon is now a projected cylindrical solid with a tapered body, reinforcement rings, hollow mouth, pivot pins and a fixed round pedestal. Its screen length and mouth ellipse change with yaw. It no longer rotates a flat barrel image. Sixty-one prepared views preserve a two-degree visual interval; the aim and physical flight remain continuous. Recoil moves the tube only.

Mouth, preview, smoke and projectile spawn use the same world coordinates. The projectile center starts at the mouth, not at ground-level pedestal coordinates. The retained ballistic curve starts at its 0.16-second exit point, with the corresponding remaining vertical velocity, preserving the old no-wind landing position and existing receiving platforms. The cannon tutorial also uses the same projection and trajectory. The ball is hidden while loaded into the cannon.

The audit found the same facing problem in fans: a screen-facing rotor with an independently moving wind arrow. Fan housings now turn, blade rotation is projected in the head's vertical plane, and gusts begin at the outlet. The displayed housing uses five-degree orientation steps while physical airflow remains continuous.

## Scope of the audit

Native exports cover 12 mechanism families, each at three states: spring bumper, conveyor, extending bridge, fan, ferry, gate, jet, lift, magnet, rotating bridge, sweeper and trapdoor. Separate exports cover eight fan headings, cannon yaw, lift stops, manual ferry travel, and automatic versus manual tutorials. Switch-controlled gates use the gate geometry and retain their two-lane behavior. Static props keep their existing artwork; this was a spatial audit rather than a new set of levels.

Host checks pass the existing full suite, 3,439 moving-footprint samples, 342 seam samples and six connected lift exits. New checks cover 67 near-bank cases, 121 muzzle/preview/spawn/landing comparisons, geometric foreshortening, posts outside lift travel, and 1,932 cached foreground-cover selections matching uncached painter order.

The native review exported 211 v0.10.8 frames. Before/after foreground-cache optimization, these exported frames are byte-identical. Native screenshots are inspected separately from mocked host graphics. Neither scripted checks nor short hardware workloads constitute a human playthrough of all 44 levels.

## Hardware findings

Initial six-stage moving-machinery test completed on the physical Playdate: 29.00–30.01 FPS, maximum sampled frame 45 ms. See `tests/depth-motion-draft-v0.10.8.log`.

The first eight-scene complex-course test exposed expensive repeated road-tile drawing: 15.22–30.14 FPS, maximum sampled frame 76 ms. See `tests/depth-smooth-draft-v0.10.8.log`. This is a draft regression, not an acceptable final performance claim.

Foreground tiles are now batched into transparent image covers, reused for unchanged poses and matching tile selections. Common moving poses are prepared during loading; old-course covers are released. The optimized native output matches the uncached output. Final optimized hardware measurements and normal-release restoration are pending USB reconnection; update this section after the actual device run.
