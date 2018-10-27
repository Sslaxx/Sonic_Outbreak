"""
   For the Sonic the Hedgehog fan-game:
   Sonic Outbreak
   Code written by Jesse, Most, Ryan, Sofox, Sslaxx
   Using the Sonic Physics Guide.
"""

# All player character scripts must inherit from this script!
extends KinematicBody2D

# FIXME: The state machine is implemented and running, but not yet in the way that'd be optimal.
# FIXME: Some of that is due to the way the existing code works (or doesn't work, or works-but-doesn't).
# FIXME: Also, make sure to (try to) keep things as simple as possible.

const UP = Vector2 (0, -1)		# Vector2s use x and y values; negatives on the y-axis are "up" in Godot.
# Special Number. FIXME: This mean that fixing framerate to 60 may be optimal?
const special_number = 60

const GRAVITY = (13.125 / special_number) * special_number	# Done to make it easier to adjust gravity values.

enum MovementState {
	# These are universal, generic states for all player characters.
	STATE_IDLE = 0,				# Player is not moving, jumping etc. This is the absence of state, really, not a state per se.
	STATE_MOVE_LEFT = 1,
	STATE_MOVE_RIGHT = 2,
	STATE_JUMPING = 4,
	STATE_CROUCHING = 8,
	STATE_SPINNING = 16,
	STATE_CUTSCENE = 32,		# Cutscene (be that the start or end of an act, or anything else).
	# Anything above this point is for character-specific or any other special-case states.
}

"""
enum SpeedType {
	SPEED_STOPPED = 0,
	SPEED_LOW = 1,
	SPEED_MEDIUM = 2,
	SPEED_HIGH = 4,
}
"""

var linear_velocity = Vector2 (0, GRAVITY)	# linear_velocity; the amount the player character moves by.
var ground_normal = UP
#var moving_in = "nil"
#var movement_direction = Vector2 (0, 0)

# Values taken from the Sonic Physics Guide.
var accel = 0.046875 * special_number		# Acceleration = 28.125
var decel = 0.5 * special_number 			# Deceleration = 30
var friction = 0.046875 * special_number 	# Friction = 2.8125
var top_speed = 6 * special_number 			# Top Speed = 360
var air = 0.09375 * special_number 			# Air = 5.625
var slope = 0.125 * special_number			# Slope = 7.5
var fall = 2.5 * special_number				# fall = 90
var ground_speed =  0.0
var run_speed = 0.0
var horizontal_lock_timer = 0
var is_player_on_floor = false
#var real_movement = Vector2 (0, 0)
var was_player_on_floor = false
var player_state = MovementState.STATE_IDLE
onready var floor_rays = [$FloorDetectLeft, $FloorDetectCenter, $FloorDetectRight]
onready var collision_count = 0

func _ready ():
	# Sets the player_character variables for other nodes/scenes to use.
	game_space.player_character = get_path ()	# Use get_node with this; $ will not work!
	game_space.player_character_node = get_node (game_space.player_character)	# This is a pointer to the *node*, not the path!
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Generic player functionality ready.")
	return

func _input (event):
	if (player_state & MovementState.STATE_CUTSCENE):	# Ensure player control is only possible when not in a cutscene.
		return
	if (Input.is_action_pressed ("move_left")):
		player_state |= MovementState.STATE_MOVE_LEFT
	if (Input.is_action_pressed ("move_right")):
		player_state |= MovementState.STATE_MOVE_RIGHT
	if (Input.is_action_just_released ("move_left")):
		player_state &= ~MovementState.STATE_MOVE_LEFT
	if (Input.is_action_just_released ("move_right")):
		player_state &= ~MovementState.STATE_MOVE_RIGHT
#	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Commands for testing things out.
#		if (Input.is_action_just_pressed ("DEBUG_kill_player")):
#			print ("AAAA")
#			game_space.lives -= 1
#	moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))
#	player_state |= (MovementState.STATE_MOVE_LEFT if moving_in == "left" else (MovementState.STATE_MOVE_RIGHT if moving_in == "right" else player_state))
#	print (moving_in)
	return

func _physics_process (delta):
	check_state_to_play_sprite ()
	if (player_state & MovementState.STATE_CUTSCENE):	# If doing a cutscene, stop any and all movement.
		run_speed = 0.0
		linear_velocity = Vector2 (0, 0)
		return	# Cutscene stuff should be handled by the level's own code wherever possible.
	for ray in floor_rays:
		# FIXME: This is pretty hacky, so need to find a better way of handling all this.
		# FIXME: These rays should be used for "edge of platform" animations and rotations.
		# FIXME: is_on_floor should be handling actual floor collisions.
		is_player_on_floor = ray.is_colliding ()
		if (is_player_on_floor && abs (linear_velocity.x) >= 0.05):
#			printerr (ray.name)
			ground_normal = ray.get_collision_normal ()
#			printerr (ray.name, " ", ground_normal)	# FOR DEBUGGING ONLY. Print which ray is colliding.

	var hitting_floor = (is_player_on_floor && !was_player_on_floor)
	was_player_on_floor = is_player_on_floor

	run_speed = (ground_speed if is_player_on_floor else linear_velocity.x)

	var ground_angle = (UP.angle_to (ground_normal))

#	# FIXME: This piece of code seems to not be called at all!
#	if (abs (ground_angle) >= (PI/2.01) && ground_speed < fall):
#		ground_speed = 0
#		horizontal_lock_timer = 0.5

	if (is_player_on_floor):	# Major condition, determines whether we're going by groundspeed or traditional
		# Vector that points "forward" along the ground that Sonic stands on.
		speed_state_checker ()
		var ground_speed_vector = ground_normal.rotated (PI/2)
		if (hitting_floor):
			player_state &= ~MovementState.STATE_JUMPING
			# If we've landed on floor, recalculate ground_speed.
			ground_speed = linear_velocity.dot (ground_speed_vector)
			rotation = ground_angle
#			printerr (ground_angle)
		ground_speed += slope * sin (ground_speed_vector.angle ())
		# Right movement
		if (player_state & MovementState.STATE_MOVE_RIGHT):
#			printerr ("Right.")
			if (ground_speed < 0):
				ground_speed += decel
			elif (ground_speed < top_speed):
				ground_speed += accel
		# Left Movement
		elif (player_state & MovementState.STATE_MOVE_LEFT):
#			printerr ("Left.")
			if (ground_speed > 0):
				ground_speed -= decel
			elif (ground_speed > -top_speed):
				ground_speed -= accel
		# Idle
		else:
			var beforeground_speed = ground_speed
			var ground_friction = min (abs (ground_speed), friction)
			ground_speed -= (ground_friction * sign (ground_speed))
#			printerr (str (beforeground_speed) + " " + str (ground_speed))
		#ground_normal
		linear_velocity = ground_speed_vector * ground_speed
		if (Input.is_action_just_pressed ("move_jump")):
			player_state |= MovementState.STATE_JUMPING
			sound_player.play_sound ("Jump")
			linear_velocity += (6.5 * special_number) * ground_normal
#			printerr (str (ground_normal.rotated (PI/2)))
			$Sprite.play ("Jump_2")
		rotation = ground_angle
	else:
		# When in the air...
		rotation = 0
		if (player_state & MovementState.STATE_MOVE_RIGHT):	# Air control
			if (linear_velocity.x < top_speed):
				linear_velocity.x += air
		elif (player_state & MovementState.STATE_MOVE_LEFT):
			if (linear_velocity.x > -top_speed):
				linear_velocity.x -= air

		# Air Drag
		if (linear_velocity.y < 0 && linear_velocity.y > -4 * special_number):
			if (abs (linear_velocity.x) >= 0.125):
				linear_velocity.x = linear_velocity.x * 0.9875

		linear_velocity.y += GRAVITY
		# Top Y Speed
		if (linear_velocity.y > 16 * special_number):
			linear_velocity.y = 16 * special_number

		if (Input.is_action_just_released ("move_jump") && (linear_velocity.y < -4 * special_number ) && (player_state & MovementState.STATE_JUMPING)):
			linear_velocity.y = -4 * special_number

#	var beforeMove = position
	linear_velocity = move_and_slide (linear_velocity, UP)	# Move the player.

#	var afterMove = position
#	real_movement = afterMove - beforeMove		# FIXME: This isn't used anywhere. Does it need to be?
#	print (real_movement)

	# Collision Count (WIP)
	collision_count = get_slide_count ()
	if (collision_count > 0):
		var last_collision = get_slide_collision (collision_count - 1)
		if (last_collision.collider is preload ("res://Scripts/Badniks/generic_badnik.gd")):
			last_collision.collider.hit_the_pest ()
#		printerr ((last_collision.normal*-1).angle ())
#		printerr ("last_collision: ", last_collision.collider)
	return

"""
   Resets the player values, some of them dependent on if you're starting a new game or not.
"""
func reset_player (is_new_game = false):
	return

"""
   STATE MACHINE FUNCTIONS.
"""

"""
   Checks the speed of the player character, sets animation as required.
"""
func ground_speedometer ():
	# This goes from slow-to-fast.
	if (abs (run_speed) > 0 && abs (run_speed) < 360):
		$Sprite.play ("Walk")
	elif (abs (run_speed) >= 360 && abs (run_speed) < 800):
		$Sprite.play ("Run_1")
	elif (abs (run_speed) >= 800):
		$Sprite.play ("fullSpeed")
	else:	# This means the player should not be moving, so if the movement states are not set, then set state to idle.
		if (!((player_state & MovementState.STATE_MOVE_LEFT) || (player_state & MovementState.STATE_MOVE_RIGHT) || (player_state & MovementState.STATE_JUMPING) || (player_state & MovementState.STATE_SPINNING) || (player_state & MovementState.STATE_CROUCHING))):
			player_state = (MovementState.STATE_IDLE if (abs (run_speed) < 0.01) else player_state)
	return

func speed_state_checker ():
	match player_state:
		MovementState.STATE_IDLE:
			if (abs (run_speed) < 0.01 && is_player_on_floor):
				$Sprite.play ("Idle")
			return
		MovementState.STATE_JUMPING:
			check_state_to_play_sprite ()
			continue
		MovementState.STATE_CUTSCENE:
			printerr ("MovementState.STATE_CUTSCENE")
			return
		_:
			ground_speedometer ()
	return

func check_state_to_play_sprite ():
	match player_state:
		MovementState.STATE_JUMPING:
			$Sprite.play ("Jump_2")
			continue
		MovementState.STATE_MOVE_RIGHT:
			$Sprite.flip_h = false
			continue
		MovementState.STATE_MOVE_LEFT:
			$Sprite.flip_h = true
			continue
		MovementState.STATE_CUTSCENE:
			printerr ("MovementState.STATE_CUTSCENE")
		MovementState.STATE_IDLE:
			# Player is (nominally) idle, but check for movement (and being on the floor) to avoid gliding.
			if (abs (run_speed) < 0.01 && is_player_on_floor):	# On the floor, and not moving, so set animation to idle.
				$Sprite.play ("Idle")
			elif (is_player_on_floor):	# Still moving, so make sure a relevant animation is playing instead.
				ground_speedometer ()
				$Sprite.flip_h = (false if sign (run_speed) == 1 else true)	# Make sure it's in the right direction if possible.
			else:
				ground_speedometer ()
			return
	return
