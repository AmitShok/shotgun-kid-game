# Player scarf implementation

The prior movement-feedback pass added native CPUParticles2D bursts and a seven-point trailing scarf. This route redesign preserves them.

Primary references: [Celeste Classic hair nodes](https://github.com/NoelFB/Celeste/blob/master/Source/PICO-8/Classic.cs) and [Celeste Player hair configuration](https://github.com/NoelFB/Celeste/blob/master/Source/Player/Player.cs). Classic updates five tapering nodes by following the previous node with a downward offset. The published full-game Player file configures hair behavior with facing, motion and wind; it does not contain the complete PlayerHair class.

Our independent adaptation in scripts/player_scarf.gd uses seven world-space points, exponential following, bounded segment lengths, velocity influence and a neck anchor. Teleports reset the trail; pausing freezes it. Aseprite-authored scarf segments replace the original baked tail. The code is an adaptation of the trailing-point idea, not a copy of the unpublished full-game hair implementation.
