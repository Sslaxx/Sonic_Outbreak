"""
   This file is part of:
   GODOT SONIC ENGINE

   Copyright (c) 2018- Stuart Moore.

   Licenced under the terms of the MIT "expat" license.

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   This is the generic player code. All player characters extend from this script. It handles all the generica that's common
   between them, primarily movement.
"""

extends KinematicBody2D

"""
   Movement variables - those for moving the player, how much to move the player by, how they affect the player moving.
   Remember that all of these are defined using pixels per second as measurement.
"""

## MOVING THE PLAYER.

# Controlling the current movement state of the player character.
enum MovementState {
	STATE_IDLE = 0,	# Player is not moving.
	STATE_MOVE_LEFT = 1,
	STATE_MOVE_RIGHT = 2,
	STATE_JUMPING = 4,
	STATE_CROUCHING = 8,
	STATE_SPINNING = 16,
	STATE_CUTSCENE = 32,
}

var player_movement_state = MovementState.STATE_IDLE	# The current moving state the player character is in.
var moving_in = "nil"		# Which direction the player is holding down, i.e. the direction the player is (going) to move in.
var movement_direction = 0	# Which direction the player is currently moving in. -1 = left/up, 1 = right/down.
var player_speed = 0.0		# The speed at which the player is moving at.

var velocity = Vector2 (0, 0)	# The velocity (amount the player is moving in a direction).

## HOW MUCH TO MOVE THE PLAYER.

# The "gravity" that affects the player, in terms of both speed and direction.
# Normally, adjust the project settings (under Physics/2D) to alter these.
onready var player_gravity = ProjectSettings.get_setting ("physics/2d/default_gravity")

# Acceleration, deceleration and speed limits. These can be adjusted in the player scene directly.
export var acceleration_rate = 4	# Standard rate of acceleration.
export var decel_rate_moving = 6	# Decelerating rate when moving in the other direction.
export var decel_rate = 4			# Deceleration rate (not moving).
export var max_player_speed = 60	# Default maximum speed is 60 pixels per second.

## AFFECTING THE PLAYER MOVING.

var floor_normal = Vector2 (0, -1)	# Vector to use for floor detection.

onready var player_gravity_vector = ProjectSettings.get_setting ("physics/2d/default_gravity_vector")	# Gravity's direction.

var floor_snap = Vector2 (0, 0)		# Adjusting the "snap" to the floor. (0, 0) for the air, (0, 32) otherwise.

"""
   Variables that control animation - like when to play walk/jog/run animations.
"""

# Limits for changing between walk/jog/run animations - MUST BE SET IN THE CHARACTER SCENE.
export var walk_limit = 0
export var jog_limit = 0
export var run_limit = 0

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Ensure the debug HUD is added to the scene.
		printerr ("Generic player functionality ready.")
	game_space.player_character = $"."	# Make sure the game knows which character to deal with!
	change_anim ("idle")				# Ensure some kind of animation is playing when instanced.
	return

func _input (event):
	# Find out which direction the player is moving in.
	moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))
	if (!(player_movement_state & MovementState.STATE_JUMPING) && is_on_floor () && Input.is_action_pressed ("move_jump")):
		# The player is jumping (pressed the jump button).
		player_movement_state |= MovementState.STATE_JUMPING
		floor_snap = Vector2 (0, 0)
		velocity.y -= 210
		change_anim ("jump")
		sound_player.play_sound ("Jump")
#		if (!player_movement_state & MovementState.STATE_JUMPING):
#			jump_held = true
#			player_movement_state |= MovementState.STATE_JUMPING
#			velocity.y -= jump_adding
	# Unless there's a cutscene playing, in which case negate any and all movement.
	if (player_movement_state == MovementState.STATE_CUTSCENE):
		moving_in = "nil"
#		jump_held = false
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Debug keys and what they do.
		if (Input.is_action_pressed ("DEBUG_gainrings")):	# Gain items!
			printerr ("DEBUG: gain items pressed.")
			game_space.collectibles += 10
		if (Input.is_action_pressed ("DEBUG_loserings")):	# Lose items!
			printerr ("DEBUG: lose items pressed.")
			game_space.collectibles = 0
		if (Input.is_action_pressed ("DEBUG_cutscene")):	# Switch into or out of the cutscene state.
			printerr ("DEBUG: cutscene key pressed.")
			if (player_movement_state != MovementState.STATE_CUTSCENE):
				printerr ("DEBUG: entered cutscene state.")
				player_movement_state = MovementState.STATE_CUTSCENE
			else:
				printerr ("DEBUG: left cutscene state.")
				player_movement_state = MovementState.STATE_IDLE
	return

func _physics_process (delta):
	velocity = move_and_slide_with_snap (velocity, floor_snap, floor_normal)	# Move the player character.
	# Do state machine checks here.
	movement_state_machine (delta)	# For movement.
	movement_state_machine_speed (delta)
	if (is_on_floor ()):
		movement_state_machine_ground (delta)	# And being on the ground.
	else:
		movement_state_machine_air (delta)		# And being in the air.
	velocity.x = (player_speed * movement_direction)	# Work out velocity from speed * direction.
	if (is_on_floor ()):								# Make sure gravity applies.
		velocity.y = 0
		floor_snap = Vector2 (0, 32)
	else:
		velocity.y += (player_gravity * delta)
		floor_snap = Vector2 (0, 0)
	return

"""
   change_anim
   change_anim (anim_to_change_to):

   Changes the animation playing to anim_to_change_to, if it isn't already playing.
   Returns true if the animation has been played (changed to), otherwise false.
"""
func change_anim (anim_to_change_to):
	if (!has_node ("AnimatedSprite")):						# Can't play animations without something to play with!
		printerr ("ERROR: Trying to play an animation when ", self, " has no AnimatedSprite node!")
		return (false)
	if ($AnimatedSprite.animation != anim_to_change_to):	# Animation's not already playing?
		$AnimatedSprite.play (anim_to_change_to)			# Then change the animation to the one requested.
		return (true)
	return (false)											# The animation's already playing.

### ACCELERATION/DECELERATION/SPEED HELPER FUNCTIONS.

"""
   get_acceleration_mult

   Work out how fast acceleration should be. Acceleration can be affected by many factors.
   Note: this emits a *multiplier* to use to modify acceleration, and NOT acceleration itself.
   The default multiplier will be (naturally) 1.0.

   IMPORTANT: Player movement in a cutscene has to be handled directly by any scene(s) running the cutscene.
"""
func get_acceleration_mult ():
	var acceleration_mult = 1.0	# Every factor gets added to/taken away from this value.
	if (moving_in == "nil"):	# Not moving, so there's no acceleration. KEEP THIS LAST.
		acceleration_mult = 0.0	# This MUST override any other calculations to acceleration rate.
	return (acceleration_mult)

"""
   get_deceleration_mult

   Works the same way as get_acceleration_mult does.

   IMPORTANT: Player movement in a cutscene has to be handled directly by any scene(s) running the cutscene.
"""
func get_deceleration_mult ():
	var deceleration_mult = 1.0	# Every factor gets added to/taken away from this value.
	if (player_movement_state == MovementState.STATE_CUTSCENE):	# In a cutscene, so the multiplier is 4. KEEP THIS LAST.
		deceleration_mult = 4.0	# This MUST override any other calculations to deceleration rate.
	return (deceleration_mult)

"""
   get_max_player_speed_mult

   Works out (the multiplier for) maximum player speed.
"""
func get_max_player_speed_mult ():
	var max_speed_mult = 1.0	# Every factor gets added to/taken away from this value.
	return (max_speed_mult)

"""
   speed_limiter

   Makes sure the player cannot go any faster than the maximum speed (or slower than 0).
"""
func speed_limiter ():
	if (player_speed < 0):	# Can't travel at negative speeds!
		player_speed = 0.0
	if (player_speed > (max_player_speed * get_max_player_speed_mult ())):	# Moving faster than maximum? Reduce speed.
		player_speed -=  player_speed - (max_player_speed * get_max_player_speed_mult ())
	return

### STATE MACHINE FUNCTIONS.

"""
   movement_state_machine

   The basic movement state logic goes in here. Sets movement direction based on movement state.
"""
func movement_state_machine (delta):
	match (moving_in):		# Set the movement state and direction as required.
		"left":
			player_movement_state |= MovementState.STATE_MOVE_LEFT
			player_movement_state &= ~MovementState.STATE_MOVE_RIGHT
		"right":
			player_movement_state |= MovementState.STATE_MOVE_RIGHT
			player_movement_state &= ~MovementState.STATE_MOVE_LEFT
	if (player_movement_state & MovementState.STATE_MOVE_LEFT):	# All the left-moving logic goes in here.
		if (moving_in == "left"):			# Player is moving left.
			movement_direction = (-1 if player_speed < 0.01 else movement_direction)
	if (player_movement_state & MovementState.STATE_MOVE_RIGHT):	# All the right-moving logic goes in here.
		if (moving_in == "right"):			# Player is moving right.
			movement_direction = (1 if player_speed < 0.01 else movement_direction)
	# Set direction for animations to play as appropriate.
	$AnimatedSprite.flip_h = (true if movement_direction == -1 else (false if movement_direction == 1 else $AnimatedSprite.flip_h))
	return

"""
   movement_state_machine_speed

   Limits the speed of the player depending on what's going on.
"""
func movement_state_machine_speed (delta):
	if ((player_movement_state & MovementState.STATE_MOVE_LEFT) && movement_direction == 1):
		# Wanting to move left but currently moving right, so decelerate.
		player_speed -= (decel_rate_moving * get_deceleration_mult ())
	elif ((player_movement_state & MovementState.STATE_MOVE_RIGHT) && movement_direction == -1):
		# Wanting to move right but currently moving left, so decelerate.
		player_speed -= (decel_rate_moving * get_deceleration_mult ())
	elif (moving_in == "nil" && movement_direction != 0):	# Still moving, but no movement input has been given.
		player_speed -= (decel_rate * get_deceleration_mult ())	# So slow down.
	else:
		player_speed += (acceleration_rate * get_acceleration_mult ())	# If the player is moving, accelerate.
	speed_limiter ()	# Ensure the player's speed is limited appropriately.
	return

"""
   movement_state_machine_ground

   Sets movement direction according to player input, and does that based upon the current movement state. Also changes
   animations. Called when the player character is on the ground (is_on_floor is true).
"""
func movement_state_machine_ground (delta):
	if (player_movement_state & MovementState.STATE_JUMPING):	# Finished jumping? Turn off the jump state.
		player_movement_state &= ~MovementState.STATE_JUMPING
	# Change the currently playing animation based on the player's current speed...
	if (player_speed > 0):
		if (player_speed < walk_limit):	# ...walking...
			change_anim ("walk")
		if (player_speed >= walk_limit && player_speed < jog_limit):	# ...jogging...
			change_anim ("jog")
		if (player_speed >= jog_limit):	# ...running...
			change_anim ("run")
	else:	# ...or lack of it.
		if (!player_movement_state == MovementState.STATE_CUTSCENE):
			# If a cutscene is running, changing animation is handled differently.
			player_movement_state = MovementState.STATE_IDLE
		change_anim ("idle")
		movement_direction = 0
	return

"""
   movement_state_machine_air

   Does state machine checks while the player is in the air, either jumping or falling.
"""
func movement_state_machine_air (delta):
	# Change the currently playing animation based on the player's current speed...
	if (player_speed > 0 && !(player_movement_state & MovementState.STATE_JUMPING)):
		# Not jumping, so animations can change.
		if (player_speed < walk_limit):
			change_anim ("walk")
		if (player_speed >= walk_limit && player_speed < jog_limit):
			change_anim ("jog")
		if (player_speed >= jog_limit):
			change_anim ("run")
	return
