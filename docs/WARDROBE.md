# Player wardrobe

Open **Wardrobe** from the main menu or pause menu. Hats, scarves, and outfits equip independently and save immediately. All items are available from the start. Randomize picks each category independently; Reset look restores the original palette. Restarting levels or resetting campaign progress preserves the outfit.

There are 12 hats plus Bareheaded, 12 scarves plus No Scarf, and 12 outfits: 2,028 combinations. The live preview offers Idle, Run, Air, and Turn. Scarves use the existing trailing animation with per-style textures and lengths. Cosmetics do not alter collision or movement.

## Files and extension workflow

- `tools/art_wardrobe.lua`: Aseprite batch authoring script. Run with Aseprite's `--batch --script` from the project directory. This generates the six editable `.aseprite` sources, six PNG exports, and the JSON/GDScript catalogues.
- `assets/source/wardrobe_*.aseprite`: editable source artwork.
- `assets/textures/wardrobe_*.png`: runtime atlases and wardrobe frame/checkmark.
- `data/wardrobe_items.gd`: generated item IDs, display names, row indices, and scarf lengths. `wardrobe.json` is the matching portable metadata.
- `scripts/wardrobe_catalog.gd`: validation, defaults, cached atlas regions and explicit texture preloads for exports.
- `scripts/player_appearance.gd`: composes clothes, hat and neck wrap, and applies the animated scarf style.
- `scenes/ui/wardrobe_panel.tscn` / `scripts/wardrobe_panel.gd`: shared main/pause menu panel. Preview uses an isolated World2D and is excluded from the gameplay player group; movement/input/camera are disabled.

Each atlas row uses eight 24x24 frames: idle 0-1, run 2-5, air 6-7. Hats and neck wraps match the body's animation and horizontal facing, inheriting its squash/stretch and transparency. Tail swatches are 5x3 per row. The final hat and neck rows are transparent for unequipped choices.

To add cosmetics, extend the Aseprite script and catalogue together, preserve existing stable IDs, and export again. If editing source files manually, export the matching PNG without rerunning the generator (which regenerates source art). Existing saves use `[wardrobe]` keys for each category; unknown or missing IDs fall back to defaults. Progress and settings continue using the same atomic save path.

## Validation

Godot 4.7.2: `tests/wardrobe_test.gd` checks menu fit, UI equipment, all frame/facing combinations for each item, preview isolation, pause navigation, restart preservation, and fresh-process save restore (`--read`). Use an isolated `-- --save-file=user://wardrobe_test.cfg`. Rendered runs save screenshots under docs. Scarf/particles, feel/audio, settings write/read, and five-level progression regressions also pass.
