# PLAYER MOVEMENT - how to handle it.

### Overview

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
- Physics (aim for feel of "classic" Sonic games; accuracy is desirable but using the exact numbers from the Sonic Physics Guide would likely be less than ideal)

### Problems

The current code *mostly* does the job, but it's not handling collisions with some slope angles, or properly in enclosed spaces. [That has caused this issue.](https://github.com/BlitzerSIO/grass-cheetah/issues/2) Trying to fix that issue may require a different approach than to write (what could be potentially endless) exceptions in the code handling it and/or change collision shapes and detection raycasts, never mind dealing with some of the staples of Sonic levels such as loops.

**Keeping it simple** is key. It's not going to be particularly simple anyway, especially if dealing with potential multiple player characters, but simplicity (of design, of code) wherever possible is desirable. Also, remember that *simple is not the same as easy*.

## POSSIBLE 1: state machine control?

### Overview

If movement is to be a "state machine", using a bitmask to determine state(s), could do it along these lines:
- 0 == No movement
- 1 == Move left
- 2 == Move right
- 4 == Jump (up)
- 8 == Jump (down)
- 16 == Spindash/squat
- 32 == Dropdash
- 64 == Collision *walls, ceilings and floors, ramps and slopes*
- 128 == Collision *badniks, spikes, monitor boxes*
- 256 == Collision *other enviromentals, e.g. zone gimmicks or moving floors/ceilings/walls*
- 512 == Cutscene/no player control

Velocity and speed should be separate. Velocity (the directional speed the player travels at) is determined by Speed. The direction of the speed is controlled by movement. -1 is left/up (x, y), 0 is none, 1 is down/right. Holding down left or right, or jump, should increase speed in the appropriate direction (up to the maximum); releasing/not holding them will decrease speed (to 0). Friction etc. is applied to this speed to determine velocity, and it is this velocity which controls movement.

Left and right should should *always* be mutually exclusive movement states. Movement and collision states could be separate if this would make it easier to handle.

If so, perhaps like these?

**Movement/actions**

- 0 No movement.
- 1 Move left
- 2 Move right
- 4 Jump (upwards)
- 8 Jump (downwards)
- 16 Spindash/squat
- 32 Cutscene/no player control

Some actions could be combinations of states and/or player input (e.g., dropdash could be Spindash/squat and jump (downwards)).

**Collision**

- 0 No collision
- 1 Colliding with *walls, ceilings, floors*
- 2 *badniks*
- 4 *spikes*
- 8 *monitor boxes*
- 16 *other environmentals, e.g. zone gimmicks or moving floors/ceilings/walls*

Having movement be separate states means that if the player suddenly starts to move in the other direction state and movement can be used together to control deceleration/turning, with the movement state being changed to whichever direction the player is moving in when deceleration has finished. While there's movement (speed is > 0) the movement direction **must not be changed**; movement state should be considered to determine which direction the player *will* move in, but not necessarily which direction the player *is currently moving* in.

So: maybe three Vector2s - Movement (x, y values from -1 to 1), Speed (whatever the current speeds of the player are - independent x, y?) and Velocity (the actual current movement of the player). Variable(s) holding the state(s) - determined by the bitmasks.

### What complicates this?

Complexity is added if different characters are playable. Tails, for example, would need to take into account time in air (if flying) and flight speed, but this *__may__* be (relatively) simple; Knuckles would need additional wall/ceiling/floor detection when wall-climbing and gliding and separate states for these.

There may well be corner cases/situations I'm not seeing with this idea either.

### What would make this simpler?

Making this as simple as possible is a good idea. But the problem is balancing it with what it may need to do as detailed above.

Maybe look at an existing FSM plugin, and see if they'd either be a good fit, or if they'd give pointers on how to implement my own solution.
