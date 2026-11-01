# Building levels

## Paint solid ground
1. Open `scenes/levels/training_yard.tscn` and select a TileMapLayer under `Terrain`.
2. Use the TileMap editor's Paint, Line, Rectangle, and Eraser tools. The atlas uses 16 x 16 cells.
3. The top three atlas rows are solid: snowy tops, stone fill, and bottom stone edges. The fourth row contains hanging rock/icicle decorations with no collision.
4. Run the level with F6. Godot creates and removes collision automatically as tiles are painted or erased.

All 13 layers reference `assets/terrain_tileset.tres`, which has a World physics layer (bit 1) and full-cell collision polygons on solid tiles. Existing layer positions preserve the exact platform heights and jump distances, including the half-cell-height ledge. There are no StaticBody2D or CollisionShape2D ground boxes under Terrain. Player, mine, spike, and checkpoint shapes remain because those are actors, not terrain.

For a new island, add a TileMapLayer beneath Terrain, assign the shared TileSet, and paint it. Keep the layer's collision enabled and scale at 1. Use 16-pixel grid snapping for new construction. Reposition scenery so tree trunks, lantern feet, and plants meet the tile surface. Hanging banners belong on the stone face.

## Four authored campaign levels
Open any of these independent scenes and press F6 to preview it while designing:
- `scenes/levels/mossy_comet.tscn`
- `scenes/levels/copper_cloud.tscn`
- `scenes/levels/velvet_glacier.tscn`
- `scenes/levels/echo_orchard.tscn`

Each scene has its own Aseprite biome background, ambient particles, native physics TileSet, Player, HUD, checkpoints and exit. Levels 2–5 now contain authored traversal campaigns with 10, 12, 14 and 16 encounters. See CAMPAIGN_DESIGN.md for their routes, backups, validation, and the root traversal_route metadata used by long-gap camera framing. Small themed props sit under Scenery/ThemeDetails; move or remove these as you change the terrain. The one-shot tools/design_campaign.gd overwrites all four scenes; do not run it after hand editing unless you intend to rebuild them.

Paint Terrain/Ground, move Player to your start, move the exit to the finish, and move/duplicate the root checkpoint flags as needed. Drag `boost_mine.tscn` into Mines and `spikes.tscn` into Hazards from `scenes/actors/`. Place the existing Aseprite scenery in Scenery. The root node exposes Level Title, Camera Bounds, and Fall Limit Y; adjust these to fit a larger or taller layout. Keep the named Player/HUD/Signs nodes and root checkpoint flags so the shared scripts can find them.

Lantern Ridge retains `scenes/components/ridge_backdrop.tscn`. Levels 2â€“5 reference their respective `<biome>_backdrop.tscn` scenes and `assets/<biome>_tileset.tres`. See `LEVEL_THEMES.md` for the atlas guide and source files.

## Campaign order and names
The single ordered campaign catalog is `data/level_catalog.tres`. It references five resources in `data/levels/`. Edit a level resource's Title and Scene Path to rename or redirect an entry; edit the level root's Level Title for its HUD title. Add future resources to the catalog's Levels array. Both menu selection and progression use this same catalog.

Only level 1 starts unlocked. Touching an exit saves completion and unlocks the next entry; the completion menu offers Next Level. Completed levels stay replayable, and the final level has no Next Level button. Out-of-order F6 previews are allowed for editing but cannot skip campaign unlocks.

Restart Level restarts the current scene and clears checkpoint progress while preserving unlocked levels and settings. Options > Reset progress (lock levels 2-5) asks for confirmation, clears all completion/unlock and checkpoint progress, and keeps settings. When used during gameplay it returns to the main menu so the next tester starts clean. Progress uses an ordered completion count, so changing the catalog order during development should be followed by Reset Progress.

## TileSet maintenance
`tools/build_terrain.gd` configures the atlas physics and can migrate old platform boxes. It preserves existing painted cells and layer positions, and repeated runs do not rebuild the layout. The shared external TileSet lets collision edits apply to all levels using it. Visual textures continue to come from the editable Aseprite source files.


## Floating shell pickups
Drag `scenes/actors/shell_pickup.tscn` into a level's Pickups container and position it along an airborne route. It restores exactly one shell on contact while airborne, up to the two-shell maximum. Full-ammo or grounded players do not consume it. It fades to a faint silhouette for three seconds, then becomes usable again. Recharge Seconds and Bob Phase are editable in the Inspector. Death resets all pickups, and pausing freezes recharge. The art reuses the existing Aseprite shell and glow textures.

Lantern Ridge includes one example at (245, 465). The themed levels preserve any pickups you have placed; add more in their Pickups containers as needed.


## Terrain-aware landing camera
The player camera scans downward against World collision (layer 1) during flight, using the surface directly beneath the player or nearby travel-direction probes over gaps. It smoothly reframes the player and landing surface, reserving space for the HUD and hints. Native tile painting, erasing, and layer movement automatically affect the next scan; no ground-height markers are required.

The Player/Camera2D Inspector exposes Minimum Landing Zoom (default 0.55) and Ground Scan Distance (1000 world pixels). Cosmetic speed/impact zoom has been removed; this automatic landing framing remains active. Empty gaps return toward normal zoom with a bounded downward look. Landing and respawning restore normal framing; airborne arrow aiming never controls the camera. Keep the level root's Camera Bounds large enough to include the playable terrain. At distances beyond the zoom limit, both the player and ground may not fit simultaneously.

## Room-based levels (current workflow)
Levels are chains of camera-locked rooms written as text in `data/rooms/<level>.txt` (one character per 16px tile; the legend is at the top of `scripts/room_map.gd` and `tools/build_rooms.gd`). Lantern Ridge uses `data/rooms/lantern_ridge.txt`.

1. Edit the room text. Standard rooms are 40x23 tiles; place rooms side by side or stacked by their `@room NAME COL ROW` origin. `P` marks a room's respawn point.
2. Rebuild the scene: `godot --headless --path . --script res://tools/build_rooms.gd -- --map=lantern_ridge`. This replaces terrain, rooms, hazards, mines, pickups, exit and props; backdrop, Player and HUD are kept.
3. Prove it is still beatable: `godot --headless --path . --script res://tests/room_routes_test.gd -- --map=lantern_ridge`. Each `@route FROM TO` block is a recorded input sequence that must carry the player from FROM's respawn point to a safe landing in TO (`exit` for the gate, `gold` for the golden shell). Add `--only=R05 --trace` to print positions (and the phase) every 6 frames while tuning one room, or `--trace-step=1` for every frame.

In room mode the camera clamps to the current room at zoom 1, entering a room refills shells and saves progress there, death returns you to that room's respawn point, and falling out of a room's bottom is a death. A golden shell banks once you stand on solid ground for a moment (or touch the exit).

The previous free-scrolling layouts are kept in `backups/pre_room_redesign/`. `tests/fixtures/legacy_ridge.tscn` preserves the old Lantern Ridge layout for the movement and camera tests that rely on fixed positions.

### Proving required items are really required
A route only proves a room *can* be cleared. When a room is meant to need a pickup or a mine, add a skip check so it can never quietly become optional:

```
@skipcheck R05 R06 without=shells
@skipcheck R09 R10 without=mines dir=left
@skipcheck R10 gold without=shells dir=left
```

The test removes those items from the room, then brute-forces every combination of jump time (an edge jump, plus fixed delays when the check adds `jump=timed` for rooms that start against a wall), two shot times and three aims (backward, backward-down, down) toward the target. If any attempt lands safely in the target room (or banks the golden shell), the test fails and prints the exact inputs that worked. Run with `--fixed-fps 60` so the search runs uncapped:

`godot --headless --fixed-fps 60 --path . --script res://tests/room_routes_test.gd -- --map=lantern_ridge`

Entering a room saves progress but does not refill shells; only landing does, so crossing a room edge mid-air never grants free shots.

### Spore pods (Mossy Comet)
`scenes/actors/spore_pod.tscn` is a grapple point. Shoot it from up to 240px away (the aim must be within about 20 degrees of the pod, so place pods on clean 8-way lines from where the player stands or flies) and the player is pulled straight to it at 700 px/s with gravity off - well above shot recoil (390) - then keeps that speed past the pod like a slingshot. The pod refunds the shell, so chains of pods never run dry. A pull ends on arrival, on a head-on wall hit, after 0.6 s, or when you fire again (so you can shoot out of a pull, and a shot that hits the next pod chains into it). A spore-green tether shows the pull. Pods regrow after 1.6 s and reset when you die.

Map characters: `o` is a free-floating pod (use it wherever the player flies through the pod, so nothing blocks the slingshot); `u` `r` `l` `d` root the pod to the surface below, left, right or above it. Watch out: any pod within range on your aim line catches the shot, so a pod below you will grab a down-shot meant for height. Art: `tools/art_spore_pod.lua`.

### Phase plates and switches (Copper Cloud)
`a` is a copper plate (solid in phase 0) and `b` a teal plate (solid in phase 1). Shooting a `w` switch (180px reach, 0.80 cone) swaps the phase for the whole level. A switch does not refund the shell, and the shot still kicks you, so place switches where that kick helps: below the player for height, behind them for speed. Every room starts in phase 0, on entry and on respawn, so routes are repeatable. The builder merges each rectangle of one colour into a single plate. A plate never closes on the player: it waits as a flickering outline until they are clear, and the whole gate waits together. Hollow plates show a tinted outline so the other layout can be read ahead.

Make every swap mandatory with full-height plate walls or full-width lids (a wall cannot be shot around), and check it with `@skipcheck ... without=switches`. Beware of follow-up shots: a second shot whose aim still covers the switch flips the phase back. Diagonals clear a switch that is straight below. Art: `tools/art_phase_blocks.lua`.
### Crumbling ice and slippery ice (Velvet Glacier)
`c` is crumbling ice: it holds for 0.4 s once stood on, shakes, shatters, and regrows after 2.4 s (never while the player is inside it). Every crumble resets on death and on room entry. Landing on a crumble still refills shells, so a chain of crumbles is a chain of refills the player has to keep moving through. Use them wherever a climb is taller than a jump and two shots (about 220px), and prove they are needed with `@skipcheck ... without=crumbles`.

A run of the same character is built as one block, so a whole row of `c` shatters at once. To make a floor whose segments break one at a time, alternate `c` and `k` (both are crumbling ice): `cckkcckk` is four separate two-tile crumbles.

`i` is slippery ice: solid ground with almost no grip (accelerates at 120 px/s^2 and brakes at 40 px/s^2, and pushing against your slide brakes no harder than letting go, against 2200 and 1900 on normal ground). Momentum from a landing or a kick carries on, so on small ice ledges hop straight off on contact, or use the shotgun kick as a brake. Ice is terrain, not an item, so it has no skip check: verify it with routes. Art: `tools/art_glacier_ice.lua`.

### Wind gusts (Echo Orchard)
`}` `{` `~` are wind gusts blowing right, left and up (`scripts/wind_zone.gd`, built as one zone per rectangle). All gusts share one rhythm: 0.9 s calm (the last 0.35 s flickers as a warning), then a 1.1 s gust, restarted on room entry and on death. A side gust pushes at 1400 px/s^2 and an updraft at 1700 px/s^2 (it beats gravity), each only until the player moves 280 px/s along it. A tailwind barely helps, since shotgun kicks already move faster than that, so use wind against the player: updrafts that lift higher than shells can (about 300px per gust), headwinds you cross in the calm or kick through, and updrafts that carry you into ceiling spikes if you stay too long. Prove a room needs its wind with `@skipcheck ... without=wind`. Mechanics test: `tests/wind_test.gd`.
In a room spec, list wind rectangles first: later rectangles paint over earlier ones, and a wind drawn last wipes out the floors and ledges inside it. Every room entry restarts the rhythm in a calm, so an updraft that carries the player through a door into the next room lets them drop back out; make the landing beside the opening reachable at the top of the rise. Standing still on solid ground holds against a side gust (ground braking beats it), but ice does not, and a player who lands already moving in a gust gets carried.

### Design tools
- `tools/room_shapes.gd` turns rectangle specs into exact-width room text. Mossy Comet's specs live in `data/rooms/specs/mossy_comet.gd`; regenerate and paste the output into `data/rooms/mossy_comet.txt`.
- `tools/reach_map.gd` maps how high the player can be at every tile column of a room, with or without items, optionally after replaying a route prefix (e.g. up to a pod fling). Compare two maps to place a ledge that one strategy reaches and another can't, then lock it in with a `@skipcheck`.

### Worlds and their later levels
Each biome is a world of five levels (`data/levels/*.tres` carry `world` 0-4 and `stage` 1-5). Stage 1 is the biome's original level and introduces its mechanic; stages 2-5 use every mechanic introduced so far and get harder. A later level's map is named `<biome>_<stage>` (e.g. `lantern_ridge_3`), its scene is `scenes/levels/<map>.tscn`, and its specs live in `data/rooms/specs/<map>.gd`.
- Create it: `godot --headless --path . --script res://tools/new_level.gd -- --map=lantern_ridge_3 --title="BELLWIRE PASS" --world=0 --stage=3 --description="..."`. This copies the world's first level (backdrop, decor, music), writes the definition, and rebuilds `data/level_catalog.tres` in world/stage order.
- Write its specs and `data/rooms/<map>.txt` (header, rooms, then `; Routes`), then build and verify it like any room map.
- Measured limits worth designing around: two diagonal kicks carry about 45-48 tiles at ledge height, even under a spiked ceiling 4-5 tiles up, so long gaps alone never force a shell; force refills with distance beyond that or with height. A mine shot from directly above launches about 330 px (into the next room's air if nothing caps it), so cap rooms whose slabs could otherwise be flown over. Shells only refill one shot each.
- Pods in later levels: a pod refunds the shell its own shot costs, but kicks don't, so a chain broken by kicks needs a floating shell to keep firing. A pod slingshot carries 40-50 tiles, so cap the landing with a ceiling or let it carry into the next room's floor. Shooting a pod while touching a ceiling misses (the shot starts inside the ceiling). Chained pods off a diagonal slingshot only stay inside the aim cone for 5-7 frames; place the second pod so its bearing starts shallower than 45 degrees and sweeps through it.
- Phase plates in later levels: a switch, mine or pod closer than about 25px, and off-axis by more than a few pixels, falls outside the aim cone (the gun sits 5px below the player's centre), so shoot from a little further away. A mine launch climbs about 150px in the 11-frame shot cooldown, so a lid you must swap open mid-launch needs that much room above the mine. Rooms that drop a long way (the turnstile descent, the vault) need the level's `checkpoint_fall_distance` raised above the drop (World 3's later levels use 700).
- Skip checks run much faster one room at a time: launch `room_routes_test.gd` with `--only=<room>` for each room in parallel.

### Breakable scenery

Every scenery prop the builder places carries `scripts/breakable_decor.gd`, Hollow Knight style: a shotgun blast that would hit it (same range, aim cone and line of sight as other shot targets) or a mine going off within its blast radius smashes it into 8x8 pieces of its own sprite. The pieces fly away from the blast, bounce and settle on the ground, then fade after a few seconds. Props are purely cosmetic (no collision, no effect on movement), stay broken until the level reloads, and need no setup: rebuilding a level is enough. Test: `tests/breakable_decor_test.gd`.
