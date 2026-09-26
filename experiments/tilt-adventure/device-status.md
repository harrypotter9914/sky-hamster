Latest — 2026-09-26, tilt 0.1.3: SDK build and host checks passed. Playdate detected on COM4. pdutil install copied builds/sky-hamster-tilt.pdx to the device and successfully ejected its F: data disk. pdutil run /Games/sky-hamster-tilt.pdx sent successfully; serial output echoed the run command and printed the existing regression PASS lines. No runtime error appeared in the captured output. Physical tilt feel, lift gestures and frame rate remain unverified.

Previous attempts (superseded):
2026-09-26: SDK build and host checks passed. Title/tutorial/HUD visually checked in updated Simulator.
Hardware: COM4 present, but access denied because another Simulator process (115924) remains open. No successful installation confirmed yet.
GitHub: authentication rejected when fetching; local work preserved, remote synchronization pending renewed credentials.

Follow-up: the Simulator exited, but the Playdate USB device and COM port were then absent. Installation remains unconfirmed. Git push was stopped after authentication was cancelled; commit 29b0ade and tags are local only.
