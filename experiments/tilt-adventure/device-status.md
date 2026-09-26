Pending — 2026-09-26, version 0.10.4 / build 40: corrected illustrated loading and mechanism-audio build compiles and passes native Simulator startup/course checks. Final installation attempts reported No Playdate device detected. Early draft transfer predates the native bootstrap correction and is not final-release validation. Reconnect and overwrite /Games/sky-hamster-tilt.pdx; hardware performance and listening remain unverified. See VALIDATION-v0.10.4.md.

Latest — 2026-09-26, version 0.10.3 / build 39: dedicated launcher cover/icon installed to /Games/sky-hamster-tilt.pdx. Launch succeeded after USB reconnected; startup checks passed. Eight control variants and three old/classroom packages archived off the device; remaining game directories are Seasons and sky-hamster-tilt.pdx. Saves retained. Future updates overwrite this same folder. See VALIDATION-v0.10.3.md and tests/device-release-v0.10.3.log.

Last confirmed game installation — 2026-09-26, unified 0.10.2 (original label 0.4.2 / build 15): regression suite and SDK build passed. After USB reconnection, installed successfully through COM4 / F: and launched at /Games/sky-hamster-tilt.pdx. Startup physics/mechanism/occlusion checks passed with no captured error. Replaced the same Tilt installation folder. Physical gesture feel still needs hands-on evaluation. See VALIDATION-v0.10.2.md and tests/device-release-v042.log.

Previous — 2026-09-26, tilt 0.10.1 (build 14): installed successfully through COM4 / F: and launched at /Games/sky-hamster-tilt.pdx after the final workloads. Production startup checks passed with no captured error. The release replaced the temporary workload in the same installation folder. Current normal-speed samples are 29.17–30.01 FPS; final-course stress is 26.71 FPS. Visual baseline and regression comparisons passed. Brief long frames remain; see VALIDATION-v0.10.1.md and tests/device-release-v041.log.

Previous — 2026-09-26, tilt 0.10.0 (build 13): installed successfully on the physical Playdate through COM4 / F: and launched at /Games/sky-hamster-tilt.pdx. Production startup checks passed with no captured error. The normal release replaced the temporary performance workload in the same installation folder.

Hardware profiling completed in both full-route camera/cache stress mode and normal-speed scene samples. Final stress route 44 improved from 11.53 to 24.70 FPS; normal-speed samples span 26.34–29.98 FPS. Brief frame-time spikes remain (up to 62 ms in final stress and 60 ms in normal-speed samples); this is not a claim of perfect 30 FPS or a complete human playthrough. See VALIDATION-v0.10.0.md and tests/device-release-v040.log.

Previous — tilt 0.9.0: 44-course build and regressions passed. Installation returned No Playdate device detected. This release was not confirmed installed at that time; superseded by the successful 0.10.0 installation above.

Latest — 2026-09-26, tilt 0.8.0: 33-course release built and host/native Simulator checks passed. 0.7.9 was installed and launched on COM4 earlier in this session. Later attempts to install both the 0.8.0 hardware workload and release returned "No Playdate device detected." Last confirmed hardware version: 0.1.9. 0.8.0 is not confirmed installed; physical gesture feel, full route playthrough and hardware frame rate remain unverified. See VALIDATION-v0.8.0.md.

Previous attempts (superseded):
2026-09-26: SDK build and host checks passed. Title/tutorial/HUD visually checked in updated Simulator.
Hardware: COM4 present, but access denied because another Simulator process (115924) remains open. No successful installation confirmed yet.
GitHub: authentication rejected when fetching; local work preserved, remote synchronization pending renewed credentials.

Follow-up: the Simulator exited, but the Playdate USB device and COM port were then absent. Installation remains unconfirmed. Git push was stopped after authentication was cancelled; commit 29b0ade and tags are local only.
