"""
   Buzzing pest (test)!
   A try at a (very) simple badnik. Just flies left to right (within a range specified).
   If the player collides with it, it'll be destroyed.
   TODO: Collision detection should, likely, be handled here directly.
"""

extends KinematicBody2D

func _ready ():
	$"Sprite/AnimationPlayer".play ("flying")
	return

func _process (delta):
	return

func _physics_process (delta):
	return

## Controlling hitting the badnik!
# TODO: Lots of stuff here. Needs to determine what's been hit, what animation state it's in, if it's invincible etc.
func hit_the_pest ():
	print ("Do explodey stuff here!")
	sound_player.play_sound ("Hit_Badnik")
	self.queue_free ()
	return
