# Build the current Playdate game

[← Project home](../README.md) · [Source](CODE.md) · [Install](PLAY.md)

## Requirements

- [Playdate SDK](https://play.date/dev/) with `pdc`, Simulator, Lua CoreLibs. This pass compiled with **3.1.2**; historical release checks used 3.1.1.
- PowerShell 7 for the Windows script and fingerprint check. No C compiler.
- Optional Python 3 + `lupa` for host Lua checks, not needed to play.

## Windows / PowerShell 7

From the repository root:

```powershell
$env:PLAYDATE_SDK_PATH = 'C:/path/to/PlaydateSDK'
./experiments/tilt-adventure/build.ps1
```

Output: `builds/sky-hamster-tilt.pdx`. Open with Simulator. The script checks baked-art fingerprints. Map/render changes require the [native-art rebuild](../experiments/tilt-adventure/art/RUNTIME-v0.12.2.md), not bypassing stale-art errors.

Included runtime images/fonts/audio are prepared for normal compilation. Art/capture scripts have additional documented dependencies; those are not required merely to compile.

For macOS/Linux, set `PLAYDATE_SDK_PATH` and compile from the root:

```sh
mkdir -p builds
"$PLAYDATE_SDK_PATH/bin/pdc" -sdkpath "$PLAYDATE_SDK_PATH" experiments/tilt-adventure/source builds/sky-hamster-tilt.pdx
```

This uses checked-in assets; the fingerprint guard is in PowerShell. This pass did not run macOS/Linux builds.

## Optional host checks

```sh
python -m pip install lupa
python experiments/tilt-adventure/tests/check_context_menus.py
python experiments/tilt-adventure/tests/check_release_menus.py
python experiments/tilt-adventure/tests/check_playtest_controls.py
```

Run from the root. Stubs test logic, not physical sensor feel, native graphics constraints, or hardware FPS. Tests include historical fixtures and current flows. [Release evidence](RELEASE.md) distinguishes actual checks.

## Structure

| Path | Purpose |
| --- | --- |
| `experiments/tilt-adventure/source/` | Current Lua release and prepared assets. |
| `experiments/tilt-adventure/tests/` | Regressions, captures, hardware records. |
| `experiments/tilt-adventure/art/` | Source art, prompts/conversion, bake tools. |
| `docs/reflections/` | Early bilingual reflections. |
| `experiments/tilt-adventure/REFLECTION.md` | Continuing bilingual journal. |
| `experiments/control-variants/` | Eight reconstructed experiments. |
| Root `source/`, `build.ps1`, `.vscode/` | Historical crank game/editor setup, not current target. |
| `release/` | Versioned publishing/validation evidence. |
| `media/`, `portfolio/` | Curated showcase and design PDFs. |

## Install/update

Players: [itch.io and sideload](PLAY.md). Developers: connect/unlock Playdate and choose **Device → Upload Game to Device** in Simulator. Keep bundle ID `com.wangyibo.skyhamster.tilt` and the installation folder to preserve saves. Root tasks compile the older game, not the current release.

No SDK binaries are bundled. [Credits/third-party terms](../CREDITS.md).
