## STATE_IDLE (0)

Not really a state, per se. This is an absence of state or player input. Player character is not necessarily on the ground so any checks using this state need to take this into account.

## STATE_MOVE_LEFT (1) / STATE_MOVE_RIGHT (2)

These states indicate the direction the player is going to move in, not necessarily the direction they're currently moving in. These two states are mutually exclusive.

Movement uses these:
- A **state** (which direction the player *is going to move in*) `enum MovementState` `player_state`;
- A **movement value** (which direction the player *is holding down*) `moving_in`;
- A **movement direction vector** (which direction the player *is currently moving in*) `movement_direction`

General order of execution for calculating movement (at the moment not taking `STATE_CROUCHING` or `STATE_SPINNING` into account) should be:

1: Movement value holds a direction if the relevant movement key is pressed, or nil if none are pressed.

2: Relevant state is set for which direction (if it isn't already set to the opposite value that is), and the movement direction vector's x is set to an appropriate value (-1, 0, +1).

3: So long as the movement value holds a direction, increase acceleration (direction handled by the movement vector) if the player is on a ground surface and value and vector correspond.

4: Decelerate if the player is on a ground surface, and the movement value:
	is neither left nor right;
	OR if it is either left or right and the movement vector is different from the movement state.

5: If stopped, and the movement state is different from the movement direction vector, change the vector to reflect the movement state and accelerate. *Unless* the movement value is nil, in which case set movement state to `STATE_IDLE` instead.

Once all of these checks are done the actual movement is performed. *After* movement the animation is changed (if need be) based upon the state, movement value and direction and if on a surface or not.

## STATE_JUMPING (4)

## STATE_CROUCHING (8)

## STATE_SPINNING (16)

## STATE_CUTSCENE (32)

No player control is available during a cutscene; if the player character is to move etc. it should be handled by the relevant scene's script (be that a level or something else).
