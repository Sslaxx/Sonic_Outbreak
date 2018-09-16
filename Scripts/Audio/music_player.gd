"""
   music_player - a singleton to be used to play music (normally looped, but whatever is necessary).
   For more advanced stuff (music that relies on signals and so on), do it in the scene directly.
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("Music")

func _ready ():
	if (OS.is_debug_build ()):
		printerr ("Music player ready.")
	return

"""
   play_music
   music_player.play_music (path_to_music, play_from)
   Plays a specified music file (path_to_music), unmuting the Music bus if need be.
   Will play from a specific point in the music (in seconds) if told to (play_from).
   Returns true if it plays something, otherwise false.
"""
## TODO: This could make use of typed GDScript in 3.1, in theory, as path_to_music is a string.
func play_music (path_to_music = "", play_from = 0.0):
	var play_me = null		# This will be used to set the stream data.
	var file = File.new ()	# Used to see if the file exists.
	if (!file.file_exists (path_to_music)):	# The file specified to play does not exist.
		printerr ("ERROR: ", path_to_music, " does not exist.")
		return (false)
	play_me = load (path_to_music)
	stream = play_me	# Everything's OK, so set the stream as needed?
	if (stream == null):	# Except it's not actually a music file, so error out.
		printerr ("ERROR: ", path_to_music, " is not a valid music file!")
		return (false)
	if (AudioServer.is_bus_mute (bus_index)):	# Unmute Music if it's muted...
		AudioServer.set_bus_mute (bus_index, false)
	play (play_from)							# ...play the music...
	return (true)								# ...and return true.

"""
   stop_music
   music_player.stop_music ()
   Just a bit of syntactic sugar. Stops the currently playing music.
"""
func stop_music ():
	stop ()
	return
