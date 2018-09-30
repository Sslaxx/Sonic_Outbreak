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

### Deals with time over. Very similar to game over, really, just that this doesn't reset things for a new game.

extends Sprite

func _ready ():
	if (OS.is_debug_build()):	# FOR DEBUGGING ONLY.
		printerr ("TIME OVER")
	jingle_player.play_jingle ("res://Assets/Audio/Jingles/63_-_Game_Over.ogg", false)
	get_tree ().set_pause (true)		# Pause the game.
	return

func _unhandled_key_input (event):
	if (event.pressed):
		jingle_player.stop_jingle ()
		AudioServer.set_bus_mute (music_player.bus_index, false)
		get_tree ().set_pause (false)		# Unpause the game.
		queue_free ()	# Make sure this is removed when the time comes.
	return
