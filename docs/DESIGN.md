# First playable design

## Identity

A small red-capped kid with an oversized shotgun traverses a moonlit rooftop training yard. Coral, mint, navy, and warm cream create a readable palette. The reference games inform precise movement, vertical commitment, and lively pixel-art silhouettes. No reference-game assets are copied.

## Movement contract

- 150 px/s walking; 285 px/s jump; gravity 850 px/s².
- 390 px/s recoil in the opposite normalized aim direction. Diagonals have the same total speed as cardinal shots.
- 0.10-second coyote time; 0.12-second jump buffer.
- 0.16-second recoil lock preserves the initial boost before air steering resumes.
- 0.18-second shot cooldown; immediate refill on confirmed landing. Already-grounded shots refill after the 0.16-second recoil lock.
- Ammo is a resource owned by the shotgun component. The player only requests refill after confirmed post-move floor contact.
- Enemy projectiles use a segment ray against player/world every physics tick as well as an Area2D contact check.
- Drone deaths and blocked projectiles produce short sprite-based particle bursts.

## Scene ownership

Player owns locomotion and a reusable Shotgun child. Shotgun owns ammo, firing, cone checks, and muzzle flash; it emits a direction signal to the player for recoil. The level owns progression and attempt statistics. Checkpoints update the player's respawn location. HUD reads state and owns pause/menu input. Keyboard actions are serialized in project.godot and editable through Project Settings > Input Map.

Collision layers: 1 World, 2 Player, 3 Enemy. Player movement collides with world; enemies/projectiles/hazards detect the player. Weapon damage uses target groups plus a world occlusion ray. Every static ledge collision is serialized explicitly in the level scene.

## Training route

1. Safe starting roof: jump and fire down, then chain two shots while climbing.
2. First checkpoint: learn a drone's warning tint and destroy its orange projectile.
3. Second checkpoint: combine diagonal recoil, gaps, spikes, and descending landings.
4. Exit: finish screen reports elapsed time and falls.

## Scope

This is a prototype foundation, not a finished commercial game. It contains one short level, one enemy type, simplified four-pose player animation, no audio, and fixed default keys. Final art direction, accessibility/remapping, difficulty modes, sound, and campaign design remain open. The next useful feedback is whether shots should preserve more pre-shot momentum.

## Manual-only input update

Arrow keys are the sole aiming controls; mode switching and the settings autoload were removed. Discrete fire input is captured as an event and buffered for up to the shot cooldown plus 0.05 seconds. A queued press consumes at most one shell; empty-gun presses are discarded, and pending input is cleared on respawn, pause, or focus loss. Cooldown advances in physics ticks.

## Normal-jump firing update

Jump and fire presses now both enter through input events, then resolve in the same physics step. Normal jumps consume no shells. Neutral airborne aim is chosen after the jump starts, so pressing jump and shoot together aims down rather than using the previous grounded direction. Confirmed landing immediately refills both shells before the next jump, including quick repeated jumps.
