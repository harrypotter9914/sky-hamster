# Release and verification evidence

[← Project home](../README.md) · [Install](PLAY.md) · [Journal](JOURNAL.md)

**Current source and public package: v0.12.12 / build 62 / 53 courses.** The official title is **Sky Hamster**, verified against game metadata, Logo, and [itch.io](https://hajimi9914.itch.io/sky-hamster). The current package is `sky-hamster-v0.12.12.zip`, containing `sky-hamster-tilt.pdx`.

## What the existing hardware records establish

| Record | Actual scope |
| --- | --- |
| [v0.12.9 final hardware record](../release/itch-v0.12.9/hardware/README.md) | 53-course / 761-scene scripted hardware sweep, 28 feature groups, and 47 audio playback checks. This is not hand-play completion of all routes. |
| [v0.12.10 validation](../experiments/tilt-adventure/VALIDATION-v0.12.10.md) | Shortcut instruction and fallback-jump flows, Simulator/device views. |
| [v0.12.11 validation](../experiments/tilt-adventure/VALIDATION-v0.12.11.md) | Context menus, hidden developer access, returns, and isolated progress. |
| [v0.12.12 validation](../experiments/tilt-adventure/VALIDATION-v0.12.12.md) | Twelve native Settings states on Simulator/device; installed package identity, save preservation, and normal startup. Not another all-course FPS sweep. |
| [Installed v0.12.12 identity](../release/itch-v0.12.12/hardware/installed-release.json) | Normal game installation and per-file verification record. |

Some old release notes correctly say itch.io still had 0.12.9 **at that time**. The public download was subsequently updated to 0.12.12. This status note supplements rather than rewrites that historical evidence.

## This repository-showcase pass — 2026-11-04

Gameplay source and release version are unchanged. The build script's machine-specific SDK fallback was replaced with a user-relative fallback, with explicit path/output checks. Documentation, translation, portfolio copies, and curated media changed. No new physical-device playtest is claimed for this pass. Current build/link/security checks are recorded in [publication verification](PUBLICATION-CHECKS.md).

Complex courses still have recorded loading waits and slower dense scenes. For concrete before/after data, see [0.12.2](../experiments/tilt-adventure/VALIDATION-v0.12.2.md), [0.12.3](../experiments/tilt-adventure/VALIDATION-v0.12.3.md), and the [bilingual reflections](JOURNAL.md).
