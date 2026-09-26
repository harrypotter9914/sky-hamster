# 0.2.0 — 33-course campaign

## Design references and adaptation

The PC Hamsterball walkthrough describes bumpers, ramps, narrow bridges, pipes, timed hazards, fans and hammers: [GameFAQs course guide](https://gamefaqs.gamespot.com/pc/933822-hamsterball/faqs/75026). [Raptisoft's game page](https://www.raptisoft.com/hamsterball/) is the original game's site. These are references for balancing a rolling ball around changing terrain; no artwork or level files were copied.

This game's new spring bumpers and wind fields adapt that obstacle vocabulary. Player-operated lifts, crank ferries and wind dials are new designs for the Playdate crank. Hammers are not included in this release: existing moving panels already occupy the timed striking-obstacle role. A true overlapping spiral and an enclosing funnel are also deferred because the current height-field collision model cannot represent two different floors at one XY coordinate. Cloud Switchback instead winds inward without crossing itself, using slopes and hairpins that remain readable in the fixed camera.

## Controls and teaching

Tilting controls force, preserving momentum. A jumps on enabled routes; while locked into a cannon it becomes Fire. B appears as Release at every control station. Slow entry locks the ball; leaving the region is required before it can lock again. Lift and ferry endpoints are clamped. Lift travel is 0.25 height units per crank degree; ferry travel takes 1.5 revolutions end to end. Reverse crank reverses travel. Fans turn one degree per crank degree. Cannons retain a fixed elevation and horizontal aiming range of −60° to +60°; they do not currently rotate freely through 360°.

Each new interaction gets a first-encounter guide. Wind control has its own guide, so learning an ordinary crosswind does not suppress the later dial tutorial. All relevant guides remain available through Left / Help. The generated Playdate illustration is reused with animated crank input and a separate diagram of the mechanism's response.

## Route sequence

| # | Route | Focus |
|---|---|---|
| 1 | Corner school | Rolling and corners; no jump |
| 2 | Downhill | Gravity without input |
| 3 | Momentum valley | Carry speed uphill |
| 4 | Brake bend | Counter-tilt before a turn |
| 5 | First hop | First gap and jump tutorial |
| 6 | Precision | Small landing pad |
| 7 | Jump chain | Multiple recovery-and-jump cycles |
| 8 | Hop and turn | Gaps separated by bends |
| 9 | Timed gate | Wait, then cross |
| 10 | Vanishing floor | Read the floor cycle |
| 11 | Shuttle | Ride an automatic ferry |
| 12 | Turn table | Ride an automatic rotating deck |
| 13 | Side sweep | Avoid moving panels |
| 14 | Spring garden | Introduction to rebound bumpers |
| 15 | Bumper slalom | Downhill, staggered bumpers, bend |
| 16 | Crosswind | Counter a lateral force |
| 17 | Crank crossing | First manual bridge |
| 18 | Bridge workshop | Two bridges and a connecting bend |
| 19 | Going up | One lift; jumping disabled |
| 20 | Two towers | Two successive lifts, then a descent |
| 21 | Cloud switchback | Inward winding road, slopes and hairpins |
| 22 | Crank ferry | One manually driven ferry; jumping disabled |
| 23 | Ferry zigzag | Diagonal crossing, island, second ferry |
| 24 | Wind workshop | Aim a fan from a control dial |
| 25 | Wind and springs | Two fan dials and bumpers |
| 26 | Cannon clouds | Capture, aim, fire and land |
| 27 | Cannon relay | Two launches with an angled second landing |
| 28 | High flight | Lift, high cannon, lower receiving road |
| 29 | Valley relay | Slope, gate, jump, automatic ferry |
| 30 | Sky circuit | Jump, rotation, sweep, trap and gate |
| 31 | Final flight | Earlier finale retained as practice |
| 32 | Storm run | Slope, springs, gate, jump, wind, ferry, trap |
| 33 | Sky odyssey | All mechanism types; five checkpoints |

## Finale rhythm

Lift and cannon → broad landing/checkpoint → gap and manual bridge → checkpoint → crank ferry and adjustable wind/bumper → checkpoint → vanishing floor and gate → automatic ferry/checkpoint → rotating deck → bend/checkpoint → final gap and moving panel → finish.

The final route spans roughly 4,200 world units horizontally, compared with the old finale's 944. This is a scope measure, not a measured completion time. Checkpoints advance monotonically; retries return to the latest reached point and reset mechanisms to their initial state.
