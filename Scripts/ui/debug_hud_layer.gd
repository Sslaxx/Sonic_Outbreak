### The debug HUD.
# Shows frame rate, X and Y position, if on the ground or in the air, etc.

extends CanvasLayer

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		print ("DEBUGGING HUD ENABLED.")
	else:	# Make sure this HUD doesn't do anything (or show anything) if not running in debug mode.
		print ("NO DEBUGGING HUD.")	# TODO: REMOVE THIS LINE ON RELEASE!
		$"FPS".text = ""
		$"Position".text = ""
		$"Velocity".text = ""
		$"Is_On_Floor".text = ""
		$"Was_On_Floor".text = ""
		set_process (false)
	return

# NOTE: The debug HUD gets updated every frame. So it's not a good idea to have this enabled in any public-facing releases.
func _process (delta):
	# Display FPS in the label
	$"FPS".text = "FPS: " + str (Engine.get_frames_per_second ())
	# Print the position, etc. - these ones depend on the player node existing.
	if (has_node ("../Player")):
		# FIXME: Really hackish, not-entirely-accurate way to do this! Look at String.format and format to 2 decimal places?
		$"Position".text = "POS: " + str (int ($"../Player".position.x)) + ", " + str (int ($"../Player".position.y))
		$"Velocity".text = "VEL: " + str (int ($"../Player".velocity.x)) + ", " + str (int ($"../Player".velocity.y))
		if ($"../Player".is_on_floor):	# Is the player on the floor?
			$"Is_On_Floor".text = "ON FLOOR"
		else:
			$"Is_On_Floor".text = "NOT ON FLOOR"
		if ($"../Player".was_on_floor):	# Was the player on the floor?
			$"Was_On_Floor".text = "WAS ON FLOOR"	# FIXME: Is this working correctly? If it is there's a bug somewhere.
		else:
			$"Was_On_Floor".text = "WASN'T ON FLOOR"	# FIXME: Also, is this useful?
	return
