"""
   For the Sonic the Hedgehog fan-game:
   Sonic: Imperial Outbreak
   Code written by Jesse, Ryan, Sofox, Sslaxx
   with additional assistance from the Sonic Physics Guide
"""

# All player character scripts must inherit from this script!
extends KinematicBody2D

# FIXME: This script needs re-writing to be better able to handle, among other things, collision issues.
# FIXME: As defined in Player_Movement_Plans.md - so state machine(s)(?). (IMPORTANT READ)
# FIXME: And cycle of processing should be input -> modify movement vectors/check collision/etc -> move.
# FIXME: Taking into account potentially different playstyles/character abilities will make this trickier.
const UP = Vector2 (0, -1)		# Vector2s use x and y values; negatives on the y-axis are "up" in Godot.
# Special Number; Delta x 60. FIXME: This mean that fixing framerate to 60 may be optimal?
const special_number = 60

const GRAVITY = 0.21875 * special_number	# Gravity Speed = 13.125

enum  PlayerState {
	IDLE_STATE = 1 << 0,
	MOVELEFT_STATE = 1 << 1,
	MOVERIGHT_STATE = 1 << 2,
	JUMP_STATE = 1 << 3,
	CROUCH_STATE = 1 << 4,
	SPIN_STATE = 1 << 5,
	COLLIDE_STATE = 1 << 6,
	SPECIAL1_STATE = 1 << 7,
	SPECIAL2_STATE = 1 << 8,
	SPECIAL3_STATE = 1 << 9,
	SPECIAL4_STATE = 1 << 10,
	CHARSPECIFIC1_STATE = 1 << 11
	CHARSPECIFIC2_STATE = 1 << 12
	CUTSCENE_STATE = 1 << 13
	}

"""enum SpeedType {
	INITIAL_SPEED = 1 << 0 
	LOW_SPEED = 1 << 1
	HIGH_SPEED = 1 << 2
	}"""




var velocity = Vector2 (0, 0)

var ground_normal = Vector2 (0, -1)

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
var is_player_on_floor = false
var jumping = false
var real_movement = Vector2 (0, 0)
var was_player_on_floor = false



var States = 0



func _ready ():
	# Sets the player_character variables for other nodes/scenes to use.
	game_space.player_character = get_path ()	# Use get_node with this; $ will not work!
	game_space.player_character_node = get_node (game_space.player_character)	# This is a pointer to the *node*, not the path!
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Generic player functionality ready.")
	return


func GroundSpeedometer(speed):
	if ((speed >= -0.01 and speed <= 2.8126) or speed == 0):
		# Bug; sometimes lands with 0, other times lands with 2.8125, exact same number as the friction.
		# FIXME: This seems an odd bug/error. Try to reproduce/recreate it? Try to identify what causes it?
		$Sprite.play ("Idle")
	elif ((speed >= 360) or (speed <= -360) and (speed < 799.9 or speed > -799.9)):
		$Sprite.play ("Run_1")
	elif ((speed >= 800) or (speed <= -800)):
		$Sprite.play ("fullSpeed")
	else:
		$Sprite.play ("Walk")

func CheckStateToPlaySprite(State):
	match State:
		CUTSCENE_STATE:
			print("CUTSCENE_STATE")
		IDLE_STATE:
			continue
		JUMP_STATE:
			$Sprite.play("Jump_2")
		MOVERIGHT_STATE: 
			$Sprite.flip_h = false
			continue
		MOVELEFT_STATE:
			$Sprite.flip_h = true
			continue
		COLLIDE_STATE:
			print("COLLIDE_STATE")






func _input (event):
	if (Input.is_action_pressed ("move_left")):
		(States &= ~IDLE_STATE)
		(States |= MOVELEFT_STATE)
		print(States)
	if (Input.is_action_pressed ("move_right")):
		(States &= ~IDLE_STATE)
		(States |= MOVERIGHT_STATE)
		print(States)
	if (Input.is_action_just_released("move_left")):
		(States &= ~MOVELEFT_STATE)
		(States |= IDLE_STATE)
		print(States)
	if (Input.is_action_just_released("move_right")):
		(States &= ~MOVERIGHT_STATE)
		(States |= IDLE_STATE)
		print(States)
	if (OS.is_debug_build ()):
		if (Input.is_action_just_pressed ("DEBUG_kill_player")):
			print ("AAAA")
			game_space.lives -= 1
	return

func _physics_process (delta):
	CheckStateToPlaySprite(States)
	if (horizontal_lock_timer >= 0):
		horizontal_lock_timer -= delta
	#	printerr ($FloorDetect.is_colliding ())
	#	printerr ($FloorDetect.get_collision_point ())
	# IMPORTANT Determine which way the player is going. Make sure that pressing both left and right at the same time does nothing.
	if (horizontal_lock_timer > 0):	# If movement is not possible...
			pass# Make sure the movement variables are set to false.
			# FIXME: Does jumping need to be in this block?
	var floor_rays = [$FloorDetectCenter, $FloorDetectLeft, $FloorDetectRight]
	for ray in floor_rays:
#		# IMPORTANT FIXME: This is pretty hacky, so need to find a better way of handling all this.
		is_player_on_floor = ray.is_colliding ()
		if (is_player_on_floor && abs (velocity.x) >= 0.05):
#			printerr (ray.name)
			ground_normal = ray.get_collision_normal ()
#			printerr (ray.name, " ", ground_normal)	# FOR DEBUGGING ONLY. Print which ray is colliding.
			break
	
	var hitting_floor = (is_player_on_floor && !was_player_on_floor)
	was_player_on_floor = is_player_on_floor
	
	var run_speed = (ground_speed if is_player_on_floor else velocity.x)
	
	
	var ground_angle = (UP.angle_to (ground_normal))
	
	# FIXME: This piece of code seems to not be called at all!
	if ((ground_angle >= (PI/2.01) || ground_angle <= (-PI/2.01)) && ground_speed < fall):
		is_player_on_floor = false
		ground_speed = 0  
		horizontal_lock_timer = 0.5

	if (is_player_on_floor):	# Major condition, determines whether we're going by groundspeed or traditional
		# Vector that points "forward" along the ground that Sonic stands on.
		var ground_speed_vector = ground_normal.rotated (PI/2)
		if !(States & JUMP_STATE):
			GroundSpeedometer(run_speed)
		if (hitting_floor):
			(States &= ~JUMP_STATE)
			(States |= IDLE_STATE)
			CheckStateToPlaySprite(States)
			# If we've landed on floor, recalculate ground_speed.
			ground_speed = velocity.dot (ground_speed_vector)
			rotation = ground_angle
#			printerr (ground_angle)
#			move_and_collide ((-400) * ground_normal * delta)
			move_and_slide ((-400) * ground_normal, UP)

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
			(States &= ~IDLE_STATE)
			(States |= JUMP_STATE)
			sound_player.play_sound ("Jump")
			velocity += (6.5 * special_number) * ground_normal
#			printerr (str (ground_normal.rotated (PI/2)))
			CheckStateToPlaySprite(States)
			
		rotation = ground_angle

	else:	#If in the air
		if (States & JUMP_STATE):
			print((States & JUMP_STATE))
			CheckStateToPlaySprite(States)
		rotation = 0
		if (States & MOVERIGHT_STATE):	# Air control
			$Sprite.flip_h = false
			if (velocity.x < top_speed):
				velocity.x += air
		elif (States & MOVELEFT_STATE):
			$Sprite.flip_h = true
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