# PLAYER MOVEMENT - how to handle it.

## Introduction

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

The current code *mostly* does the job, but it's not handling collisions with some slope angles, or properly in enclosed spaces. [That has caused this issue.](https://github.com/BlitzerSIO/grass-cheetah/issues/2)

Some of that issue (dealing with collision/jumping at the bottom of ramps) appears to have been mostly fixed by moving the floor collision rays. That still leaves the issues at the top of the ramps.

**Keeping it simple** is key. It's not going to be particularly simple anyway, especially if dealing with potential multiple player characters, but simplicity (of design, of code) wherever possible is desirable. *Simple is not the same as easy*.

## POSSIBLE 1: state machine control?

### Overview

Velocity and speed should be separate. Velocity (the amount of directional speed the player travels at) is determined by Speed. The direction of the speed is controlled by movement. -1 is left/up (x, y), 0 is none, 1 is down/right.

Generic movement state machine values:

```
0 - STATE_IDLE
1 - STATE_MOVE_LEFT
2 - STATE_MOVE_RIGHT
4 - STATE_JUMPING
8 - STATE_CROUCHING
16 - STATE_SPINNING
32 - STATE_CUTSCENE
```

Anything above this is character-specific, with names like, e.g. `STATE_KNUCKLES_GLIDING`. Exact implementation details may vary.

Movement direction is handled by:

1: `move_left` or `move_right` - boolean variables set to be true if the relevant movement key is pressed.

2: relevant state is set for which direction. Movement direction vector's x is set to appropriate value.

3: so long as `move_left/right` are true, increase acceleration (dirction handled by movement vector).

4: if both `move_left/right` are false for any reason, decelerate. However, if one move is true and the other false, and the move is different from the representative movement state, decelerate.

5: if stopped, and the movement state is different from the movement direction vector, change the vector to reflect the movement state and accelerate. Unless `move_left/right` are *both* false *and* the player is on a floor surface, in which case set movement state to `STATE_IDLE` instead.

**OR**, instead of having two boolean variables, one variable called something like `moving_in` functioning in a similar way, controlled by something like:

`moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))`

Speed is positive only - direction is handled by the movement direction vector (i.e., it has values from -1 to 1). This *should* eliminate the need for abs checks; the only time the direction vector needs to be used should be `move_and_slide`.

### What complicates this?

Complexity is added if different characters are playable. Tails, for example, would need to take into account time in air (if flying) and flight speed, but this *__may__* be (relatively) simple; Knuckles would need additional wall/ceiling/floor detection when wall-climbing and gliding and separate states for these.

There may well be corner cases/situations I'm not seeing with this idea either.

### What would make this simpler?

Making this as simple as possible is a good idea. But the problem is balancing it with what it may need to do as detailed above.

Maybe look at an existing FSM plugin, and see if they'd either be a good fit, or if they'd give pointers on how to implement my own solution.
