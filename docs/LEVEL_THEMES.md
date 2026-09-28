# Shotgun Kid: level themes

All artwork was authored and exported in Aseprite, using the same pixel density and shared dark blue shadows as Lantern Ridge. Foreground surface caps carry the brightest edge; background shapes have lower contrast. Level layouts, player starts, exits, checkpoints, mines, and pickups were preserved.

| Level | Visual identity | Terrain | Ambient detail |
| --- | --- | --- | --- |
| Mossy Comet | Dense jungle on comet fragments, with vines, nebulae and a ringed planet | Moss-capped fractured stone, roots | Ferns, mushrooms, old markers, spores |
| Copper Cloud | Copper city above the clouds, with patinated domes, rooftops and sky bridges | Riveted copper, patina seams, pipes | Brass fixtures, gears, warm motes |
| Velvet Glacier | Enclosed blue-violet ice cavern, faceted walls, stalactites and refracted light | Snow-capped blue ice, fractures and icicles | Crystal clusters and drifting snow |
| Echo Orchard | Sunlit field of giant fruit trees, flowering vines and oversized wildflowers | Root-bound warm stone | Flowers, fruit bushes, carved posts, petals |

## Painting the levels

Open the level scene and select `Terrain/Ground`. Its dedicated `assets/<biome>_tileset.tres` is already assigned. New TileMapLayers in that level should use the same resource.

- Atlas source **0** uses 16Ã—16 cells, matching the old atlas coordinates exactly. Rows 0â€“2 are solid on World physics layer 1: surface, fill, bottom edge. Row 3 holds non-solid hanging details.
- Atlas source **1** has eight non-solid 32Ã—32 ornaments. Paint these on a separate decorative TileMapLayer (z_index -1); the TileSet grid remains 16px, so leave room for the larger artwork.
- Existing set dressing uses Sprite2D frames from the same ornament atlas under `Scenery/ThemeDetails`. The artwork's foot is 15 pixels below its center. These props do not create collisions or move automatically when you edit the ground: move them with the surfaces they sit on.
- Ground physics remain native TileSet polygons. No extra collision boxes or hand-set camera targets are needed.

## Editable source files

For each biome, `assets/source/` contains:

- `<biome>_backdrop.aseprite`: sky, far, middle and near layers in a 640Ã—400 document.
- `<biome>_terrain.aseprite`: 128Ã—64, eight columns and four rows of terrain.
- `<biome>_decor.aseprite`: 128Ã—64, four columns and two rows of ornaments.
- `<biome>_mote.aseprite`: the ambient particle.

PNG exports are in `assets/textures/` with matching names. The backdrop exports each layer separately as `<biome>_sky.png`, `_far.png`, `_middle.png`, and `_near.png`. Retain transparency in the moving layers.

Each `scenes/components/<biome>_backdrop.tscn` uses `scripts/biome_backdrop.gd`. Three independently scrolling planes establish depth; repeated copies cover the screen while the landing camera zooms. Vertical motion is bounded to keep painted edges outside the viewport. Level 1 and the main menu retain their original art.

`tools/art_biome_backgrounds.lua` regenerates only the four backgrounds. `tools/art_level_themes.lua` rebuilds the full art set and then invokes that background script, so it cannot restore the superseded backgrounds. Running it regenerates these documents and exports, overwriting manual changes; back up hand-edited Aseprite documents first. Use the `root` script parameter for this project directory and wait for Aseprite to finish before importing in Godot.

## Verification

Godot 4.7.2 only. `tests/biome_theme_test.gd` checks spawn collision, collision-free decorations, all parallax planes, and grounded prop placement in all four levels. Rendered previews are `docs/<biome>_theme.png`. Review uses an isolated `--save-file` so player progress and settings are not changed. Original painted data and actor positions were compared byte-for-byte before/after changing the art references.

Background material polish: irregular layered foliage, veined leaves, shaded fruit and petals, bark grooves and roots, recessed window frames and sills, copper roof seams/dome ribs/patina, and ice growth bands, branching fractures, trapped bubbles and refraction streaks. Details are painted in Aseprite at the original pixel scale. Distant fruit uses smaller silhouettes to maintain depth. Gameplay geometry and camera settings are unchanged.
