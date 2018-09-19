"""
   For the Sonic the Hedgehog fan-game:
   Sonic: Imperial Outbreak
   Code written by Jesse, Ryan, Sofox, Sslaxx
   with additional assistance from the Sonic Physics Guide
"""

extends KinematicBody2D

# TODO: Make this into a generic script for player character scripts to extend from.
# TODO: I.e. this script -> player character specific script.

# FIXME: This script needs re-writing to be better able to handle, among other things, collision issues.
# FIXME: As defined in Player_Movement_Plans.md - so state machine(s)(?).
# FIXME: And cycle of processing should be input -> modify movement vectors/check collision/etc -> move.
# FIXME: Taking into account potentially different playstyles/character abilities will make this trickier.
# FIXME: The SPG's numbers may be broadly fine for a Megadrive, but work poorly with Godot.
# FIXME: An easy solution may be to multiply all the numbers by 60 (explicitly, as opposed to using a var).
# FIXME: i.e. accel = 28.125 as opposed to accel = 0.46875 * special_number (as done currently).
# FIXME: Assuming of course values are all pixels/second or frames/second. Not that it's going to be that straightforward.

const UP = Vector2 (0, -1)		# Vector2s use x and y values; negatives on the y-axis are "up" in Godot.
# Special Number; Delta x 60. FIXME: This mean that fixing framerate to 60 may be optimal?
const special_number = 60

const GRAVITY = 0.21875 * special_number	# Gravity Speed

var velocity = Vector2 (0, 0)

var ground_normal = Vector2 (0, -1)

# Sonic Physics Guide Variables
var accel = 0.046875 * special_number		# Acceleration
var decel = 0.5 * special_number 			# Deceleration
var friction = 0.046875 * special_number 	# Friction
var top_speed = 6 * special_number 			# Top Speed
var air = 0.09375 * special_number 			# Air

var slope = 0.125 * special_number			# Slope

var fall = 2.5 * special_number

var ground_speed =  0.0						# Ground Speed
var horizontal_lock_timer = 0

var is_player_on_floor = false

var jumping = false
var real_movement = Vector2 (0, 0)
var was_player_on_floor = false

# Left and Right input variables.
var left = false
var right = false

func _ready ():
	return

func _input (event):
	left = (Input.is_action_pressed ("move_left") && !right)
	right = (Input.is_action_pressed ("move_right") && !left)
	return

func _physics_process (delta):
	if (horizontal_lock_timer >= 0):
		horizontal_lock_timer -= delta
#	print ($FloorDetect.is_colliding ())
#	print ($FloorDetect.get_collision_point ())
	# Determine which way the player is going. Make sure that pressing both left and right at the same time does nothing.
	if (horizontal_lock_timer > 0):	# If movement is not possible...
		left = false	# Make sure the movement variables are set to false.
		right = false	# FIXME: Does jumping need to be in this block?

	var floor_rays = [$FloorDetectCenter, $FloorDetectLeft, $FloorDetectRight]
	for ray in floor_rays:
#		# FIXME: This is pretty hacky, so need to find a better way of handling all this.
#		if ($FloorDetectRight.is_colliding () && $FloorDetectLeft.is_colliding () && !$FloorDetectCenter.is_colliding ()):
#			is_player_on_floor = $FloorDetectCenter.is_colliding ()
#			ground_normal = $FloorDetectCenter.get_collision_normal ()
#			break
		is_player_on_floor = ray.is_colliding ()
		if (is_player_on_floor):
#			print (ray.name)
			ground_normal = ray.get_collision_normal ()
#			print (ray.name, " ", ground_normal)	# FOR DEBUGGING ONLY. Print which ray is colliding.
			break

#	var hitting_floor = (is_player_on_floor == true and was_player_on_floor == false)
	var hitting_floor = (is_player_on_floor && !was_player_on_floor)
	was_player_on_floor = is_player_on_floor

	var run_speed = (ground_speed if is_player_on_floor else velocity.x)

	# Very hazy animation states; will need to put these in a MATCH state machine.
	if (jumping):
			$Sprite.play ("Jump_2")
	elif ((run_speed >= -0.01 and run_speed <= 2.8126) or run_speed == 0):
		# Bug; sometimes lands with 0, other times lands with 2.8125, exact same number as the friction.
		# FIXME: This seems an odd bug/error. Try to reproduce/recreate it? Try to identify what causes it?
		$Sprite.play ("Idle")
	elif ((run_speed >= 360) or (run_speed <= -360) and (run_speed < 799.9 or run_speed > -799.9)):
		$Sprite.play ("Run_1")
		if ((run_speed >= 800) or (run_speed <= -800)):
			$Sprite.play ("fullSpeed")
	else:
		$Sprite.play ("Walk")

	var ground_angle = (UP.angle_to (ground_normal))

	# FIXME: This piece of code seems to not be called at all!
	if ((ground_angle >= (PI/2.01) || ground_angle <= (-PI/2.01)) && ground_speed < fall):
		# Depending on angle/position the player may not be on the floor.
#		print (is_player_on_floor)
		is_player_on_floor = false
		ground_speed = 0
		horizontal_lock_timer = 0.5

	if (is_player_on_floor):	# Major condition, determines whether we're going by groundspeed or traditional
		jumping = false
		# Vector that points "forward" along the ground that Sonic stands on.
		var ground_speed_vector = ground_normal.rotated (PI/2)

		if (hitting_floor):
			# If we've landed on floor, recalculate ground_speed.
			ground_speed = velocity.dot (ground_speed_vector)
			rotation = ground_angle
#			print (ground_angle)
#			move_and_collide ((-400) * ground_normal)
			move_and_slide ((-400) * ground_normal, UP)

		ground_speed += slope * sin (ground_speed_vector.angle ())

		# Right movement
		if (right):
			$Sprite.flip_h = false
#			print ("Right.")
			if (ground_speed < 0):
				ground_speed += decel
			elif (ground_speed < top_speed):
				ground_speed += accel

		# Left Movement
		elif (left):
			$Sprite.flip_h = true
#			print ("Left.")
			if (ground_speed > 0):
				ground_speed -= decel
			elif (ground_speed > -top_speed):
				ground_speed -= accel

		# Idle
		else:
			var beforeground_speed = ground_speed
			var ground_friction = min (abs (ground_speed), friction)
			ground_speed -= (ground_friction * sign (ground_speed))
#			print (str (beforeground_speed) + " " + str (ground_speed))

		#ground_normal
		velocity = ground_speed_vector * ground_speed
		if (Input.is_action_just_pressed ("move_jump")):
			jumping = true
			sound_player.play_sound ("Jump")
			velocity += (6.5 * special_number) * ground_normal
#			print (str (ground_normal.rotated (PI/2)))
		rotation = ground_angle

	else:	#If in the air
		rotation = 0

		if (right):	# Air control
			$Sprite.flip_h = false
			if (velocity.x < top_speed):
				velocity.x += air
		elif (left):
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

		if (Input.is_action_just_released ("move_jump") && (velocity.y < -4 * special_number ) && jumping):
			velocity.y = -4 * special_number

	var beforeMove = position
	velocity = move_and_slide (velocity, UP)	# Sets motion equal to 0
	
	var afterMove = position
	real_movement = afterMove - beforeMove		# FIXME: This isn't used anywhere. Does it need to be?

	# Collision Count (WIP)
	var collision_count = get_slide_count ()
	if (collision_count > 0):
		var last_collision = get_slide_collision (collision_count - 1)
		if (last_collision.collider is preload ("res://Scripts/Badniks/Buzzing_Pest_Test.gd")):
			last_collision.collider.hit_the_pest ()
#		print ((last_collision.normal*-1).angle ())
#		print ("last_collision: ", last_collision.collider)
	return
