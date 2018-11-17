"""
   For the Sonic the Hedgehog fan-game:
   Sonic Outbreak
   Code written by Jesse, Most, Ryan, Sofox, Sslaxx
   Using the Sonic Physics Guide.
"""

# The player_generic.gd script contains all the basic functionality; scripts like this one are for character-specific abilities.
# REMEMBER: player_generic.gd EXTENDS FROM KinematicBody2D!
# player_<name>.gd -> player_generic.gd -> KinematicBody2D.
extends "res://Scripts/Player/player_generic.gd"

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Sonic - ", game_space.player_character_node, " - is ready.")
	return

#func _process (delta):
#	return

#func _physics_process (delta):
#	return
