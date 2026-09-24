# Shotgun Kid

A Godot 4.7 2D traversal platformer set in Lantern Ridge. Open `project.godot` in Godot and press F6 on the level or F5 to run the project.

## Controls
- A/D: move.
- Space: jump (W or Ctrl are alternatives).
- Arrow keys: aim in eight directions, including diagonals.
- Shift or J: fire.
- Esc: pause; R: restart the ridge; F3: input diagnostic.

The shotgun holds two shells. Shooting pushes you opposite your aim; landing reloads instantly. Normal jumping costs no shells. Shoot floating mines for extra momentum. Mines are safe to touch and recharge after exploding. Avoid spikes and falls, touch checkpoint flags, and reach the mountain gate. A keyboard's physical key rollover can prevent certain simultaneous keys from reaching the game; F3 displays received input.

## Options and saved progress
Press **Esc > Options** for sound volume, camera shake, camera zoom, separate shot/mine shake switches, controls and hints box, level hints, and shell HUD. Turn off all three text switches for a clean gameplay view. Esc from Options returns to the pause menu; Esc again resumes. Menus support keyboard focus and mouse input.

Settings save immediately. Touching a checkpoint flag saves its position; reopening the game resumes at that flag with two shells. **Restart ridge [R]** clears the saved checkpoint and starts from the beginning, keeping your options. **Quit game** exits from the pause menu. The completion menu also offers Options, Restart, and Quit.

The save is local at `%APPDATA%/Godot/app_userdata/Shotgun Kid/settings.cfg`. Existing volume and camera preferences are retained. Missing or invalid preferences use defaults, and an unknown checkpoint falls back to the start. Progress stores the flag and position; loading resolves the flag's current safe spawn position so level edits cannot strand the player.

## Sound and movement
There are 12 original effects: footsteps, jump, landing, shotgun, empty click, reload, mine explosion, mine recharge, checkpoint, respawn, completion, and UI. Footsteps follow actual ground distance with pitch variation. Mine audio fades with distance.

Movement includes quick acceleration and reversals, air steering, coyote time, jump buffering, and variable jump height. Downward shots preserve lateral momentum; mine momentum carries into follow-up shots. Bounded shake, subtle zoom pulses, velocity look-ahead, and sprite squash/stretch add feedback without changing collisions.

## Structure and editing
- `scenes/actors/`: reusable player, boost mine, checkpoint, spikes, and exit.
- `scenes/components/`: shotgun, particles, explosion, and platform.
- `scenes/levels/training_yard.tscn`: Lantern Ridge with editable TileMapLayers, explicit platform collisions, scenery, and actors.
- `scenes/ui/hud.tscn`: HUD, pause menu, and options submenu.
- `scripts/player.gd`: locomotion; `player_camera.gd`: camera feedback.
- `scripts/sfx.gd`: autoload for the bounded audio voice pool.
- `scripts/save_data.gd`: autoload for preferences and checkpoint persistence.
- `assets/source/`: editable layered Aseprite documents.
- `assets/textures/`: exported PNGs, including the tile atlas and character sheet.
- `assets/terrain_tileset.tres`: native Godot TileSet.
- `assets/audio/`: original WAV effects.

Movement and mine tuning are exposed in the Inspector. TileMapLayers provide artwork; each platform's CollisionShape2D defines its solid area. Resize both when changing platform dimensions.

## Asset workflow
All custom visual assets were authored and exported in Aseprite using its Lua API. No reference-game assets, external sprite packs, or image-generation services were used. Godot's built-in font and controls provide text and panels.

Edit the Aseprite source and export its PNG, or run `tools/export_art.ps1`. `tools/art_lantern_ridge.lua` recreates matching source documents and overwrites them, so back up manual edits first. `tools/build_terrain.gd` rebuilds the atlas and terrain layers. `tools/make_sounds.py` creates original WAV effects using Python's standard library without external samples.

## Checks
Use an isolated save profile for tests to protect real player progress. Start each gameplay suite with a fresh test profile:

```powershell
godot --headless --path . --script res://tests/gameplay_test.gd -- --save-file=user://gameplay-test.cfg
godot --headless --path . --script res://tests/mine_test.gd -- --save-file=user://mine-test.cfg
godot --path . --script res://tests/feel_audio_test.gd -- --save-file=user://audio-test.cfg
```

Other regression scripts cover traversal, manual fire, jump/fire, and diagonal jump combinations (`--alternates`). Headless tests verify sound dispatch; rendered tests exercise playback.

Run `tests/settings_save_test.gd` across three processes using `-- --save-file=user://options_test.cfg --write`, then the same profile with `--read`, then with neither phase flag. This checks persisted options, checkpoint loading, restart semantics, and Quit. Screenshots are in `docs/`.

This remains a prototype to tune together. Human feedback is still needed on movement feel, sound balance, and level pacing.

Grounded arrow-key aiming gently pans the camera in that direction. Releasing aim or leaving the floor eases the view back to normal; airborne aim never controls the look offset. Camera shake is the master shake switch, with independent shot and mine switches beneath it. Zoom works independently. All four settings persist, and old camera-effect preferences migrate automatically.
