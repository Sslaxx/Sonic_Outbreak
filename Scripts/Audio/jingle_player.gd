"""
   jingles_player - a singleton to play music as a jingle.
   What this does is as follows:
   1 - Mutes the Music bus. This way any music will carry on playing, just silently.
   2 - plays the specified jingle.
   3 - at the end of the jingle, unmutes Music (if wanted; the default) so anything playing becomes audible again.

   It can either emit a "jingle_finished" signal (for having played the jingle in its entirety), or "jingle_aborted" (for a
   jingle having been stopped by something else).
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("Jingles")

signal jingle_finished	# Jingle played from start to finish.
signal jingle_aborted	# Jingle has been told to stop playing before it finished.

var unmute_music = true	# True (the default) will unmute the Music bus after playing the jingle; false will not.

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
	var file = File.new ()		# Used to detect if a file exists or not.
	unmute_music = music_unmute	# Make sure music will be muted/unmuted after this jingle is done.
	if (!file.file_exists (path_to_jingle)):	# The file doesn't exist, so say so.
		printerr ("ERROR: ", path_to_jingle, " does not exist!")
		return (false)
	play_me = load (path_to_jingle)
	stream = play_me	# Set the stream.
	if (stream == null):	# If the stream is null, this means the sound file is invalid, so report an error.
		printerr ("ERROR: jingle_player has an empty stream! ", path_to_jingle, " is not a valid sound file.")
		return (false)
	AudioServer.set_bus_mute (music_player.bus_index, true)		# Mute the Music bus...
	play ()														# ...play the jingle...
	return (true)												# ...and return true.

"""
   stop_jingle
   jingles_player.stop_jingle (abort_jingle)
   Stops the currently playing jingle and unmutes Music if told to.
   If abort_jingle is true, then it'll emit "jingle_aborted", otherwise "jingle_finished".
   You may need to unmute Music manually yourself in code if you leave it muted.

   Note that this is really meant more for unmuting Music, as jingles should be not looped.
"""
func stop_jingle (abort_jingle = false):
	stop ()	# Usually not necessary as this should normally be called via signal, but here to handle exceptions to this rule.
	if (unmute_music):	# The default - unmute the music bus if this is true.
		AudioServer.set_bus_mute (music_player.bus_index, false)	# Note music_player unmutes Music if told to play something.
	unmute_music = true	# As this is a singleton, reset unmute_music after the check!
	if (abort_jingle):	# The jingle has been terminated early, so emit the "jingle_aborted" signal.
		emit ("jingle_aborted")
	else:	# Jingle has played through.
		emit ("jingle_finished")
	return
