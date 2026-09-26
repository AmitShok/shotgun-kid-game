# Menu artwork

All menu textures are authored in Aseprite. Editable layered sources live in `assets/source/ui_*.aseprite`; their PNG exports live in `assets/textures`. Run `tools/art_menu_ui.lua` with Aseprite's batch scripting mode and a `root` parameter pointing at this project to regenerate them.

`scenes/ui/menu_theme.tres` shares nine-slice button states across the main, level-select, pause and options menus, including confirmation buttons. It also supplies matching switches, sliders, popup radio marks and dialog borders. Keep button texture margins at 13 pixels horizontally to preserve the endcap details. Keyboard focus uses cool corner marks; gold is reserved for pointer hover/pressed feedback. Existing alternating tilt remains in `scripts/menu_motion.gd`.

Validated with the rendered menu integration check on Godot 4.7.2 (18 checks passed), plus visual inspection of the main, level-select, options, pause, CRT dropdown and reset confirmation screens. Review runs used isolated save profiles.

Gameplay UI uses the same palette and Aseprite workflow: ui_hud_panel, ui_sign_panel, ui_keycap, ui_ammo_full/empty and ui_summit. HUD styles cover the status bar, hints, key readout and pause/completion emblem. Labels under a level's Signs container receive the shared sign_style.tres automatically. Existing visibility preferences still hide the corresponding UI. Godot 4.7.2 menu checks and settings write/read checks passed; loaded/empty ammo, completion and F3 readout were visually reviewed.
