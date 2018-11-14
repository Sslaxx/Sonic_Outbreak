"""
   For the Sonic the Hedgehog fan-game:
   Sonic Outbreak
   Code written by Jesse, Most, Ryan, Sofox, Sslaxx
   Using the Sonic Physics Guide.
"""

# REMEMBER: level_<name>_<act>.gd -> level_generic.gd -> Node2D.
extends "res://Scripts/Levels/level_generic.gd"

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr (get_script ().resource_path, " ready.")
	music_player.play_music ("res://Audio/Music/Crimson_District_Act_2_loop0.28.24.ogg")
	game_space.get_node ("level_timer").start ()	# Make sure the timer starts when the level does.
	return

#func _process (delta):
#	return

#func _physics_process (delta):
#	return
