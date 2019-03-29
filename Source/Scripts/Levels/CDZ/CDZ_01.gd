extends "res://Scripts/Levels/level_generic.gd"

func _ready () -> void:
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		global_space.add_path_to_node ("res://Scenes/Player/player_sonic.tscn", "/root/Level")
		print (game_space.player_character)
	music_player.play_music ("res://Assets/Audio/Music/cdz_idea_0_1_281.ogg")
	return
