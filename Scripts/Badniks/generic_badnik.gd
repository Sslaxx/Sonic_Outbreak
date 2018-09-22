"""
   Generic badnik script.

   All badniks will inherit this script (which itself extends from KinematicBody2D). This script doesn't do much by itself.
   It controls a badnik's hit points and score value. It has a generic "badnik_hit" function. Most badniks will use it, but
   some may not be able to. Unlike the player scripts, most logic for badniks will be in the script meant for the badnik and
   not this script.
"""

# Remember: <badnik>.gd -> generic_badnik.gd -> KinematicBody2D
extends KinematicBody2D

export var hits_to_kill = 1	# How many hits does it take to make it explode? Normally just 1, but allows for tougher badniks.
export var score_value = 100	# How many points is this badnik worth?

func _ready ():
	if (OS.is_debug_build ()):
		printerr (name, " is ready at ", position, ".")
	return

func _process (delta):
	return

func _physics_process (delta):
	return

"""
   Controlling hitting the badnik!

   Most badniks can just use this script as-is, but some may need to use a custom script instead.
"""
# TODO: Lots of stuff here. Needs to determine what's been hit, what animation state it's in, if it's invincible etc.
func badnik_hit ():
	hits_to_kill -= 1	# TODO: Lots to check before the code should get here (see above!). Plus after, like player rebounding.
	if (hits_to_kill <= 0):	# Badnik has no hits left, so it's destroyed!
		printerr (name, " at ", position, " is worth ", score_value, " points!")
		game_space.score += score_value
		sound_player.play_sound ("Destroy_Badnik")
		self.queue_free ()
	return
