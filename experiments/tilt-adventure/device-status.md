Latest — 2026-09-26, tilt 0.2.0: 33-course release built and host/native Simulator checks passed. 0.1.9 was installed and launched on COM4 earlier in this session. Later attempts to install both the 0.2.0 hardware workload and release returned "No Playdate device detected." Last confirmed hardware version: 0.1.9. 0.2.0 is not confirmed installed; physical gesture feel, full route playthrough and hardware frame rate remain unverified. See VALIDATION-v020.md.

Previous attempts (superseded):
2026-09-26: SDK build and host checks passed. Title/tutorial/HUD visually checked in updated Simulator.
Hardware: COM4 present, but access denied because another Simulator process (115924) remains open. No successful installation confirmed yet.
GitHub: authentication rejected when fetching; local work preserved, remote synchronization pending renewed credentials.

Follow-up: the Simulator exited, but the Playdate USB device and COM port were then absent. Installation remains unconfirmed. Git push was stopped after authentication was cancelled; commit 29b0ade and tags are local only.
