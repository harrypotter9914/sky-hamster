# 0.10.3 — launcher artwork and one device installation

Date: 2026-09-26. Full-game version 0.10.3 / build 39. Launcher name: Sky Hamster. The bundle ID and `/Games/sky-hamster-tilt.pdx` remain unchanged.

## Assets and checks

Dedicated cover, list icon and loading image exported at SDK-required 350×155, 32×32 and 400×240 sizes. The three selected-card frames match the new cover. Every exported image was checked for opaque black/white pixels and correct dimensions, then visually inspected at native size. Asset source and final prompts: [launcher notes](art/LAUNCHER-v0.10.3.md).

SDK compilation passed. Compiled `main.pdz` is byte-identical to 0.10.2, confirming this asset update does not change gameplay code. The title artwork export no longer overwrites launcher artwork.

## Hardware and cleanup

Installation completed through COM4 / F: and replaced the existing folder. Immediate launch initially missed the serial device during USB reconnection after eject. Retrying after reconnection succeeded; startup physics, mechanisms and occlusion checks passed with no captured error. Log: `tests/device-release-v0.10.3.log`. The installation script now bounds launch retries to handle this reconnect delay.

11 obsolete project packages were moved from the physical device to the local archive `builds/device-archive-2026-09-26/`. The archive count and byte totals match the original inventory. Total removed from the device: 1,361,792 file-content bytes (approximately 1.30 MiB; filesystem allocation can differ). Remaining game directories immediately after cleanup: `Seasons` and `sky-hamster-tilt.pdx`. Saved data and system files were preserved. Direct deletion was blocked; the successful cleanup used recoverable archival to the computer.

Archived packages: playdate-template, core-v0.5.8, v0.6.7, and eight control variants: brake, direct, latch, lock, reverse, speed, throttle and track.

Future updates use `./experiments/tilt-adventure/install.ps1`, which builds and installs the stable `sky-hamster-tilt.pdx` path. Versioned ZIP archives remain on the computer and GitHub. No new version folder is created on the device.

The SDK launcher shows the cover in card view and the icon with text in list view. Installation/startup verification is not a claim that the physical launcher screen was visually observed remotely.
