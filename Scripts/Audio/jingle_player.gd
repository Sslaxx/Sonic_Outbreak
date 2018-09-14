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
   jingles_player - a singleton to play music as a jingle.
   What this does is as follows:
   1 - Mutes the Music bus. This way any music will carry on playing, just silently.
   2 - plays the specified jingle.
   3 - at the end of the jingle, unmutes Music (if wanted; the default) so anything playing becomes audible again.
   For more advanced stuff (jingles that rely on signals and so on), do it in the scene directly.
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("Jingles")

var unmute_music = true	# True (the default) will unmute the Music bus, false will not.

func _ready ():
	if (OS.is_debug_build ()):
		printerr ("Jingle player ready.")
	self.connect ("finished", self, "stop_jingle")
	return

"""
   play_jingle
   jingles_player.play_jingle (path_to_jingle, music_unmute)
   Plays a specified music file as a jingle (path_to_jingle), muting the Music bus beforehand.
   After the jingle is finished, music_unmute can be set false to leave the music bus muted.
   Returns true if it plays something, otherwise false.
"""
## TODO: This could make use of typed GDScript, in theory, as path_to_jingle is a string.
func play_jingle (path_to_jingle = "", music_unmute = true):
	var play_me = null			# This will hold the stream for the jingle.
	unmute_music = music_unmute	# Make sure music will be muted/unmuted after this jingle is done.
	if (path_to_jingle != ""):	# A path was specified, so load that up.
		play_me = load (path_to_jingle)
	else:	# No path was specified, so error out.
		printerr ("No jingle file specified to play!")
		return (false)
	stream = play_me														# Everything's OK, so set the stream as needed...
	AudioServer.set_bus_mute (music_player.bus_index, true)	# ...mute the Music bus...
	play ()																	# ...play the jingle...
	return (true)															# ...and return true.

"""
   stop_jingle
   jingles_player.stop_jingle ()
   Stops the currently playing jingle, unmutes Music.
   Remember to unmute Music manually yourself in code if you leave it muted!
"""
func stop_jingle ():
	stop ()	# Shouldn't be necessary as this should only be called via signal, but just in case.
	if (unmute_music):	# The default - unmute the music bus if this is true.
		AudioServer.set_bus_mute (music_player.bus_index, false)
	unmute_music = true	# As this is a singleton, reset unmute_music after the check!
	return
