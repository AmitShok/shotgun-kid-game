# Prototype validation

Validated on 24 September 2026 with the installed Godot 4.7.2 Windows editor and OpenGL compatibility renderer (Intel Iris Xe).

- Project import: completed without script or resource errors.
- Gameplay integration: **26 checks, zero failures**, including a physical keyboard event through the serialized Input Map.
- Continuous traversal: **10 consecutive gaps passed**, without repositioning the player between ledges. Enemies were removed and damage disabled to isolate reachability.
- Rendered game view and pause menu: captured from the actual Godot viewport and inspected for legibility and overlap.
- Art provenance: 13 original PNG textures and matching editable Aseprite documents, authored/exported by the installed Aseprite application.
- Project Manager: registered as a favorite without replacing existing projects.

The gameplay suite covers grounded spawn, floor collision, jumping, recoil direction, two-shot exhaustion, rejected third shot, ground refill, all eight manual directions, projectile destruction, enemy damage, terrain blocking, checkpoint activation, respawn position/ammo, and completion pause.

Remaining validation: human playtesting for movement feel and combat difficulty; broader keyboard layouts and window configurations. No claim of a finished or release-ready game.

Manual-only update: 15 input regression checks passed, including injected physical Shift/J plus all four diagonal combinations, rapid second taps during cooldown, held-Shift behavior, and no delayed shot after empty-gun refill. The cooldown regression failed before the fix and passed afterward. Injected key events test software input handling; they do not measure the physical keyboard's key rollover.

Jump/fire update: eight additional checks pass. Tests cover normal jump ammo, Shift plus diagonal arrows while Space stays held, simultaneous jump/fire, immediate touchdown refill, a quick follow-up jump and shot, and the two-shot air limit. Before this update, simultaneous default aim, first-tick refill, and shooting after a quick landing/jump failed.

Diagonal-jump investigation: the existing Space mapping passed all 24 tested combinations (four diagonals, standing/A/D movement, arrows held before or pressed alongside jump). No software failure was reproduced. Added W and Ctrl alternatives and an F3 received-key readout. The expanded automated test injects all three jump keys; it cannot certify physical keyboard rollover.
