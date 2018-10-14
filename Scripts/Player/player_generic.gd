"""
   For the Sonic the Hedgehog fan-game:
   Sonic: Imperial Outbreak
   Code written by Jesse, Ryan, Sofox, Sslaxx
   with additional assistance from the Sonic Physics Guide
"""

# All player character scripts must inherit from this script!
extends KinematicBody2D

# FIXME: The state machine is implemented and running, but not yet in the way that'd be optimal.
# FIXME: Some of that is due to the way the existing code works (or doesn't work, or works-but-doesn't).
# FIXME: Also, make sure to (try to) keep things as simple as possible.

const UP = Vector2 (0, -1)		# Vector2s use x and y values; negatives on the y-axis are "up" in Godot.
# Special Number. FIXME: This mean that fixing framerate to 60 may be optimal?
const special_number = 60

const GRAVITY = (13.125 / 60) * special_number	# Gravity Speed = 13.125

enum PlayerState {
	IDLE_STATE = 0,				# Player is not moving, jumping etc.
	MOVELEFT_STATE = 1,
	MOVERIGHT_STATE = 2,
	JUMP_STATE = 4,
	CROUCH_STATE = 8,
	SPIN_STATE = 16,
	COLLIDE_STATE = 32,
	SPECIAL1_STATE = 64,
	SPECIAL2_STATE = 128,
	SPECIAL3_STATE = 256,
	SPECIAL4_STATE = 512,
	CHARSPECIFIC1_STATE = 1024,
	CHARSPECIFIC2_STATE = 2048,
	CUTSCENE_STATE = 4096,		# Cutscene (be that the start or end of an act, or anything else).
}

"""
enum SpeedType {
	STOPPED_SPEED = 0,
	INITIAL_SPEED = 1,
	LOW_SPEED = 2,
	HIGH_SPEED = 4,
}
"""

var velocity = Vector2 (0, 0)	# Velocity; the amount the player character moves by.
var ground_normal = UP

# Sonic Physics Guide Variables
var accel = 0.046875 * special_number		# Acceleration = 28.125
var decel = 0.5 * special_number 			# Deceleration = 30
var friction = 0.046875 * special_number 	# Friction = 2.8125
var top_speed = 6 * special_number 			# Top Speed = 360
var air = 0.09375 * special_number 			# Air = 5.625
var slope = 0.125 * special_number			# Slope = 7.5
var fall = 2.5 * special_number				# fall = 90
var ground_speed =  0.0
var horizontal_lock_timer = 0
var is_player_on_floor = false
var real_movement = Vector2 (0, 0)
var was_player_on_floor = false
var States = IDLE_STATE
var run_speed = 0.0

func _ready ():
	# Sets the player_character variables for other nodes/scenes to use.
	game_space.player_character = get_path ()	# Use get_node with this; $ will not work!
	game_space.player_character_node = get_node (game_space.player_character)	# This is a pointer to the *node*, not the path!
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Generic player functionality ready.")
	return

"""
   Checks the speed of the player character, sets animation as required.
"""
func ground_speedometer ():
	# Bug; sometimes lands with 0, other times lands with 2.8125, exact same number as the friction.
	# FIXME: This seems an odd bug/error. Try to reproduce/recreate it? Try to identify what causes it?
	if (abs (run_speed) > 0 && abs (run_speed) < 360):
		$Sprite.play ("Walk")
	elif (abs (run_speed) >= 360 && abs (run_speed) < 800):
		$Sprite.play ("Run_1")
	elif (abs (run_speed) >= 800):
		$Sprite.play ("fullSpeed")
	else:	# This means the player should not be moving, so if the movement states are not set, then set state to idle.
		if (!((States & MOVELEFT_STATE) || (States & MOVERIGHT_STATE) || (States & JUMP_STATE) || (States & SPIN_STATE) || (States & CROUCH_STATE))):
			States = (IDLE_STATE if (abs (run_speed) < 0.01) else States)
	return

func speed_state_checker ():
	match States:
		IDLE_STATE:
			return
		JUMP_STATE:
			check_state_to_play_sprite ()
		CUTSCENE_STATE:
			printerr ("CUTSCENE_STATE")
		_:
			ground_speedometer ()
			continue
	return

func check_state_to_play_sprite ():
	match States:
		JUMP_STATE:
			$Sprite.play ("Jump_2")
#			continue
		MOVERIGHT_STATE:
			$Sprite.flip_h = false
#			continue
		MOVELEFT_STATE:
			$Sprite.flip_h = true
#			continue
		COLLIDE_STATE:
			print ("COLLIDE_STATE")
		CUTSCENE_STATE:
			printerr ("CUTSCENE_STATE")
		IDLE_STATE:
			$Sprite.play ("Idle")
#			continue
	return

func _input (event):
	if (States & CUTSCENE_STATE):	# Ensure player control is only possible when not in a cutscene.
		return
	if (Input.is_action_pressed ("move_left")):
		States |= MOVELEFT_STATE
	if (Input.is_action_pressed ("move_right")):
		States |= MOVERIGHT_STATE
	if (Input.is_action_just_released ("move_left")):
		States &= ~MOVELEFT_STATE
	if (Input.is_action_just_released ("move_right")):
		States &= ~MOVERIGHT_STATE
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Commands for testing things out.
		if (Input.is_action_just_pressed ("DEBUG_kill_player")):
			print ("AAAA")
			game_space.lives -= 1
	return

func _physics_process (delta):
	check_state_to_play_sprite ()
	if (States & CUTSCENE_STATE):
		return	# Cutscene stuff should be handled by the level's own code wherever possible.
	var floor_rays = [$FloorDetectLeft, $FloorDetectCenter, $FloorDetectRight]
	for ray in floor_rays:
		# FIXME: This is pretty hacky, so need to find a better way of handling all this.
		# FIXME: These rays should be used for "edge of platform" animations and rotations.
		# FIXME: is_on_floor should be handling actual floor collisions.
		is_player_on_floor = ray.is_colliding ()
		if (is_player_on_floor && abs (velocity.x) >= 0.05):
#			printerr (ray.name)
			ground_normal = ray.get_collision_normal ()
#			printerr (ray.name, " ", ground_normal)	# FOR DEBUGGING ONLY. Print which ray is colliding.

	var hitting_floor = (is_player_on_floor && !was_player_on_floor)
	was_player_on_floor = is_player_on_floor

	run_speed = (ground_speed if is_player_on_floor else velocity.x)

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
			States &= ~JUMP_STATE
			# If we've landed on floor, recalculate ground_speed.
			ground_speed = velocity.dot (ground_speed_vector)
			rotation = ground_angle
#			printerr (ground_angle)
		ground_speed += slope * sin (ground_speed_vector.angle ())
		# Right movement
		if (States & MOVERIGHT_STATE):
#			printerr ("Right.")
			if (ground_speed < 0):
				ground_speed += decel
			elif (ground_speed < top_speed):
				ground_speed += accel
		# Left Movement
		elif (States & MOVELEFT_STATE):
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
		velocity = ground_speed_vector * ground_speed
		if (Input.is_action_just_pressed ("move_jump")):
			States |= JUMP_STATE
			sound_player.play_sound ("Jump")
			velocity += (6.5 * special_number) * ground_normal
#			printerr (str (ground_normal.rotated (PI/2)))
			$Sprite.play ("Jump_2")
		rotation = ground_angle
	else:
		#If in the air
		rotation = 0
		if (States & MOVERIGHT_STATE):	# Air control
			if (velocity.x < top_speed):
				velocity.x += air
		elif (States & MOVELEFT_STATE):
			if (velocity.x > -top_speed):
				velocity.x -= air

		# Air Drag
		if (velocity.y < 0 && velocity.y > -4 * special_number):
			if (abs (velocity.x) >= 0.125):
				velocity.x = velocity.x * 0.9875

		velocity.y += GRAVITY
		# Top Y Speed
		if (velocity.y > 16 * special_number):
			velocity.y = 16 * special_number

		if (Input.is_action_just_released ("move_jump") && (velocity.y < -4 * special_number ) && (States & JUMP_STATE)):
			velocity.y = -4 * special_number

	var beforeMove = position
	velocity = move_and_slide (velocity, UP)	# Sets motion equal to 0

	var afterMove = position
	real_movement = afterMove - beforeMove		# FIXME: This isn't used anywhere. Does it need to be?
#	print (real_movement)

	# Collision Count (WIP)
	var collision_count = get_slide_count ()
	if (collision_count > 0):
		var last_collision = get_slide_collision (collision_count - 1)
		if (last_collision.collider is preload ("res://Scripts/Badniks/generic_badnik.gd")):
			last_collision.collider.hit_the_pest ()
#		printerr ((last_collision.normal*-1).angle ())
#		printerr ("last_collision: ", last_collision.collider)
	return

func reset_player (is_new_game = false):
	return
