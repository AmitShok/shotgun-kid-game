# Shotgun Kid

A Godot 4 desktop platformer prototype about turning two shotgun shells into movement. Original pixel artwork is authored and exported in Aseprite. This is the first playable training yard, built for us to tune together.

## Play

Open `project.godot` in Godot and press **F6** with `training_yard.tscn` open, or **F5** from anywhere. The project is also registered as **Shotgun Kid** in your Godot Project Manager. Tested with the installed Godot 4.7.2 editor.

| Key | Action |
| --- | --- |
| A / D | Walk left / right |
| Space / W / Ctrl | Normal jump; release early for a shorter jump |
| J or Shift | Fire one shell |
| Arrow keys | Aim in eight directions |
| Escape | Pause / resume; keyboard menu navigation |
| R | Restart the entire yard |
| F3 | Show keys received by the game |

**Aiming:** with no arrow held, aim horizontally on the ground and down in the air. Hold two adjacent arrows to aim diagonally. Opposing arrows cancel.


The gun has **two shells**. Shooting pushes you opposite your aim. Shots have a short cooldown. A rapid second tap is buffered until that cooldown ends instead of being discarded. Each press fires at most one shell; holding does not auto-fire. Landing restores both shells immediately, so jumping again right away still leaves two aerial shots. A shot made while already grounded refills after its brief recoil recovery. No air reload and no reload key. A third aerial shot does nothing. Shooting resets movement to the recoil velocity, giving consistent directional boosts.

Shots destroy drones and incoming orange orbs in a 140-pixel cone. Terrain blocks the shot. This is an active, timed projectile block, not a passive shield. Touching enemies, orbs, spikes, or falling off the level returns you to the latest flag. Reach the green door to finish.

## Structure

- `scenes/actors/`: reusable player, drone, projectile, checkpoint, spikes, and exit scenes.
- `scenes/components/`: shotgun, burst effect, and basic platform scene.
- `scenes/levels/training_yard.tscn`: editor-visible level layout, real static bodies, explicit collision shapes, signs, actor instances, and HUD instance.
- `scenes/ui/hud.tscn`: container-based HUD and keyboard-accessible pause menu.
- `scripts/`: focused behavior scripts; no global autoload is needed.
- `assets/source/`: editable original `.aseprite` documents, including the four-pose kid sheet.
- `assets/textures/`: Aseprite-exported PNGs, imported with nearest filtering.
- `tools/`: reproducible Aseprite Lua artwork authoring script and source export helper.
- `tests/`: actual Godot physics integration and continuous traversal tests.
- `docs/`: design notes and a captured gameplay image.

Select the Player instance to tune speed, jump, gravity, and recoil in the Inspector. Edit the reusable player scene to adjust the camera or collision shape. Select Shotgun to tune its cooldown and range. Enemy fire interval is also exported.

## Art workflow

Open a file from `assets/source/` in Aseprite, edit it, save the source, then export the matching PNG to `assets/textures/`. Godot imports the result automatically. `tools/export_art.ps1` exports the saved source files in bulk. The `kid` document is a 96x24 sheet with four 24x24 poses; keep those cell dimensions unless you update the player scene.

All custom visual assets were created through the installed Aseprite application's Lua API. No generated-image service, external sprite packs, SVG substitutes, or Godot code-drawn sprites were used. Godot's built-in font and standard UI controls provide interface text and panels. No audio assets have been added; Aseprite is a visual-art editor.

`create_art.lua` recreates the initial source artwork and **overwrites matching source files**. Use the export helper for normal edits; do not rerun the authoring script over edited sources without making a copy first.

## Validation

Run with your Godot executable:

```powershell
godot --headless --path . --script res://tests/gameplay_test.gd
godot --headless --path . --script res://tests/traversal_test.gd
godot --headless --path . --script res://tests/manual_fire_test.gd
godot --headless --path . --script res://tests/jump_fire_test.gd
godot --headless --path . --script res://tests/diagonal_jump_test.gd -- --alternates
```

The gameplay test checks ground support, jump, recoil, ammo limits/refill, eight directions, projectile blocking, enemy damage, terrain occlusion, checkpoints, respawn, and completion. The traversal test crosses ten consecutive gaps without teleporting between ledges. It removes enemies and disables damage to isolate platform reachability; it is not a claim that combat difficulty has been human-playtested.

## Next decisions together

Arrow-key aiming is the chosen control scheme. Next, tune recoil strength, air steering and cooldown before expanding the campaign. Add fuller animation, sound, moving enemies, remappable controls, and more levels after the movement feels right.

## Jumping with diagonal aim

All four arrow diagonals are independent of normal jumping. Space, W, and Ctrl trigger the same jump action. If Space is not detected with certain arrow combinations, use W or Ctrl. Press F3 to see keys that reach the game: if SPACE stays -- while physically pressed, that key is not reaching Godot in that chord. Software cannot restore a key press the keyboard does not report. This behavior is documented in [Godot issue 56423](https://github.com/godotengine/godot/issues/56423), but has not been confirmed on your keyboard.
