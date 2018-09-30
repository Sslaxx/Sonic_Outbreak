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
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   The HUD layer controller.
   Updates the HUD and plays animations as necessary; most of this is controlled in (and called through) game scripts.
"""

extends CanvasLayer

var rings_zero = false	# To make sure the flashing animation for no rings is only called as needed.
var t_minus_ten = false	# Ten seconds or less until the 10 minutes mark.

func _ready ():
	$"rings_symbol/rings_player".play ("safe")
	$"time_symbol/time_player".play ("safe")
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr (get_script ().resource_path, " ready.")
	game_space.update_hud ()	# Make sure the HUD is initialised from the get-go!
	return

"""
   update_hud
   Updates the HUD and makes sure it does any effects as required.
   When should this be called?
    - Automatically whenever the hud_layer scene is instantiated via _ready.
    - Whenever score, rings or lives are changed (via a setter).
    - Whenever the game starts, an act starts or the game is paused and then unpaused.
    - Any other cases that may not be described above.
"""
func update_hud ():
	var pretty_me_up = ""	# Used for prettying up/formatting text.
	## Update the HUD values as needed.
	$"lives_count".set_text (var2str (game_space.lives))
	$"rings_count".set_text (var2str (game_space.rings))
	# Put the timer together.
	pretty_me_up += var2str (game_space.minutes) + ":"
	if (game_space.seconds < 10):	# Add a relevant 0 (to keep the timer looking consistent).
		pretty_me_up += "0"
	pretty_me_up += var2str (game_space.seconds)
	$"time_count".text = pretty_me_up
	$"score_count".text = str (game_space.score)
	## Make sure that the counters are flashing if need be.
	if (game_space.rings == 0):
		if (!rings_zero):
			# Rings are currently set to zero, so start the flashing animation.
			$"rings_symbol/rings_player".play ("unsafe")
			rings_zero = true
	else:
		# Got some rings, so the rings counter doesn't need to flash.
		rings_zero = false
		$"rings_symbol/rings_player".play ("safe")
#	# Make the time counter flash when it's less than ten seconds until ten minutes.
#	# TODO: See above about TODO how things are going to be stored and accessed.
	return
