"""
   Buzzing pest (test)!
   A try at a (very) simple badnik. Just flies left to right (within a range specified).
   If the player collides with it, it'll be destroyed.
   TODO: Collision detection should, likely, be handled here directly.
"""

extends KinematicBody2D

export var hits_to_kill = 1	# How many hits does it take to make it explode? Normally just 1, but allows for tougher badniks.
export var score_value = 100	# How many points is this badnik worth?

func _ready ():
	$"Sprite/AnimationPlayer".play ("flying")
	if (OS.is_debug_build ()):
		printerr (name, " is ready at ", position, ".")
	return

func _process (delta):
	return

func _physics_process (delta):
	return

## Controlling hitting the badnik!
# TODO: Lots of stuff here. Needs to determine what's been hit, what animation state it's in, if it's invincible etc.
func hit_the_pest ():
	hits_to_kill -= 1	# TODO: Lots to check before the code should get here (see above!). Plus after, like player rebounding.
	if (hits_to_kill <= 0):	# Badnik has no hits left, so it's destroyed!
		printerr (name, " at ", position, " is worth ", score_value, " points!")
		game_space.score += score_value
		sound_player.play_sound ("Destroy_Badnik")
		self.queue_free ()
	return
