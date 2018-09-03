# MOVEMENT - how to handle it.

Movement needs to handle several different states:
- No movement
- Left/right movement
- Jumping
- Looking up/down
- Moving up/down
- Spindash
- Dropdash
- Looping through loops
- Acceleration and deceleration (independent of movement)

In addition, any movement code needs to take into account the following:
- Collision *walls, ceilings and floors, ramps and slopes*
- Collision *badniks, spikes, monitor boxes*
- Collision *other enviromentals, e.g. zone gimmicks or moving floors/ceilings/walls*
- Cutscenes (no movement or anything else possible during them, this includes end-of-act tally, act/zone transitions etc.)
- Physics (aim for feel of "classic" Sonic games; accuracy is desirable but NOT essential)

**Keeping it simple** is key. It's not going to be particularly simple anyway, especially if dealing with potential multiple player characters, but simplicity (of design, of code) wherever possible is desirable.

## POSSIBLE 1: state machine control?

### Overview

If movement is to be a state machine, using a bitmask to determine state(s):
- 0 == No movement
- 1 == Move left
- 2 == Move right
- 4 == Jump (up)
- 8 == Jump (down)
- 16 == Spindash
- 32 == Dropdash
- 64 == Collision *walls, ceilings and floors, ramps and slopes*
- 128 == Collision *badniks, spikes, monitor boxes*
- 256 == Collision *other enviromentals, e.g. zone gimmicks or moving floors/ceilings/walls*
- 512 == Cutscene/no player control

Velocity and speed should be separate. Velocity (the directional speed the player travels at) is determined by Speed. The direction of the speed is controlled by movement. -1 is left/up (x/y), 0 is none, 1 is down/right. Holding down left or right, or jump, should increase speed in the appropriate direction (to the maximum); releasing/not holding them will decrease speed (to 0). Friction etc. is applied to this speed to determine velocity, and it is this velocity which controls movement.

This way there is (*probably*) no need to worry about calculating or needing to take into account speed or velocity as negatives - that is determined entirely by movement.

So: maybe three Vector2s - Movement (x/y values from -1 to 1), Speed (whatever the current speeds of the player are - independent x/y?) and Velocity (the actual current movement of the player). One variable holding the state - determined by the bitmasks.

### What complicates this?

Complexity is added if different characters are playable. Tails, for example, would need to take into account time in air (if flying) and flight speed, but this *_may_* be (relatively) simple; Knuckles would need additional wall/ceiling/floor detection when wall-climbing and gliding and separate states for these.

There may well be corner cases/situations I'm not seeing with this idea either.
