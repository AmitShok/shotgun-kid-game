# Validation — 25 September 2026

Godot 4.7.2 on Windows; rendered checks use OpenGL compatibility and Intel Iris Xe.

- Gameplay: 28 checks passed, including ground support, eight-way aim, ammo, landing refill, checkpoints, completion, and sound events.
- Mines: 18 checks passed, including safe contact/blast, impulse, range/cone/wall blocking, recharge, audio, reset, and landing on the high shortcut.
- Jump/fire: 8 checks passed.
- Manual firing: 15 checks passed, including Shift/J diagonals and cooldown buffering.
- Base route: all 10 consecutive gaps passed with the revised controller. Mines/damage are disabled only in this geometry test.
- Rendered audio/feel: 28 checks passed, including playable samples, sound dispatch, footsteps, ground reversal, momentum preservation, bounded camera effects, effects toggle, and persisted volume.
- Rendered game and pause menu inspected for layout and legibility. Editable Aseprite sources and native TileMapLayers included.

A 72-combination diagonal-jump matrix is also included. Synthetic input tests software handling, not physical keyboard rollover. The user's keyboard was observed via F3 to block Space with Right+Down. Space remains primary, W/Ctrl are alternatives, and no aim lock is enabled.

Headless runs bypass inaudible playback but verify event dispatch. Actual playback is exercised in the rendered test. Human playtesting is still required for sound balance, movement feel, and pacing.


## Pause options and persistence update
- Rendered options/pause layout checked; captures: options_menu.png and pause_menu.png.
- Three separate processes: 13 assertions passed for submenu navigation, text visibility, persisted volume/camera/text settings, checkpoint restore, and restart preserving settings while clearing progress across another launch. Each exited through the Quit button signal.
- Isolated save profiles used; actual player save untouched by tests.
- Regression checks: gameplay 28/28, mines 18/18, feel/audio 28/28. Headless import passed without script errors.


## Independent camera effects and grounded look
Rendered camera/scenery test: 30 checks passed, including ground look, no airborne aim panning, independent shake/zoom gates, supported tree/plant/lantern/sign bases, and options fitting the viewport. Visually checked start, checkpoint sections, and exit. Three floating trees relocated, an edge plant moved inward, and a redundant checkpoint sign removed. Existing Aseprite artwork retained. Mine and feel/audio regressions passed (18 + 28 checks). Separate-process save test verified all four camera preferences persist.


## Main menu, CRT, and native tile physics
- Rendered menu/tiles/CRT integration: 18 checks passed for initial keyboard focus, level selection, shared options, live CRT toggling, return to main menu, shared external TileSet physics, and painting/erasing solid cells.
- Visual checks: main menu, level selection, options, and gameplay with CRT on/off (PNG captures in this folder).
- Native-tile regression: gameplay 28/28, mines 18/18, continuous traversal through all ten gaps passed.
- Separate-process save tests confirmed CRT-off and independent camera preferences survive relaunch, checkpoint resume works, and Restart clears progress without clearing preferences.
- Updated scenery support test uses real physics rays against tiles instead of legacy collision boxes.


## Five-level progression and editable scaffolds
Rendered progression test verifies all five playable spawns, backgrounds and starter structure, real exit triggers, sequential unlocks, Next Level transitions, final-level behavior, locked selection rejection, repeated/out-of-order completion protection, and menu layout. Separate-process tests verify persistence and reset behavior, including confirmation cancellation, returning to the main menu from gameplay, and preserving settings. Test profiles are isolated from player data. Captures: level_select_progression.png, options_progression.png, level_template.png.


## Menu and HUD visual polish
Tilted menu headings and buttons, smooth focus/hover/press transforms, short page fades, warm focus accents, beveled panel edges and shadows. Settings rows and gameplay HUD text stay stable. Rendered menu integration passed all 18 existing checks; screenshots reviewed for main menu, five-level selector, crowded Options panel, and pause menu. Native focus/navigation and progression logic retained.


## Airborne shell pickup
Rendered pickup test: 11 checks passed for actual overlap collection, grounded/full-ammo rejection, one-shell restoration and capacity cap, fade, three-second reuse, pause behavior, usable restored ammo, and death reset. Existing gameplay regression: 28/28 checks passed. Screenshot: shell_pickup.png. Tests used isolated save files.


## Godot 4.7.2 verification, September 26
Verified engine 4.7.2.stable.official.ed1daf0bf. Fixed mixed indentation in level.gd checkpoint restoration. Clean editor import; gameplay 28, mine 18, diagonal jump 72, ten-gap traversal, rendered menu/CRT 18, rendered feel/audio 28, rendered shell pickup 11, and separate-process campaign progression/reset suites all passed. Player save files were isolated from tests. Project launcher tools/open_editor.ps1 checks version before opening the editor. Menu button tilt now chooses a stable small random angle per button, capped at 1.7 degrees (smaller in the tightly packed Options panel).


## Terrain-aware landing framing
Godot 4.7.2: 11 dedicated checks passed for high-flight player/ground visibility between HUD panels, bounded zoom independent of cosmetic settings, live moved/painted/erased terrain detection, no airborne aim panning, empty-gap behavior, landing recovery, and reset. Rendered screenshot: landing_camera.png. Existing camera/scenery (30) and feel/audio (28) checks passed with assertions separating cosmetic zoom from landing framing.


## Smoother platform-height transitions
Landing camera now blends detected world-space surface heights, caps upward retargeting speed, retains its previous surface across gaps shorter than 0.18 seconds, and waits 0.10 seconds after touchdown before returning to normal. Zoom-in and upward framing recovery are gentler. Rendered Godot 4.7.2 landing-camera suite: 14/14 passed, including higher-platform height blending, bounded frame-to-frame zoom change, short-gap retention, high-flight visibility, and normal landing recovery.
