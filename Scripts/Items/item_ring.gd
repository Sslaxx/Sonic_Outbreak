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

### Rings (aka collectibles).

extends Area2D

var ring_taken = false

func _ready ():
	self.connect ("body_entered", self, "got_ring")	# Handles when the ring is collected.
	$"Sprite".play ()
	return

func got_ring (body):
	if (!ring_taken && body is preload ("res://Scripts/Player/player_generic.gd")):
		ring_taken = true				# Player has picked up the ring! So make sure this ring is set as taken.
#		visible = false					# And then as invisible, because of playing the sound.
		game_space.rings += 1			# Increase the player's rings count.
		sound_player.play_sound ("Get_Ring")
	if (OS.is_debug_build()):	# FOR DEBUGGING ONLY.
		printerr ("Ring got at ", position)
	queue_free ()
	return
