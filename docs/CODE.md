# Design in code

[← Project home](../README.md) · [Build](BUILD.md) · [Journal](JOURNAL.md)

These paths are the current tilt game; root `source/` is historical.

## Comfortable grip → visible correction

[`tilt.lua`](../experiments/tilt-adventure/source/tilt.lua): `Tilt.startCalibration`, `Tilt.update`, `Tilt.direction`, `Tilt.response`. Stable gravity samples define neutral, rather than assuming flat holding. Magnitude and direction separate; Screen transforms axes before projection, Road preserves them. The overhead pointer shows force, not velocity.

[`physics.lua`](../experiments/tilt-adventure/source/physics.lua): `Physics.steer`, `Physics.air`. Inertia and slope acceleration remain independent. Opposing input gains braking help; near-neutral settling does not drag normal propulsion. Device-local lift pulses separate from tilt. Historical `Physics.controls`/charge functions remain for comparisons, not current tilt acceleration.

## Free movement → crank machinery

[`dock.lua`](../experiments/tilt-adventure/source/dock.lua): `Dock.update`, `Dock.status`, `Dock.muzzle`, `Dock.trajectory`. Slow grounded entry docks; B releases and blocks recapture until leaving. Crank change modifies machinery. Cannon art, guide, and projectile share one muzzle and a bounded aim arc.

[`workshop.lua`](../experiments/tilt-adventure/source/workshop.lua) extends docking for telescoping bridges and route switches. [`campaign.lua`](../experiments/tilt-adventure/source/campaign.lua) constructs lift, shuttle, fan, and bumper encounters.

## Actual clearance → GO / WAIT

[`passage.lua`](../experiments/tilt-adventure/source/passage.lua): `P.ports`, `P.ready`, `P.laneReady`, `P.draw`. Each port/lane reports actual geometry/height. Labels reserve occupied regions and break leaders around the ball. Rotation stays continuous; circular support tolerates small equal-height seams.

[`mechanisms.lua`](../experiments/tilt-adventure/source/mechanisms.lua): `Mechanisms.pose`, `carry`, `support`, `collide`. Transport stays separate from a rider's own displacement, preventing stationary balls from rolling just because their boards move.

## Lessons → persistent progress

[`engine.lua`](../experiments/tilt-adventure/source/engine.lua): `selectLevel`, `startNewGame`, `openSelector`, `closeSelector`, `pd.update`. [`campaign.lua`](../experiments/tilt-adventure/source/campaign.lua): `Courses.migrate`. Selection remembers origin, stable identity preserves reordered progress, and developer tests isolate saves. Tutorials pause the world and contextualize A/B so advancing instruction cannot accidentally fire.

## Hardware constraints → staged preparation

Fixed native art prebakes with source fingerprints. Collision prepares first; nearby road images use bounded retention. Loading yields to avoid the watchdog. See [asset rebuild](../experiments/tilt-adventure/art/RUNTIME-v0.12.2.md), [validation](../experiments/tilt-adventure/VALIDATION-v0.12.2.md), and [a rejected optimization](../experiments/tilt-adventure/REFLECTION.md#entry-11): binary search was reverted when hardware benefit was negligible.

Source/tests do not establish manual completion of every route. [Evidence and limitations](RELEASE.md).
