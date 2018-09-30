"""
   This file is part of:
   GODOT SONIC ENGINE

   Copyright (c) 2018- Stuart Moore.

   Licenced under the terms of the MIT "expat" license.

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

### The player has gotten their character killed, this is what makes that work.

extends Sprite

var game_over_yeah = null	# Used to handle the game/time over node if needed.

# Well, the player has had a death, so start the death animation playing.
func _ready ():
	$Tween.connect ("tween_completed", self, "player_has_died")
	$Tween.interpolate_property ($".", "position", position, Vector2 (position.x, position.y+290), 1.50, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.set_repeat (false)
	$Tween.start ()
	return

# The animation is now over, so return the player to normal (after resetting various values) unless they have no lives left in which
# case end the game.
func player_has_died (done, key):
	if ((game_space.minutes >= 9 && game_space.seconds > 59) && game_space.lives >= 0):
		# Over ten minutes have passed, so time over applies. Load the time over scene, show it and continue.
		game_over_yeah = global_space.add_path_to_node ("res://Scenes/UI/time_over.tscn", "/root/Level")
		game_over_yeah.get_node ("Camera2D").current = true
		game_over_yeah.position = game_space.player_character.get_node ("Camera2D").get_camera_position ()
	if (game_space.lives >= 0):
		game_space.player_character.get_node ("Camera2D").current = true			# Not game over yet, so...
	else:
		# The game is now over; all lives have been lost. Show the game over stuff.
		game_over_yeah = global_space.add_path_to_node ("res://Scenes/UI/game_over.tscn", "/root/Level")
		game_over_yeah.get_node ("Camera2D").current = true
		game_over_yeah.position = game_space.player_character.get_node ("Camera2D").get_camera_position ()
	queue_free ()	# This instance is no longer required, so delete it.
	return

# Make sure certain things happen as soon as this scene is added to the tree.
func _on_dead_player_tree_entered ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("ENTERED DEAD PLAYER")
	$"/root/Level/hud_layer".layer = -99		# Hide the HUD layer.
	$"/root/Level/Timer_Level".stop ()
	sound_player.play_sound ("Death")		# Play the death jingle.
	position = game_space.player_character.position			# Set the position of this to where the player is.
	# Make sure that the player character's camera is disabled during the animation.
	game_space.player_character.get_node ("Camera2D").current = false
	game_space.player_controlling_character = false
	return

# When the scene is being removed from the tree, reset values, restore player's position and control and so on.
func _on_dead_player_tree_exited ():
	game_space.minutes = 0
	game_space.seconds = 0
	game_space.reset_player_to_checkpoint = true
	$"/root/Level/Timer_Level".start ()
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("EXITED DEAD PLAYER")
	return
