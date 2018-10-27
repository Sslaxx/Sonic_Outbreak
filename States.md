## STATE_IDLE (0)

Not really a state, per se. This is an absence of state or player input. Player character is not necessarily on the ground so any checks using this state need to take this into account.

## STATE_MOVE_LEFT (1) / STATE_MOVE_RIGHT (2)

These states indicate the direction the player is going to move in, not necessarily the direction they're currently moving in. These two states are mutually exclusive.

- The *state* (which direction the player is going to move in);
- A *movement value* (which direction the player is holding down);
- A *movement direction vector* (which direction the player is currently moving in)

General order of execution should be:

1: A value holds a direction if the relevant movement key is pressed (movement value).

2: Relevant state is set for which direction (if it isn't already set to the opposite value that is), and the movement direction vector's x is set to appropriate value (-1, 0, +1).

3: So long as the movement value holds a direction, increase acceleration (direction handled by the movement vector) if the player is on a ground surface.

4: Decelerate if the player is on a ground surface, and the movement value:
	is neither left nor right;
	OR if it is either left or right and the move vector is different from the movement state.

5: If stopped on a surface, and the movement state is different from the movement direction vector, change the vector to reflect the movement state and accelerate. _Unless_ the movement value is nil, in which case set movement state to `STATE_IDLE` instead.

## STATE_JUMPING (4)

## STATE_CROUCHING (8)

## STATE_SPINNING (16)

## STATE_CUTSCENE (32)
