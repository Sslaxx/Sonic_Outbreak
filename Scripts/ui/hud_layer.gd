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
		printerr ("HUD set up.")
	game_space.update_hud ()	# Make sure the HUD is initialised from the get-go!
	return

"""
   update_hud
   Updates the HUD text and makes sure it does any effects as required.
   When should this be called?
    - Automatically whenever the hud_layer scene is instantiated via _ready.
    - Whenever score, rings or lives are changed (via a setter).
    - Whenever the game starts, an act starts or the game is paused and then unpaused.
    - Any other cases that may not be described above.
"""
func update_hud ():
	var pretty_me_up = ""	# Used for prettying up/formatting text.
	## Update the HUD values as needed.
	# TODO: How are rings, score etc. going to be stored in the project? This needs deciding!
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
