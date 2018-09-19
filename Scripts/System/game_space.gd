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

"""
   For use for game variables, constants etc. that will be accessed by other scenes/nodes/scripts throughout the game.
   Also does some (basic) game management.
"""

extends Node

const RINGS_FOR_EXTRA_LIFE = 100	# Number of rings before an extra life. Don't use this directly...
const DEFAULT_RINGS = 0				# Default number of player rings.
const DEFAULT_LIVES = 3				# Ditto lives.
const DEFAULT_SCORE = 0				# Ditto score.

## These control the player character, and if anything needs to be done to/with it.
var player_character = null		# Who is the player character? Set up by the player_<character name>.gd script in its _ready.
var player_controlling_character = true	# Is the player controlling the character? Normally true. False for death/cutscenes/etc.
var reset_player_to_checkpoint = false	# Reset the player to the last checkpoint/start position if true.

onready var Game_Timer = Timer.new ()	# A universal timer.

## Set up variables for rings/collectibles, lives and score.
# These have setters and getters in order to allow gameplay-related events (extra lives, death etc.) to occur.
var rings = DEFAULT_RINGS setget set_rings, get_rings		# Number of rings the player has.
var lives = DEFAULT_LIVES setget set_lives, get_lives		# Lives left.
var score = DEFAULT_SCORE setget set_score, get_score		# Score.

# These variables control the timer. Probably not the most efficient way to do it, but it works, so...
var seconds = 0 setget set_seconds, get_seconds
var minutes = 0
var timer_paused = false

func _ready ():
	printerr ("Game-space functionality ready.")
	return

# Reset values to default. Note the lack of "self." here - otherwise it'd invoke the setters/getters!
# This needs to be done like this because singletons don't get reset on application/scene restart.
func reset_values ():
	rings = DEFAULT_RINGS
	lives = DEFAULT_LIVES
	score = DEFAULT_SCORE
	return

# Updates the HUD as required (for rings and lives and score, etc.). Called by the setters/getters for rings/score/time/lives.
func update_hud ():
	var prettied_time = ""	# Use this for the timer.
	if (!has_node ("/root/Level/hud_layer")):	# Can't update a HUD that is not there!
		return
	$"/root/Level/hud_layer/lives_count".set_text (var2str (lives))
	$"/root/Level/hud_layer/rings_count".set_text (var2str (rings))
	# Put the timer together.
	prettied_time += var2str (minutes) + ":"
	if (seconds < 10):	# Add a relevant 0 (to keep the timer looking consistent).
		prettied_time += "0"
	prettied_time += var2str (seconds)
	$"/root/Level/hud_layer/time_count".text = prettied_time
	$"/root/Level/hud_layer/score_count".text = str (score)
	$"/root/Level/hud_layer".update_hud ()
	return

"""
   SETTERS and GETTERS.
   get_ and set_ functions to allow the HUD counters to be updated. Nothing else needs to be done; these variables are automatically
   called via the setget definition for the variable (outside of the class; inside it, remember to use self if needed!).
   These also allow for events such as extra lives and death of the player.
"""

func get_lives ():
	return (lives)

# The lives variable setter handles death.
func set_lives (value):
	if (value < lives):	# The player has died! Reset things to default values, set the player's position to the checkpoint etc.
#		timer_paused = true
#		player_character.set_linear_velocity (Vector2 (0,0))	# Stop the player moving.
#		player_character.change_anim ("Die")
#		player_character.set ("visible", false)
#		global_space.add_path_to_node ("res://Scenes/UI/dead_player.tscn", "/root/Level")
#		player_character.reset_player (false)
		timer_paused = false
	elif (value > lives):	# The player has got an extra life! Play the relevant music (if possible)!
		jingle_player.play_jingle ("res://Assets/Audio/Jingles/One_Up.ogg")
	lives = value
	update_hud ()
	return

func get_rings ():
	return (rings)

func set_rings (value):
	if (value < rings && !(lives < 0 || !player_controlling_character)):
		# Have lost rings through being hurt, as opposed to insta-kill etc.
		sound_player.play_sound ("LoseRings")				# Play the sound.
	rings = value
#	if (has_node ("/root/Level")):
#		if (lives >= 0 && rings >= $"/root/Level".rings_to_collect):	# Got enough rings to get an extra life!
#			$"/root/Level".rings_to_collect += game_space.RINGS_FOR_EXTRA_LIFE
#			self.lives += 1
	update_hud ()
	return

func get_score ():
	return (score)

func set_score (value):
	score = value
	update_hud ()
	return

func get_seconds ():
	return (seconds)

func set_seconds (value):
	if (timer_paused):	# Timer is paused, so don't increment the timer.
		return
	seconds = value
	if (seconds > 59):	# A minute has passed, so update that!
		if (minutes >= 9):	# Ten minutes have passed, in fact, so kill the player.
			timer_paused = true
			self.lives -= 1
			return
		seconds = 0
		minutes += 1
		if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
			printerr ("Minutes are now ", minutes, ".")
	update_hud ()
	return
