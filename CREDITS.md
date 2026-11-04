# Sky Hamster — credits and sources

Game design and creative direction: **Yibo Wang / 王奕博** (game metadata: Wang Yibo).

- **Playdate platform, Lua SDK and CoreLibs:** Panic. The game uses the Playdate SDK; no SDK executables are distributed in the game download.
- **Fonts:** Asheville Sans 14 Bold (runtime name `ui-bold`) and Roobert 9 Mono Condensed, 11 Mono Condensed and 11 Bold, supplied by Panic with the Playdate SDK. Playdate fonts are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), as stated in the [SDK legal notices](https://sdk.play.date/3.1.2/Inside%20Playdate.html#legal). `ui-bold` is the project's renamed runtime copy of Asheville Sans 14 Bold.
- **Development setup:** [playdate-template](https://github.com/SquidGodDev/playdate-template) by SquidGodDev was the starting point for the VS Code/Lua build configuration. The template and editor tooling are separate from the playable `.pdx` download. The template's included [playdate-luacats](https://github.com/notpeter/playdate-luacats) annotations are by notpeter under the MIT license; editor annotations are not included in the game package.
- **Inspiration:** hamster-ball balance games, including *Hamsterball* by Raptisoft. Their art, sound recordings and level files are not used in this release.
- **Generated material:** AI-generated artwork is used for selected title, menu, tutorial, loading, mechanism and cloud assets, and promotional images. It is adapted into one-bit, fixed-size runtime images. AI assistance was also used for code and text. Prompt and conversion records are retained in the project's art and release directories.
- **Audio:** project-specific programmatically synthesized sounds and music. Earlier reference recordings are not included in the current release.
- **Historical audio reference:** [Marble Roll.mp3 by JuandreSound](https://freesound.org/people/JuandreSound/sounds/490913/), released under CC0. The original remains in `assets/audio-source/` for the v0.6.4 archive, with its [processing/source notes](assets/audio-source/README.md). Current rolling synthesis does not read or sample it.
- **Gameplay media:** screenshots and GIFs are rendered by the Playdate Simulator. Preview clips use scripted inputs and an isolated save; they are game rendering, not footage of a person playing on hardware.

Playdate and its associated trademarks belong to Panic. This is an independent game.

The public repository is available for inspection, without a newly granted project-wide open-source license. Retained third-party license files apply to their respective material; this notice does not replace them. Original template configuration is attributed above rather than reclassified as newly authored game code.
