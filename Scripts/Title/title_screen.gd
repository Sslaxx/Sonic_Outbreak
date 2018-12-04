"""
   This file is part of
   SONIC OUTBREAK

   The title screen. It'll wait until a key is pressed (button on the keypad etc as well) then go to the main menu. It will
   alternate the backdrop between various zone backgrounds (every 5 seconds).
"""
# FIXME: Keypad and mouse button input. These are not spectacularly hard to check for thankfully.

extends Node2D

func _ready():
	return

"""
   If any key is pressed, start the game.
"""
func _unhandled_input (event):
	if (event.is_pressed ()):
		jingle_player.stop_jingle ()
		game_space.reset_values ()
		global_space.go_to_scene ("res://CDZ/CDZ_01.tscn")
	return
