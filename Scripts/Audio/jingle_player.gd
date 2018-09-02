"""
   jingles_player - a singleton to play music as a jingle.
   What this does is as follows:
   1 - Mutes the Music bus. This way any music will carry on playing, just silently.
   2 - plays the specified jingle.
   3 - at the end of the jingle, unmutes Music so anything playing becomes audible again.
   For more advanced stuff (jingles that rely on signals and so on), do it in the scene directly.
"""

extends AudioStreamPlayer

func _ready ():
	printerr ("Music player ready.")
	self.connect ("finished", self, "stop_jingle")
	return

"""
   play_jingle
   jingles_player.play_jingle (path_to_jingle)
   Plays a specified music file (path_to_jingle). If it's left blank, it'll just play (if there was a music file loaded before).
   It mutes the Music bus.
   Returns true if it plays something, otherwise false.
"""
## TODO: This could make use of typed GDScript, in theory, as path_to_jingle is a string.
func play_jingle (path_to_jingle = ""):
	var play_me = null	# This will be used to set the stream data.
	if (path_to_jingle != ""):	# A path was specified, so load that up.
		play_me = load (path_to_jingle)
	else:	# No path was specified, so error out.
		print_err ("No jingle file specified to play!")
		return (false)
	AudioServer.set_bus_mute (AudioServer.get_bus_index ("Music"), true)
	stream = play_me	# Everything's OK, so set the stream as needed...
	play ()	# ...play the music...
	return (true)		# ...and return true.

"""
   stop_jingle
   jingles_player.stop_jingle ()
   Stops the currently playing jingle, unmutes Music.
"""
func stop_jingle ():
	stop ()
	AudioServer.set_bus_mute (AudioServer.get_bus_index ("Music"), false)
	return
