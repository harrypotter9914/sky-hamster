# 0.3.0 — more kinds of decisions

The campaign now has 44 courses, adding 11 after the existing 33. Existing course numbers and saves stay valid. Each new mechanism has an introduction, a longer practice route, a first-encounter animated guide and a Goal reference page.

| Mechanism | Different player decision | Course introduction / practice |
|---|---|---|
| Conveyor | Stay grounded and counter its transport, or jump free | 34 Moving stones / 35 Belt bends |
| Pulsed steam | Read the active/quiet cycle before committing | 36 Steam windows / 37 Pressure alley |
| Extending bridge | Dock and build enough support across a void | 38 Unfold the road / 39 Twin drawbridges |
| Paired route gates | Open one branch while closing the other | 40 Choose a lane / 41 Fork in the wind |
| Magnetic field | Keep distance from edge attraction and correct early | 42 Magnetic island / 43 Polar crossing |

44 Grand expedition extends the earlier Sky Odyssey with these five mechanisms and two further checkpoints, for seven in total. The old 33rd course remains available. Route 41 offers a faster conveyor branch and a timed steam branch that reconnect at a checkpoint. Magnets affect nearby airborne balls too; unlike conveyors, jumping is not an automatic escape from attraction.

Controls remain contextual: crank Extend or Route at the new stations, B Release, A Jump while free and Fire in a cannon. The bridge remembers its extension until retry; reverse crank retracts it. Gate choice follows crank angle, always opening exactly one of the paired lanes. Station capture, release and leave-before-reentry rules are shared with existing machinery.

## Visual implementation

Reuse established native stone, plank, gear/dial and hazard-panel materials. Conveyor surfaces have a black belt with white bars moving in the actual force direction. Steam outlets have metal rims and grille slots, with flow marks only during a pulse. Magnetic pedestals have a high-contrast horseshoe and animated field arcs. Extending bridges use the existing textured bridge renderer with changing physical width. Tutorials reuse the Playdate illustration and fixed storyboard grid.

## Validation and limits

`python tests/check_workshop.py` includes all preceding regression suites plus grounded-only belt force, timed jet windows, extension endpoints and support, paired gate switching and actual collision, magnetic falloff, all 44 course update paths, seven final checkpoints and tutorial coverage. SDK compilation passed. Native Simulator exported all five guides in three phases and representative world views for visual inspection.

Visual review found subtle belt/nozzle markings and duplicate extension labels; these were corrected. Reviewing the final fork found a middle lane that could bypass both gates; a fixed center barrier now makes the branch choice meaningful.

The native Simulator completed the six-route workload (34, 36, 38, 40, 42, 44; 180 updates each) without runtime errors. Raw measurements are retained in `tests/simulator-workload-v030.json`, marked `device: false`. They verify the workload executes; their desktop timing must not be treated as Playdate performance.

The installation attempt returned `No Playdate device detected`. No hardware FPS, physical gesture validation or human completion of all new routes is claimed. The added mechanisms reuse screen culling and bounded terrain caches, but hardware profiling is still needed, especially for the extended finale.
