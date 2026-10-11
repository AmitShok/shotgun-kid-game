# Campaign route redesign — 11 October 2026

## Design intent and research

The original campaign repeated a vertical mine / shell / recoil staircase. The new campaign uses authored routes in both horizontal directions, drops, low passages, isolated climbs, and a final combined flight.

Primary sources read:

- [Maddy Thorson: The Making of Celeste Chapter 9](https://exok.com/posts/2019-11-25-chapter-9-design/). The developer describes remixing familiar objects, introducing new mechanics in easier stages, and changing pace within a finale. Our application: teach isolated recoil and refill encounters before combining mine momentum with a midair refill; alternate demanding flights with simpler drops. These are our adaptations, not copied Celeste room layouts.
- [GDC workshop developer discussion](https://www.gamedeveloper.com/design/gdc-2017-level-design-workshop). Thorson describes revisiting individual levels, areas, and the complete game together. Our application: give each biome a route identity and revise the difficulty sequence, rather than repeating an identical section more times.
- [Celeste & Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/index.html). Thorson explains movement allowances that favor the player. Existing jump buffering, coyote time, and apex assistance remain intact; challenge comes from geometry. Safe platforms save checkpoints, reducing retry cost.

## Route identities

| Level | Sections | Route and pacing | Landing width |
| --- | ---: | --- | ---: |
| Mossy Comet | 10 | Broad diagonal canopy leaps, a lower fern landing, comet slings and shell relays; one crown ascent turns onto a leftward upper route. | 192 px |
| Copper Cloud | 12 | Sideways arcade passages, rooftop steps, balconies and a bell-tower climb; a short leftward detour returns east over the earlier city on a shallow overpass. | 176 px |
| Velvet Glacier | 14 | Ice galleries and descending pockets interrupt long cave crossings; two chimneys connect three alternating tiers with tighter shelves. | 160 px |
| Echo Orchard | 16 | Narrow flower and root landings, long arcs and direction reversals; the final harvest flight combines a mine, diagonal recoil, shell refill and upward correction without landing. | 144 px |

Difficulty increases through encounter count, smaller catches, edge hazards and combinations. Distance alone does not determine difficulty: the harder shell gaps can be shorter because their landings are narrower and higher. Pure climbs comprise only one or two sections per level.

## Encounter language

- **Diagonal:** jump, aim down and opposite travel, fire near the apex; preserve useful lateral speed.
- **Mine:** jump forward beyond the floating mine, shoot diagonally back/down, use the second shot to extend the arc and brake before landing.
- **Shell:** two diagonal shots intersect a refill. A downward third shot restores height while retaining lateral velocity.
- **Low passage:** early diagonal recoil then a horizontal shot under a solid tile roof. The roof covers the middle of the gap, leaving both platforms open for entries and following lifts. Spikes on its top discourage bypassing the low passage.
- **Drop:** an easier lower landing; a horizontal shot extends reach, with a second shot available for recovery.
- **Lift:** shoot down onto a mine, use the remaining shot for height, then steer onto the other tier.
- **Harvest flight:** mine plus two diagonal shots, collect the shell, then shoot down and control the final landing. This high-speed refill has a 22 px catch radius within its visible glow; ordinary shells retain 12 px.

## Clean challenge pass

Tutorial presentation has been removed from all five levels: no bottom controls/hint panel, route labels, arrows, or checkpoint text. Checkpoints still save, chime, and change flag color. The shell HUD remains optional. Pause and completion retain essential actions/statistics; the old hint toggles have been removed. Legacy save fields are ignored by presentation, so an old save cannot restore hints.

New physical constraints sharpen each biome:
- Mossy Comet: a thorn-capped fragment interrupts the final mine flight.
- Copper Cloud: spiked copper obstacles interrupt both long mine crossings.
- Velvet Glacier: hanging ice and downward spikes constrain height through four mine/refill flights.
- Echo Orchard: two uninterrupted mine-plus-refill flights, with thorn obstacles beneath the trajectory; the earlier combination spans 1,152 px and the final one 1,280 px.

The intended flight corridors remain visible. Difficulty comes from altitude control, maintaining speed and catching a refill, with safe checkpoint landings between encounters. No movement constants were changed. The previous revision is in backups/pre_clean_challenge_pass/.

## Camera, recovery and editing

Long mine/shell encounters use a smooth, fixed encounter view showing launch and destination. This view is selected on the ground; airborne aiming cannot redirect it. Normal terrain-dependent landing framing remains in place elsewhere, including level 1. Respawn clears encounter framing.

Every safe platform has a checkpoint with a trigger spanning the landing. Falls reset relative to the checkpoint rather than requiring a fall through the entire map. Lower routes can sometimes catch a missed upper jump; the saved checkpoint remains the recovery point.

Scenes remain native, editable TileMapLayers using their existing biome TileSets and Aseprite art. Island undersides taper by biome: comet fragments, copper piers, ice facets and roots. All walking surfaces and roofs use TileSet physics, not ground collision boxes.

`tools/design_campaign.gd` is a one-shot authoring tool, not a runtime generator. **Running it replaces all four level scenes and overwrites hand edits.** Edit the scenes directly in Godot for normal level building. If changing paths, also update/remove the root `traversal_route` metadata: its start/launch/target points drive long-gap framing and the route test. Actors and collision continue to work without that metadata.

`backups/pre_route_redesign/` contains the previous upward-only scenes and generator. `backups/pre_campaign_design/` retains the earlier scenes from before campaign design. No player settings or real save file were reset.

## Verification and limits

Godot 4.7.2:

- `tests/campaign_route_test.gd`: 52 continuous physical encounters, four reachable exits; no between-section teleports or modified movement stats. The bot supplies movement/jump input and invokes the real shotgun firing logic in the eight-direction scheme.
- Early, usual and late apex firing variants (`--shot-threshold=-80`, `-50`, `0`) are checked to avoid designing exclusively around one exact shot frame.
- Same test with `--without-mines`, `--without-shells`, and `--without-relay-shell`: the corresponding planned routes fail as expected. These checks are not an exhaustive proof against every possible speedrunning shortcut.
- `tests/route_camera_test.gd`: both player and destination remain inside the settled encounter view for all 18 long crossings.
- Existing terrain/art, progression and landing-camera regression checks.

These checks establish reachability and basic readability, not that every player will find the difficulty curve ideal. Human playtesting is the next balancing input. Log files beginning `challenge_` record the clean challenge pass. The earlier `route_` logs cover the initial multidirectional redesign; `campaign_` logs cover the replaced upward-only layouts.
