# Lantern Ridge design

Traversal is the focus. Drones and hostile projectiles are removed. Static spikes, gaps, checkpoints, and safe boost mines provide the challenge.

## Tuning

| Parameter | Value |
| --- | --- |
| Run / jump speed | 170 / 310 px/s |
| Gravity | 900 px/s²; x1.22 on descent |
| Held-jump apex gravity | x0.65 |
| Ground acceleration / braking | 2200 / 1900 px/s² |
| Air acceleration | 1050 px/s²; x1.45 when reversing |
| Neutral air drag | 180 px/s²; 65 during mine carry |
| Coyote time / jump buffer | 0.12 / 0.14 seconds |
| Shot recoil | 390 px/s; 85% perpendicular carry |
| Shot cooldown / lock | 0.18 / 0.075 seconds |
| Mine impulse / lock | +420 px/s / 0.16 seconds |
| Mine radius / recharge | 176 px / 2.5 seconds |
| Maximum boost speed | 900 px/s |

Downward carry cannot weaken an upward shot. Releasing jump only cuts an ordinary jump, never recoil. Landing immediately refills two shells. Mines never refill ammo. Inputs resolve before physics movement; normal jumps and shots can occur together. Manual arrows are the only aiming scheme.

## Feedback and architecture

Player owns locomotion and the Shotgun child; Camera2D owns cosmetic feedback. Mines are reusable non-colliding shot targets. The level owns progression and resets mines on death. Sfx is the sole autoload and owns 14 audio voices, 12 original samples, distance attenuation, and saved volume/camera preferences.

Camera effects are bounded to 3 source pixels of shake and zoom between 0.95 and 1.04. There is no rotation, hit-stop, or input delay. Sprite stretch never changes collision geometry.

## Art and route

The original Aseprite palette combines cold slate, lavender mountains, cream snow, coral clothing, and amber lamps. A shared 32-tile atlas forms 13 platforms. The player has two idle poses, four running poses, and rising/falling poses. Parallax mountain planes, spruce trees, heather, banners, lanterns, and snow add depth.

The lower route crosses ten gaps. Four mines offer momentum; one near the first checkpoint opens a high shortcut. The finish gate reports time and falls. No music or enemies are included in this traversal build.
