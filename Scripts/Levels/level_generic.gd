"""
   For the Sonic the Hedgehog fan-game:
   Sonic: Imperial Outbreak
   Code written by Jesse, Ryan, Sofox, Sslaxx
   with additional assistance from the Sonic Physics Guide
"""

"""
   This script is a generic script for handling levels. It's inherited by the scripts that actually handle levels.
   This script's functions should be empty/undefined - it's up to the level script proper to handle things.
   This is just a template/base script for inheriting from.

   REMEMBER: level_<name>_<act>.gd -> level_generic.gd -> Node2D.
"""

extends Node2D

func _ready ():
	if (OS.is_debug_build ()):
		print ("Level functionality is ready.")
	if (has_node ("Player") && has_node ("Start_Position")):	# Make sure the player starts at the start position!
		if ($"Player".position != $"Start_Position".position):
			$"Player".position = $"Start_Position".position
	return

func _process (delta):
	return

func _physics_process (delta):
	return