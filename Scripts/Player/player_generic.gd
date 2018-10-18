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
	IDLE_STATE = 0,
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
	CUTSCENE_STATE = 4096,
	}

"""
enum SpeedType {
	STOPPED_SPEED = 0,
	INITIAL_SPEED = 1,
	LOW_SPEED = 2,
	HIGH_SPEED = 4,
	}
"""

var linear_velocity = Vector2 (0, GRAVITY)	# Velocity; the amount the player character moves by.
var ground_normal = UP
var movement_velocity

# Sonic Physics Guide Variables
var accel = 0.046875 * special_number		# Acceleration = 28.125
var decel = 0.5 * special_number 			# Deceleration = 30
var friction = 0.046875 * special_number 	# Friction = 2.8125
var top_speed = 6 * special_number 			# Top Speed = 360
var air = 0.09375 * special_number 			# Air = 5.625
var slope = 0.125 * special_number			# Slope = 7.5
var fall = 2.5 * special_number			# fall = 90
var ground_speed =  0.0
var horizontal_lock_timer = 0
var before_move
var is_player_on_floor = false
var real_movement = Vector2 (0, 0)
var was_player_on_floor = false
var is_player_on_edge = false
var States = IDLE_STATE
onready var center_ray = $FloorDetectCenter
onready var left_ray = $FloorDetectLeft
onready var right_ray = $FloorDetectRight
onready var floor_rays = [left_ray, right_ray, center_ray]

func _ready ():
	# Sets the player_character variables for other nodes/scenes to use.
	game_space.player_character = get_path ()	# Use get_node with this; $ will not work!
	game_space.player_character_node = get_node (game_space.player_character)	# This is a pointer to the *node*, not the path!
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Generic player functionality ready.")
	return

"""
   Checks the speed of the player character, sets animation speeds as required.
"""
func ground_speedometer (speed):
#	if ((speed >= -0.01 and speed <= 2.8126) or speed == 0):
	if (abs (speed) == 0):
		# Bug; sometimes lands with 0, other times lands with 2.8125, exact same number as the friction.
		# FIXME: This seems an odd bug/error. Try to reproduce/recreate it? Try to identify what causes it?
		States |= IDLE_STATE
	elif ((abs(speed) >= 360) and (abs(speed) < 799.9)):
		$Sprite.play ("Run_1")
	elif ((abs(speed) >= 800)):
		$Sprite.play ("fullSpeed")
	else:
		$Sprite.play ("Walk")

"""func speed_state_checker (state, PlayerSpeed):
	match state:
		IDLE_STATE:
			pass
		JUMP_STATE:
			check_state_to_play_sprite (state)
		CUTSCENE_STATE:
			printerr ("CUTSCENE_STATE")
		_:
			ground_speedometer (PlayerSpeed)
			continue"""

func edge_checker(outer_ray):
	if(center_ray.is_colliding() && !(outer_ray.is_colliding())):
		is_player_on_edge = true
	else:
		is_player_on_edge = false
func wall_checker(outer_ray,speed):
	if(speed < 800):
		if(is_on_floor() && is_on_wall()):
			if(States & MOVERIGHT_STATE) or (States & MOVELEFT_STATE):
				(States |= COLLIDE_STATE)
		else:
			(States &= ~COLLIDE_STATE)
			
func angle_checker(ray):
	if (is_player_on_floor && abs (linear_velocity.x) >= 0.05):
#			printerr (ray.name)
			ground_normal = ray.get_collision_normal ()
#			printerr (ray.name, " ", ground_normal)	# FOR DEBUGGING ONLY. Print which ray is colliding.,,,,,,,,,,,,,,,,,,
func check_state_to_play_sprite (State):
	match State:
		IDLE_STATE:
			$Sprite.play ("Idle")
			continue
		JUMP_STATE:
			$Sprite.play ("Jump_2")
		MOVERIGHT_STATE:
			$Sprite.flip_h = false
			
		MOVELEFT_STATE:
			$Sprite.flip_h = true
			continue
		COLLIDE_STATE:
			print ("COLLIDE_STATE")
		CUTSCENE_STATE:
			printerr ("CUTSCENE_STATE")

func _input (event):
	if (!(States & CUTSCENE_STATE)):
		if (Input.is_action_pressed ("move_left")):
			States |= MOVELEFT_STATE
		if (Input.is_action_pressed ("move_right")):
			States |= MOVERIGHT_STATE
		if (Input.is_action_just_released ("move_left")):
			States &= ~MOVELEFT_STATE
		if (Input.is_action_just_released ("move_right")):
			States &= ~MOVERIGHT_STATE
		if (OS.is_debug_build ()):
			if (Input.is_action_just_pressed ("DEBUG_kill_player")):
				print ("AAAA")
				game_space.lives -= 1
	return

func _physics_process (delta):
	check_state_to_play_sprite(States)
	before_move = position
	move_and_slide(linear_velocity, UP)
	is_player_on_floor = is_on_floor()
	for ray in floor_rays:
		match ray:
			center_ray:
				angle_checker(ray)
			_:
				edge_checker(ray)
				wall_checker(ray, linear_velocity.x)
				angle_checker(center_ray)
	
	var hitting_floor = (is_player_on_floor && !was_player_on_floor)
	was_player_on_floor = is_player_on_floor

	#var run_speed = (ground_speed if is_player_on_floor else velocity.x)

	var ground_angle = (UP.angle_to (ground_normal))
	
	if (is_player_on_floor):	# Major condition, determines whether we're going by groundspeed or traditional
		# Vector that points "forward" along the ground that Sonic stands on.
		ground_speedometer(ground_speed)
		var ground_speed_vector = ground_normal.rotated (PI/2)
		if (hitting_floor):
			States &= ~JUMP_STATE
			# If we've landed on floor, recalculate ground_speed.
			ground_speed = linear_velocity.dot (ground_speed_vector)
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
		linear_velocity = ground_speed_vector * ground_speed
		if (Input.is_action_just_pressed ("move_jump")):
			States |= JUMP_STATE
			sound_player.play_sound ("Jump")
			linear_velocity += (6.5 * special_number) * ground_normal
#			printerr (str (ground_normal.rotated (PI/2)))
			$Sprite.play ("Jump_2")
		rotation = ground_angle
	else:
		#If in the air
		rotation = 0
		if (States & MOVERIGHT_STATE):	# Air control
			if (linear_velocity.x < top_speed):
				linear_velocity.x += air
		elif (States & MOVELEFT_STATE):
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

		if (Input.is_action_just_released ("move_jump") && (linear_velocity.y < -4 * special_number ) && (States & JUMP_STATE)):
			linear_velocity.y = -4 * special_number
			
			
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
