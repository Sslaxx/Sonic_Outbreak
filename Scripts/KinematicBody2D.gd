### For the Sonic the Hedgehog fan-game:
# Sonic: Imperial Outbreak
# Code written by Jesse, Ryan, Sofox, Sslaxx
# with additional assistance from the Sonic Physics Guide

extends KinematicBody2D	# Needed to create our own physics.

# Script extension for "Player"

const UP = Vector2 (0, -1)		# Vectors use x and y values; negatives on the y-axis are "up" in Godot.
var spec = 60					# Special Number; Delta x 60. FIXME: This mean that keeping framerate to 60 may be optimal?
var GRAVITY = 0.21875 * spec	# Gravity Speed

var velocity = Vector2 (0, 0)

var ground_normal = Vector2 (0, -1)

# Sonic Physics Guide Variables 
var acc = 0.046875 * spec	# Acceleration
var dec = 0.5 * spec 		# Deceleration
var frc = 0.046875 * spec 	# Friction
var top = 6 * spec 			# Top Speed
var air = 0.09375 * spec 	# Air

var slp = 0.125 *spec	#slope

var fall = 2.5 * spec

var GSP =  0.0	# Ground Speed
var horizontal_lock_timer = 0

var is_on_floor = false

var jumping = false
var realMovement = Vector2 (0, 0)
var was_on_floor = false

# Left and Right input variables.
var left = false
var right = false

func _ready ():
	return

func _physics_process (delta):
	if (horizontal_lock_timer >= 0):
		horizontal_lock_timer -= delta
#	print ($FloorDetect.is_colliding ())
#	print ($FloorDetect.get_collision_point ())
	# Determine which way the player is going. Make sure that pressing both left and right at the same time does nothing.
	left = (Input.is_action_pressed ("move_left") && !right)
	right = (Input.is_action_pressed ("move_right") && !left)
	if (horizontal_lock_timer > 0):
		left = false
		right = false

	var rays = [$FloorDetect, $FloorDetectLeft, $FloorDetectRight]
	for ray in rays:
		is_on_floor = ray.is_colliding ()
		if (is_on_floor):
			ground_normal = ray.get_collision_normal ()
			break

	var hitting_floor = (is_on_floor == true and was_on_floor == false)
	was_on_floor = is_on_floor

#	print ("XSP: ", velocity.x)
#	print ("YSP: ", velocity.y)
	var run_speed = (GSP if is_on_floor else velocity.x)

	# Very hazy animation states; will need to put these in a MATCH state machine
	if (jumping):
			$Sprite.play ("Jump_2")
	elif ((run_speed >= -0.01 and run_speed <= 2.8126) or run_speed == 0):
		# Bug; sometimes lands with 0, other times lands with 2.8125, exact same number as the friction.
		$Sprite.play ("Idle")
	elif ((run_speed >= 360) or (run_speed <= -360) and (run_speed < 799.9 or run_speed > -799.9)):
		$Sprite.play("Run_1")
		if ((run_speed >= 800) or (run_speed <= -800)):
			$Sprite.play("fullSpeed")
	else:
		$Sprite.play ("Walk")

	var ground_angle = (UP.angle_to (ground_normal))

	if ((ground_angle >= (PI/2.01) or ground_angle <= (-PI/2.01)) and GSP < fall):
		is_on_floor = false
		GSP = 0
		horizontal_lock_timer = 0.5

	if (is_on_floor):	#Major condition, determines whether we're going by groundspeed or traditional
		jumping = false
		var gsp_vector = ground_normal.rotated (PI/2)	#Vector that points "forward" along the ground that Sonic stands on
		
		if (hitting_floor):	#If we've landed on floor, recalculate GSP
			GSP = velocity.dot (gsp_vector)
			rotation = ground_angle
#			print(ground_normal)
			move_and_slide ((-400)*ground_normal, UP)
			
		GSP += slp*sin (gsp_vector.angle ())

		# Right movement
		if (right):
			$Sprite.flip_h = false
#			print ("Right.")
			if (GSP < 0):
				GSP += dec
			elif (GSP < top):
				GSP += acc 

		# Left Movement
		elif (left):
			$Sprite.flip_h = true
#			print ("Left.")
			if (GSP > 0):
				GSP -= dec
			elif (GSP > -top):
				GSP -= acc

		# Idle
		else:
			var beforeGSP = GSP
			var friction = min (abs (GSP), frc)
			GSP -= friction*sign (GSP)
#			print (str (beforeGSP) + " " + str (GSP))

		#ground_normal
		velocity = gsp_vector*GSP
		if Input.is_action_just_pressed ("move_jump"):
			velocity += (6.5 * spec) * ground_normal
			jumping = true
			sound_player.play_sound ("Jump")
#			print (str (ground_normal.rotated (PI/2))) 
		rotation = ground_angle

	else:	#If in the air
		rotation = 0

		if (right):	# Air control
			$Sprite.flip_h = false
			if (velocity.x < top):
				velocity.x += air
		elif (left):
			$Sprite.flip_h = true
			if (velocity.x > -top):
				velocity.x -= air

		# Air Drag
		if (velocity.y < 0 and velocity.y > -4 * spec):
			if (abs (velocity.x) >= 0.125):
				velocity.x = velocity.x * 0.9875

		velocity.y += GRAVITY
		# Top Y Speed
		if (velocity.y > 16 * spec):
			velocity.y = 16 * spec

		if Input.is_action_just_released ("ui_up") and (velocity.y < -4 * spec ) and jumping:
			velocity.y = -4 * spec

	var beforeMove = position
	velocity = move_and_slide (velocity, UP)	# Sets motion equal to 0
	
	var afterMove = position
	realMovement = afterMove - beforeMove

	# Collision Count (WIP)
	var collision_count = get_slide_count ()
	if (collision_count > 0):
		var last_collision = get_slide_collision (collision_count - 1)
		if (last_collision.collider is preload ("res://Scripts/Badniks/Buzzing_Pest_Test.gd")):
			last_collision.collider.hit_the_pest ()
#		print ((last_collision.normal*-1).angle())
#		print ("last_collision: ", last_collision.collider)
	return
