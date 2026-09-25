# Building levels

## Paint solid ground
1. Open `scenes/levels/training_yard.tscn` and select a TileMapLayer under `Terrain`.
2. Use the TileMap editor's Paint, Line, Rectangle, and Eraser tools. The atlas uses 16 x 16 cells.
3. The top three atlas rows are solid: snowy tops, stone fill, and bottom stone edges. The fourth row contains hanging rock/icicle decorations with no collision.
4. Run the level with F6. Godot creates and removes collision automatically as tiles are painted or erased.

All 13 layers reference `assets/terrain_tileset.tres`, which has a World physics layer (bit 1) and full-cell collision polygons on solid tiles. Existing layer positions preserve the exact platform heights and jump distances, including the half-cell-height ledge. There are no StaticBody2D or CollisionShape2D ground boxes under Terrain. Player, mine, spike, and checkpoint shapes remain because those are actors, not terrain.

For a new island, add a TileMapLayer beneath Terrain, assign the shared TileSet, and paint it. Keep the layer's collision enabled and scale at 1. Use 16-pixel grid snapping for new construction. Reposition scenery so tree trunks, lantern feet, and plants meet the tile surface. Hanging banners belong on the stone face.

## Four prepared levels
Open any of these independent scenes and press F6 to preview it while designing:
- `scenes/levels/mossy_comet.tscn`
- `scenes/levels/copper_cloud.tscn`
- `scenes/levels/velvet_glacier.tscn`
- `scenes/levels/echo_orchard.tscn`

Each scene includes the original layered background and snow, a native Ground tilemap using the shared physics TileSet, Player, HUD, checkpoint, exit door, and empty Mines, Hazards, Scenery, and Signs containers. The only painted area is a small removable flat test floor; no challenge layout or decorative placement has been designed for you.

Paint Terrain/Ground, move Player to your start, move the exit to the finish, and move/duplicate the root checkpoint flags as needed. Drag `boost_mine.tscn` into Mines and `spikes.tscn` into Hazards from `scenes/actors/`. Place the existing Aseprite scenery in Scenery. The root node exposes Level Title, Camera Bounds, and Fall Limit Y; adjust these to fit a larger or taller layout. Keep the named Player/HUD/Signs nodes and root checkpoint flags so the shared scripts can find them.

The shared backdrop is `scenes/components/ridge_backdrop.tscn`, copied exactly from Lantern Ridge. New levels reference it without changing the first level's background.

## Campaign order and names
The single ordered campaign catalog is `data/level_catalog.tres`. It references five resources in `data/levels/`. Edit a level resource's Title and Scene Path to rename or redirect an entry; edit the level root's Level Title for its HUD title. Add future resources to the catalog's Levels array. Both menu selection and progression use this same catalog.

Only level 1 starts unlocked. Touching an exit saves completion and unlocks the next entry; the completion menu offers Next Level. Completed levels stay replayable, and the final level has no Next Level button. Out-of-order F6 previews are allowed for editing but cannot skip campaign unlocks.

Restart Level restarts the current scene and clears checkpoint progress while preserving unlocked levels and settings. Options > Reset progress (lock levels 2-5) asks for confirmation, clears all completion/unlock and checkpoint progress, and keeps settings. When used during gameplay it returns to the main menu so the next tester starts clean. Progress uses an ordered completion count, so changing the catalog order during development should be followed by Reset Progress.

## TileSet maintenance
`tools/build_terrain.gd` configures the atlas physics and can migrate old platform boxes. It preserves existing painted cells and layer positions, and repeated runs do not rebuild the layout. The shared external TileSet lets collision edits apply to all levels using it. Visual textures continue to come from the editable Aseprite source files.
