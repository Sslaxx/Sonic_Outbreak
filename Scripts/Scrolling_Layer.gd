### Makes a ParallaxLayer scroll on its own. It can move x and/or y-axis independently.
# To use:
# 1 - Attach this script to a ParallaxLayer node/scene.
# 2 - Use the "Movement Factor" property in the inspector to set the speed/direction required.

extends ParallaxLayer

export var movement_factor = Vector2 (0, 0)	# Have movement be able to be changed in the object inspector.

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Give a bit of info about what is moving how.
		print (name, " is moving at ", movement_factor, ".")
	return

func _process (delta):
	motion_offset += (movement_factor * delta)	# Move the background, in the directions and speed required.
	return
