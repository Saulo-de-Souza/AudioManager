@tool
@icon("res://addons/audio_manager/icons/icon_plus_3d.svg")

## AudioStreamPlus3D is a super node based on Godot's native AudioStreamPlayer3D node with improvements.
class_name AudioStreamPlus3D extends Node3D


#region EXPORTS ************************************************************************************
## The AudioStream resource to be played. Setting this property stops all currently playing sounds. If left empty, the AudioStreamPlayer does not work.
@export var stream: AudioStream:
	set(value):
		stream = value
		_current_stream = stream
		_update_properties(_current_stream)
		update_configuration_warnings()

@export_subgroup("Clipper")
## Enable or disable clipper in audio.
## if true, you have to configure the start_time and and_time and the subtraction of end_time by start_time cannot be less than zero.
@export var use_clipper: bool = false:
	set(value):
		use_clipper = _can_change_use_clipper(value)
		update_configuration_warnings()

## Start time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time cannot be less than zero.
@export_range(0.0, 2.0, 0.0001, "or_greater", "suffix:sec") var start_time: float = 0.0:
	set(value):
		start_time = _can_change_start_time(value)
		update_configuration_warnings()

## End time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time cannot be less than zero.
@export_range(0.0, 2.0, 0.0001, "or_greater", "suffix:sec") var end_time: float = 0.0:
	set(value):
		end_time = _can_change_end_time(value)
		update_configuration_warnings()

## Fill in the start_time and end_time fields according to the audio track selected in the stream.
@export_tool_button("FILL IN CLIPPER") var btn_fill_clipper = _on_btn_fill_clipper

## Ignore time scaling for audio clipping. If you notice any lack of synchronization between audio clipping playbacks, enable this.
## This affects behavior when the game changes time scaling.
@export var clipper_ignore_time_scale: bool = false:
	set(value):
		clipper_ignore_time_scale = _can_change_clipper_ignore_time_scale(value)
		if is_instance_valid(_timer):
			_timer.ignore_time_scale = clipper_ignore_time_scale


@export_subgroup("Main Controls")
## If true, this node calls play() when entering the tree.
@export var autoplay: bool = false:
	set(value):
		autoplay = _can_change_autoplay(value)
		update_configuration_warnings()
		
## Enable Loop.
## If you are using AudioStreamPlaylist, its loop will be disregarded and this one will be accepted.
@export var loop: bool = false:
	set(value):
		loop = _can_change_loop(value)
		_set_loop(_current_stream, loop if not use_clipper else false)
		update_configuration_warnings()
		
## Volume of sound, in decibels. This is an offset of the stream's volume.
## Note: To convert between decibel and linear energy (like most volume sliders do), use volume_linear, or @GlobalScope.db_to_linear() and @GlobalScope.linear_to_db().
@export_range(-80.0, 80.0, 0.01, "suffix:db") var volume_db: float = 0.0:
	set(value):
		volume_db = _can_change_volume_db(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.volume_db = volume_db
		update_configuration_warnings()

## Sets the absolute maximum of the sound level, in decibels.
@export_range(-24.0, 6.0, 0.01, "suffix:db") var max_db: float = 3.0:
	set(value):
		max_db = _can_change_max_db(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.max_db = max_db
		update_configuration_warnings()


## The audio's pitch and tempo, as a multiplier of the stream's sample rate. A value of 2.0 doubles the audio's pitch, while a value of 0.5 halves the pitch.
## This does not work for AudioStreamInteractive.
@export_range(0.1, 4.0, 0.001) var pitch_scale: float = 1.0:
	set(value):
		pitch_scale = _can_change_pitch_scale(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.pitch_scale = pitch_scale
		update_configuration_warnings()
		
## The maximum number of sounds this node can play at the same time. Calling play() after this value is reached will cut off the oldest sounds.
## AudioStreamInteractive does not support polyphony.
@export_range(1, 100, 1, "or_greater") var max_polyphony: int = 1:
	set(value):
		max_polyphony = _can_change_max_polyphony(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.max_polyphony = max_polyphony
		update_configuration_warnings()
		
## The factor for the attenuation effect. Higher values make the sound audible over a larger distance.
@export_range(0.1, 100.0, 0.1, "or_greater") var unit_size: float = 10.0:
	set(value):
		unit_size = _can_change_unit_size(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.unit_size = unit_size
		update_configuration_warnings()

## The distance past which the sound can no longer be heard at all. 
## Only has an effect if set to a value greater than 0.0. 
## max_distance works in tandem with unit_size. However, unlike unit_size whose behavior depends on the attenuation_model, max_distance always works in a linear fashion. 
## This can be used to prevent the AudioStreamPlayer3D from requiring audio mixing when the listener is far away, which saves CPU resources.
@export_range(0.1, 4096.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		max_distance = _can_change_max_distance(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.max_distance = max_distance
		update_configuration_warnings()

@export_subgroup("Controls")
## Experimental: Pause audio when the browser tab loses focus and unpause audio when it regains focus.
@export var pause_onblur: bool = false:
	set(value):
		if value == pause_onblur: return
		pause_onblur = _can_change_pause_onblur(value)
		if not pause_onblur:
			if is_instance_valid(_audio_stream_player):
				_audio_stream_player.stream_paused = false
				_timer.paused = false
		else:
			if not Engine.is_editor_hint():
				print_wait("""
				[b][color=%s]WARNING![/color][/b] [color=%s]Your audio may pause if the game window loses focus due to the [b]pause_onblur = true[/b] setting in the inspector.
				If you need to test the sound in Godot, leave it as [b]false[/b] and when exporting your game, re-mark it as [b]true[/b], if you wish.[/color]
				""" % ["#4bacecff", "lime"], print_wait_enum.RICH, 0.2)
		update_configuration_warnings()

## Experimental: This property may be changed or removed in future versions.
## The playback type of the stream player. If set other than to the default value, it will force that playback type.
@export var playback_type: AudioServer.PlaybackType = AudioServer.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = _can_change_playback_type(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.playback_type = playback_type
		update_configuration_warnings()

## Decides in which step the Doppler effect should be calculated.
## Note: If doppler_tracking is not DOPPLER_TRACKING_DISABLED but the current Camera3D/AudioListener3D has doppler tracking disabled, the Doppler effect will be heard but will not take the movement of the current listener into account. 
## If accurate Doppler effect is desired, doppler tracking should be enabled on both the AudioStreamPlayer3D and the current Camera3D/AudioListener3D.
@export var doppler_tracking: AudioStreamPlayer3D.DopplerTracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_DISABLED:
	set(value):
		doppler_tracking = _can_change_doppler_tracking(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.doppler_tracking = doppler_tracking
		update_configuration_warnings()
		
## The target bus name. All sounds from this node will be playing on this bus.
## Note: At runtime, if no bus with the given name exists, all sounds will fall back on "Master". See also AudioServer.get_bus_name().
@export var bus: StringName = "Master":
	set(value):
		bus = _can_change_bus(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.bus = bus
		update_configuration_warnings()

## Scales the panning strength for this node by multiplying the base Audio > General > 3D Panning Strength by this factor. If the product is 0.0 then stereo panning is disabled and the volume is the same for all channels. If the product is 1.0 then one of the channels will be muted when the sound is located exactly to the left (or right) of the listener.
## Two speaker stereo arrangements implement the WebAudio standard for StereoPannerNode Panning   where the volume is cosine of half the azimuth angle to the ear.
## For other speaker arrangements such as the 5.1 and 7.1 the SPCAP (Speaker-Placement Correction Amplitude) algorithm is implemented.
@export_range(0.0, 3.0, 0.01) var panning_strength: float = 1.0:
	set(value):
		panning_strength = _can_change_panning_strength(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.panning_strength = panning_strength
		update_configuration_warnings()

## Determines which Area3D layers affect the sound for reverb and audio bus effects. Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
## An example of how you might use this is making a "water" area so that sounds played in the water are redirected through an audio bus to make them sound like they are being played underwater.
@export_flags_3d_physics var area_mask: int = 1:
	set(value):
		area_mask = _can_change_area_mask(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.area_mask = area_mask
		update_configuration_warnings()

@export_subgroup("Emission")
## If true, the audio should be attenuated according to the direction of the sound.
@export var emission_angle_enabled: bool = false:
	set(value):
		emission_angle_enabled = _can_change_emission_angle_enabled(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.emission_angle_enabled = emission_angle_enabled
		update_configuration_warnings()

## The angle in which the audio reaches a listener unattenuated.
@export_range(0.1, 90.0, 0.001, "suffix:deg") var emission_angle_degrees: float = 45.0:
	set(value):
		emission_angle_degrees = _can_change_emission_angle_degrees(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.emission_angle_degrees = emission_angle_degrees
		update_configuration_warnings()

## Attenuation factor used if listener is outside of emission_angle_degrees and emission_angle_enabled is set, in decibels.
@export_range(-80.0, 0.0, 0.001, "suffix:db") var emission_angle_filter_attenuation_db: float = -12.0:
	set(value):
		emission_angle_filter_attenuation_db = _can_change_emission_angle_filter_attenuation_db(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
		update_configuration_warnings()

@export_subgroup("Attenuation")
## Decides if audio should get quieter with distance linearly, quadratically, logarithmically, or not be affected by distance, effectively disabling attenuation.
@export var attenuation_model: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_INVERSE_DISTANCE:
	set(value):
		attenuation_model = _can_change_attenuation_model(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.attenuation_model = attenuation_model
		update_configuration_warnings()

## The cutoff frequency of the attenuation low-pass filter, in Hz. 
## A sound above this frequency is attenuated more than a sound below this frequency. 
## To disable this effect, set this to 20500 as this frequency is above the human hearing limit.
@export_range(1, 20500, 1, "suffix:hz") var attenuation_filter_cutoff_hz: int = 5000:
	set(value):
		attenuation_filter_cutoff_hz = _can_change_attenuation_filter_cutoff_hz(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		update_configuration_warnings()

## Amount how much the filter affects the loudness, in decibels.
@export_range(-80.0, 0.0, 0.001, "suffix:db") var attenuation_filter_db: float = -24.0:
	set(value):
		attenuation_filter_db = _can_change_attenuation_filter_db(value)
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.attenuation_filter_db = attenuation_filter_db
		update_configuration_warnings()
#endregion *****************************************************************************************


#region SIGNAL *************************************************************************************
## Emitted when a sound finishes playing without interruptions. This signal is not emitted when calling stop(), or when exiting the tree while sounds are playing.
signal finished

## Emitted when the sound is looping and ends its playback cycle before repeating when the use_clipper option is true.
signal finished_loop_in_clipper

## A signal is emitted every time the audio is paused or unpaused when pause_onblur is activated (pause_onblur = true).
signal pause_unpause_focus(pause: bool)
#endregion *****************************************************************************************
		
		
#region CONSTANTS **********************************************************************************
const AUDIO_STREAM_CLASS_NAME: String = "AudioStream"
const AUDIO_STREAM_MICROPHONE_CLASS_NAME: String = "AudioStreamMicrophone"
const AUDIO_STREAM_RANDOMIZER_CLASS_NAME: String = "AudioStreamRandomizer"
const AUDIO_STREAM_GENERATOR_CLASS_NAME: String = "AudioStreamGenerator"
const AUDIO_STREAM_WAV_CLASS_NAME: String = "AudioStreamWAV"
const AUDIO_STREAM_POLYPHONIC_CLASS_NAME: String = "AudioStreamPolyphonic"
const AUDIO_STREAM_PLAYLIST_CLASS_NAME: String = "AudioStreamPlaylist"
const AUDIO_STREAM_INTERACTIVE_CLASS_NAME: String = "AudioStreamInteractive"
const AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME: String = "AudioStreamSynchronized"
const AUDIO_STREAM_MP3_CLASS_NAME: String = "AudioStreamMP3"
const AUDIO_STREAM_OGGVORBIS_CLASS_NAME: String = "AudioStreamOggVorbis"
#endregion *****************************************************************************************

	
#region PUBLIC PROPERTIES **************************************************************************
## Returns whether audio is currently playing or not.
var is_playing: bool = false:
	get():
		if not is_instance_valid(_audio_stream_player): return false
		if not _audio_stream_player.is_inside_tree(): return false
		return _audio_stream_player.playing
	set(value):
		push_warning("is_playing is read only.")

## Returns whether the audio is paused or not.
var is_paused: bool = false:
	get():
		if not is_instance_valid(_audio_stream_player): return false
		if not _audio_stream_player.is_inside_tree(): return false
		return _audio_stream_player.stream_paused
	set(value):
		push_warning("is_paused is read only.")
#endregion *****************************************************************************************


#region PRIVATE PROPERTIES *************************************************************************
var _current_stream: AudioStream
var _audio_stream_player: AudioStreamPlayer3D
var _timer: Timer
var _count_max_polyphony: int = 0
enum _type_enum {NORMAL, NORMAL_LOOP, CLIPPER, CLIPPER_LOOP}
var _type: _type_enum = _type_enum.NORMAL:
	get():
		if not use_clipper and not loop:
			return _type_enum.NORMAL
		
		if not use_clipper and loop:
			return _type_enum.NORMAL_LOOP
		
		if use_clipper and not loop:
			return _type_enum.CLIPPER
			
		if use_clipper and loop:
			return _type_enum.CLIPPER_LOOP
		push_error("No configuration type was found.")
		return -1
	set(value):
		push_error("type is read only.")
var _window: JavaScriptObject = JavaScriptBridge.get_interface("window")
var _on_blur_ref: JavaScriptObject = JavaScriptBridge.create_callback(_on_blur)
var _on_focus_ref: JavaScriptObject = JavaScriptBridge.create_callback(_on_focus)
var _warnings: PackedStringArray = []
#endregion *****************************************************************************************

	
#region ENGINE METHODS *****************************************************************************
func _ready() -> void:
	if OS.has_feature("web"):
		_window.addEventListener("blur", _on_blur_ref)
		_window.addEventListener("focus", _on_focus_ref)

	_timer = _create_timer()
	_audio_stream_player = _create_audio_stream_player()
	_audio_stream_player.add_child(_timer)
	add_child(_audio_stream_player)
	await _is_ready()

	pause_unpause_focus.connect(_on_pause)

	if autoplay and not Engine.is_editor_hint():
		play()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_on_focus([])
	
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_on_blur([])


func _get_configuration_warnings() -> PackedStringArray:
	_warnings = []

	if not stream:
		_warnings.append("The 'stream' property needs to be defined.")

	if use_clipper and start_time >= end_time:
		_warnings.append("The 'start_time' property cannot be greater than or equal to the 'end_time' property. Change start_time or end_time so that they are different and end_time is greater than start_time.")
	
	if bus.strip_edges() == "":
		_warnings.append("The 'bus' property cannot be empty or null. Consider setting a valid value or the default value 'Master'.")

	if AudioServer.get_bus_index(bus) == -1:
		_warnings.append("The property 'bus' has an invalid value. The value '%s' does not exist. Consider using an existing value or use the default value 'Master'."%bus)

	if use_clipper and _current_stream and end_time > get_length():
		_warnings.append("The end_time property cannot be larger than the size of the audio track. Consider placing the end_time value within the audio track.")
	return _warnings


## Fill in the start_time and end_time fields according to the audio track selected in the stream.
func _on_btn_fill_clipper() -> void:
	if _current_stream and _current_stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_RANDOMIZER_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME, AUDIO_STREAM_PLAYLIST_CLASS_NAME]:
		push_warning("Not allowed for the selected stream type.")
		start_time = 0.0
		end_time = 0.0
		return

	var length: float = get_length()

	if length == 0.0:
		start_time = 0.0
		end_time = 0.0
		push_warning("You must first select a stream in order to populate the clipper. Consider selecting a valid stream.")
		return
		
	if Engine.is_editor_hint():
		var undo_redo = Engine.get_singleton("EditorInterface").get_editor_undo_redo()

		var old_start = start_time
		var old_end = end_time
		var new_start = 0.0
		var new_end = length

		undo_redo.create_action("btn_fill_start_time")
		undo_redo.add_do_property(self, &"start_time", new_start)
		undo_redo.add_undo_property(self, &"start_time", old_start)
		undo_redo.commit_action()

		undo_redo.create_action("btn_fill_end_time")
		undo_redo.add_do_property(self, &"end_time", new_end)
		undo_redo.add_undo_property(self, &"end_time", old_end)
		undo_redo.commit_action()

		start_time = new_start
		end_time = new_end
#endregion *****************************************************************************************


#region PUBLIC METHODS *****************************************************************************
## Play the audio.
func play(from_position: float = 0.0) -> void:
	if not is_inside_tree():
		push_error("The play() method is not allowed for AudioStreamPlus when it is not embedded in the node tree. It considers adding it as a child to a node or use call_deferred method.")
		return
		
	if from_position < 0:
		push_error("The `from_position` parameter of the `play()` method cannot be negative.")
		return
	
	if from_position > get_length():
		push_error("The form_position parameter of the play() method cannot be greater than the audio track.")
		return
		
	await _is_ready()

	if not _can_play():
		push_warning("Invalid stream. Consider adding a valid stream in the properties inspector.")
		return
	
	if max_polyphony > 1 and _count_max_polyphony < max_polyphony:
		_count_max_polyphony += 1

	# NORMAL
	if _type == _type_enum.NORMAL:
		if _current_stream and _current_stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME) and not _has_loop_in_interactive(_current_stream):
			_timer.wait_time = get_length()
			_timer.one_shot = true
			_timer.paused = false
			_timer.start()
		_audio_stream_player.play(from_position)
		return
		
	# NORMAL LOOP
	if _type == _type_enum.NORMAL_LOOP:
		_audio_stream_player.play(from_position)
		return
		
	# CLIPPER
	if _type == _type_enum.CLIPPER:
		_audio_stream_player.play(start_time)
		_timer.wait_time = get_length_with_weight()
		_timer.one_shot = true
		_timer.paused = false
		_timer.start()
		return
	
	# CLIPPER LOOP
	if _type == _type_enum.CLIPPER_LOOP:
		_audio_stream_player.play(start_time)
		_timer.wait_time = get_length_with_weight()
		_timer.one_shot = false
		_timer.paused = false
		_timer.start()
		return
	

## Stop current audio playback.
func stop() -> void:
	if not is_inside_tree():
		push_error("The stop() method is not allowed for AudioStreamPlus when it is not embedded in the node tree. It considers adding it as a child to a node or use call_deferred method.")
		return
		
	await _is_ready()
	
	_count_max_polyphony = 0

	if _type == _type_enum.NORMAL:
		_audio_stream_player.stop()
		if _current_stream and _current_stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME) and not _has_loop_in_interactive(_current_stream):
			finished.emit()
		return
		
	if _type == _type_enum.NORMAL_LOOP:
		_audio_stream_player.stop()
		return
		
	if _type == _type_enum.CLIPPER:
		_audio_stream_player.stop()
		_timer.stop()
		finished.emit()
		return
	
	if _type == _type_enum.CLIPPER_LOOP:
		_audio_stream_player.stop()
		_timer.stop()
		finished_loop_in_clipper.emit()
		return

	
## Pause the current audio playback.
func pause() -> void:
	if not is_inside_tree():
		push_error("The pause() method is not allowed for AudioStreamPlus when it is not embedded in the node tree. It considers adding it as a child to a node or use call_deferred method.")
		return
		
	await _is_ready()
	_audio_stream_player.stream_paused = true
	_timer.paused = true
	

## Continue playing the paused audio.	
func unpause() -> void:
	if not is_inside_tree():
		push_error("The unpause() method is not allowed for AudioStreamPlus when it is not embedded in the node tree. It considers adding it as a child to a node or use call_deferred method.")
		return
		
	await _is_ready()
	_audio_stream_player.stream_paused = false
	_timer.paused = false
	
	
## Returns the stream size without considering pitch scaling.
func get_length() -> float:
	var length: float = 0.0
	if not _current_stream: return length
	if _current_stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		var size: int = (_current_stream as AudioStreamPlaylist).stream_count
		for i in range(size):
			var current_stream: AudioStream = (_current_stream as AudioStreamPlaylist).get_list_stream(i)
			if current_stream:
				length += current_stream.get_length()
		return length
	if _current_stream.is_class(AUDIO_STREAM_RANDOMIZER_CLASS_NAME):
		var size: int = (_current_stream as AudioStreamRandomizer).streams_count
		for i in range(size):
			var current_stream: AudioStream = (_current_stream as AudioStreamRandomizer).get_stream(i)
			if current_stream:
				length += current_stream.get_length()
		return length
	if _current_stream.is_class(AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME):
		var size: int = (_current_stream as AudioStreamSynchronized).stream_count
		for i in range(size):
			var current_stream: AudioStream = (_current_stream as AudioStreamSynchronized).get_sync_stream(i)
			if current_stream:
				length += current_stream.get_length()
		return length
	if _current_stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME):
		var size: int = (_current_stream as AudioStreamInteractive).clip_count
		var initial_clip: int = (_current_stream as AudioStreamInteractive).initial_clip
		var next_clip: int = -1
		var has_next: bool = false
		var current_clip: int = initial_clip
		for i in range(size):
			var current_stream: AudioStream = (_current_stream as AudioStreamInteractive).get_clip_stream(current_clip)
			if current_stream:
				next_clip = _current_stream.get_clip_auto_advance_next_clip(current_clip)
				has_next = _current_stream.get_clip_auto_advance(current_clip) == AudioStreamInteractive.AUTO_ADVANCE_ENABLED and next_clip != current_clip
				length += current_stream.get_length()
				current_clip = next_clip
				if not has_next: break
		return length
	length = _current_stream.get_length()
	return length


## Returns the stream size considering the pitch scale. If use_clipper is true, it will return the size configured in use_clipper considering the pitch scale.
func get_length_with_weight() -> float:
	var length: float = get_length()
	var length_clipper: float = ((end_time if end_time <= length else length) - start_time)
	if use_clipper:
		return length_clipper / pitch_scale
	return length / pitch_scale
#endregion *****************************************************************************************


#region PUBLIC METHODS OF AUDIO STREAM PLAYER ******************************************************
## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
## Note: The position is not always accurate, as the AudioServer does not mix audio every processed frame. To get more accurate results, add AudioServer.get_time_since_last_mix() to the returned position.
## Note: This method always returns 0.0 if the stream is an AudioStreamInteractive, since it can have multiple clips playing at once.
func get_playback_position(add_mix: bool = false) -> float:
	if not is_instance_valid(_audio_stream_player): return 0.0
	
	var position = _audio_stream_player.get_playback_position()
	var mix = AudioServer.get_time_since_last_mix()

	if use_clipper and position == 0:
		position = start_time
		
	if position != 0 and OS.has_feature("web"):
		position += 0.2
	
	if position != 0 and add_mix:
		position += mix

	return position
	
	
## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback() -> AudioStreamPlayback:
	if not is_instance_valid(_audio_stream_player): return null
	return _audio_stream_player.get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback() -> bool:
	if not is_instance_valid(_audio_stream_player): return false
	return _audio_stream_player.has_stream_playback()
	
	
## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek(to_position: float) -> void:
	if not is_instance_valid(_audio_stream_player): return
	_audio_stream_player.seek(to_position)
	
	
## Get the AudioStreamPlayer.
func get_audio_stream_player() -> AudioStreamPlayer3D:
	return _audio_stream_player
#endregion *****************************************************************************************


#region PRIVATE METHODS ****************************************************************************
func _create_timer() -> Timer:
	var new_timer: Timer = Timer.new()
	var length: float = get_length_with_weight()
	new_timer.name = "timer"
	new_timer.set_meta("is_plus", true)
	new_timer.one_shot = true
	new_timer.wait_time = max(length, 0.05)
	new_timer.ignore_time_scale = clipper_ignore_time_scale
	new_timer.timeout.connect(_on_timer_timeout)
	return new_timer
	

func _create_audio_stream_player() -> AudioStreamPlayer3D:
	var new_audio_stream_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_audio_stream_player.name = "audio"
	new_audio_stream_player.set_meta("is_plus", true)
	new_audio_stream_player.stream = stream
	new_audio_stream_player.volume_db = volume_db
	new_audio_stream_player.max_db = max_db

	new_audio_stream_player.pitch_scale = pitch_scale
	new_audio_stream_player.max_polyphony = max_polyphony
	new_audio_stream_player.playback_type = playback_type
	new_audio_stream_player.bus = bus

	new_audio_stream_player.panning_strength = panning_strength
	new_audio_stream_player.area_mask = area_mask
	new_audio_stream_player.emission_angle_enabled = emission_angle_enabled
	new_audio_stream_player.emission_angle_degrees = emission_angle_degrees
	new_audio_stream_player.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
	new_audio_stream_player.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
	new_audio_stream_player.attenuation_filter_db = attenuation_filter_db
	new_audio_stream_player.doppler_tracking = doppler_tracking
	new_audio_stream_player.attenuation_model = attenuation_model

	new_audio_stream_player.max_distance = max_distance
	new_audio_stream_player.unit_size = unit_size

	new_audio_stream_player.finished.connect(_on_audio_stream_player_finished)
	return new_audio_stream_player
	
	
func _is_ready() -> bool:
	if not is_node_ready(): await ready
	return true
	
	
func _can_play() -> bool:
	return true if not get_length() == 0.0 else false


func _on_blur(args: Array) -> void:
	if OS.has_feature("web"):
		var _event = args[0]
		if pause_onblur:
			if is_instance_valid(_audio_stream_player):
				if is_playing and not is_paused:
					_audio_stream_player.stream_paused = true
					_timer.paused = true
					emit_wait(pause_unpause_focus, 0.1, [true])
	else:
		if pause_onblur:
			if is_instance_valid(_audio_stream_player):
				if is_playing and not is_paused:
					_audio_stream_player.stream_paused = true
					_timer.paused = true
					emit_wait(pause_unpause_focus, 0.1, [true])


func _on_focus(args: Array) -> void:
	if OS.has_feature("web"):
		var _event = args[0]
		if pause_onblur:
			if is_instance_valid(_audio_stream_player):
				_audio_stream_player.stream_paused = false
				_timer.paused = false
				emit_wait(pause_unpause_focus, 0.1, [false])
	else:
		if pause_onblur:
			if is_instance_valid(_audio_stream_player):
				if not is_playing and is_paused:
					_audio_stream_player.stream_paused = false
					_timer.paused = false
					emit_wait(pause_unpause_focus, 0.1, [false])


func _on_timer_timeout() -> void:
	if Engine.is_editor_hint(): return
	stop()
	if _type == _type_enum.CLIPPER_LOOP:
		play()
	
	
func _on_audio_stream_player_finished() -> void:
	if Engine.is_editor_hint(): return
	if _type == _type_enum.NORMAL:
		if max_polyphony > 1:
			_count_max_polyphony -= 1
			if _count_max_polyphony == 0:
				finished.emit()
		else:
			finished.emit()


func _get_streams_from(_stream: AudioStream) -> Array[AudioStream]:
	if not _stream: return []

	var streams: Array[AudioStream] = []

	if _stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		var size: int = (_stream as AudioStreamPlaylist).stream_count
		for i in range(size):
			var current_stream: AudioStream = (_stream as AudioStreamPlaylist).get_list_stream(i)
			if current_stream:
				streams.append(current_stream)
		return streams

	if _stream.is_class(AUDIO_STREAM_RANDOMIZER_CLASS_NAME):
		var size: int = (_stream as AudioStreamRandomizer).streams_count
		for i in range(size):
			var current_stream: AudioStream = (_stream as AudioStreamRandomizer).get_stream(i)
			if current_stream:
				streams.append(current_stream)
		return streams

	if _stream.is_class(AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME):
		var size: int = (_stream as AudioStreamSynchronized).stream_count
		for i in range(size):
			var current_stream: AudioStream = (_stream as AudioStreamSynchronized).get_sync_stream(i)
			if current_stream:
				streams.append(current_stream)
		return streams

	if _stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME):
		var size: int = (_stream as AudioStreamInteractive).clip_count
		for i in range(size):
			var current_stream: AudioStream = (_stream as AudioStreamInteractive).get_clip_stream(i)
			if current_stream:
				streams.append(current_stream)
		return streams
	
	streams.append(_stream)
	
	return streams


func _has_loop_in_interactive(stream: AudioStreamInteractive) -> bool:
	var visited := {}
	var current_clip := stream.initial_clip
	var size := stream.clip_count
	
	for i in range(size + 1):
		if current_clip < 0 or current_clip >= size:
			return false
		
		if visited.has(current_clip):
			var last := visited.keys().back()
			if last != current_clip:
				return true
			else:
				return false
		
		visited[current_clip] = true
		
		var auto_adv := stream.get_clip_auto_advance(current_clip)
		if auto_adv != AudioStreamInteractive.AUTO_ADVANCE_ENABLED:
			return false
		
		var next := stream.get_clip_auto_advance_next_clip(current_clip)
		if next == current_clip:
			return false
		
		current_clip = next
	
	return false

	
func _on_pause(_pause: bool) -> void:
	if not Engine.is_editor_hint() and _pause:
		print_wait("""
		[b][color=%s]WARNING![/color][/b] [color=%s]Your audio may pause if the game window loses focus due to the [b]pause_onblur = true[/b] setting in the inspector.
		If you need to test the sound in Godot, leave it as [b]false[/b] and when exporting your game, re-mark it as [b]true[/b], if you wish.[/color]
		""" % ["#4bacecff", "lime"], print_wait_enum.RICH, 0.2)
#endregion *****************************************************************************************

	
#region PRIVATE METHODS - SET LOOP *****************************************************************
func _set_loop(_stream: AudioStream, value: bool) -> void:
	if not is_instance_valid(_stream): return
	
	if _stream.is_class(AUDIO_STREAM_MP3_CLASS_NAME):
		_set_loop_mp3(_stream, value)
		return
	
	if _stream.is_class(AUDIO_STREAM_WAV_CLASS_NAME):
		_set_loop_wav(_stream, value)
		return
	
	if _stream.is_class(AUDIO_STREAM_OGGVORBIS_CLASS_NAME):
		_set_loop_ogg(_stream, value)
		return
	
	if _stream.is_class(AUDIO_STREAM_RANDOMIZER_CLASS_NAME):
		_set_loop_randomizer(_stream, value)
		return

	if _stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		_set_loop_playlist(_stream, value)
		return
	
	if _stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME):
		_set_loop_interactive(_stream, value)
		return

	if _stream.is_class(AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME):
		_set_loop_synchronized(_stream, value)
		return


func _set_loop_mp3(mp3: AudioStreamMP3, value: bool) -> void:
		mp3.loop = value
		
		
func _set_loop_ogg(ogg: AudioStreamOggVorbis, value: bool) -> void:
		ogg.loop = value

		
func _set_loop_wav(wav: AudioStreamWAV, value: bool) -> void:
	if value == true:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		var duracao_em_segundos = wav.get_length()
		var mix_rate = wav.mix_rate
		var total_samples = int(duracao_em_segundos * mix_rate)
		wav.loop_end = total_samples
	else:
		wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
		wav.loop_begin = 0
		wav.loop_end = -1


func _set_loop_randomizer(_stream: AudioStreamRandomizer, value: bool) -> void:
	for i in range(_stream.streams_count):
		_set_loop(_stream.get_stream(i), value)
		

func _set_loop_playlist(_stream: AudioStreamPlaylist, value: bool) -> void:
	_stream.loop = loop


func _set_loop_interactive(_stream: AudioStreamInteractive, value: bool) -> void:
	for i in range(_stream.clip_count):
		_set_loop(_stream.get_clip_stream(i), value)


func _set_loop_synchronized(_stream: AudioStreamSynchronized, value: bool) -> void:
	for i in range(_stream.stream_count):
		_set_loop(_stream.get_sync_stream(i), value)
#endregion *****************************************************************************************
	
	
#region PRIVATE METHODS - CAN CHANGE ***************************************************************
func _can_change_start_time(value: float) -> float:
	if value < 0:
		push_warning("The minimum value for start_time is zero. Consider assigning a value of zero or higher.")
		return start_time

	return value
	
	
func _can_change_end_time(value: float) -> float:
	if value < 0:
		push_warning("The minimum value for end_time is zero. Consider assigning a value of zero or higher.")
		return end_time

	return value


func _can_change_clipper_ignore_time_scale(value: bool) -> bool:
	return value

	
func _can_change_volume_db(value: float) -> float:
	if value < -80 or value > 80:
		push_warning("The 'volume_db' property only accepts values ​​from -80 to 80.")
		return volume_db

	return value
	
	
func _can_change_max_db(value: float) -> float:
	if value < -24 or value > 6:
		push_warning("The 'max_db' property only accepts values from -24.0 to 6.0")
		return volume_db

	return value


func _can_change_pitch_scale(value: float) -> float:
	if value < 0.1 or value > 4.0:
		push_warning("The value of the 'pitch_scale' property must be between 0.1 and 4.0.")
		return pitch_scale

	if is_instance_valid(_current_stream) and _current_stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_PLAYLIST_CLASS_NAME]:
		if value != 1.0:
			push_warning("'pitch_scale' is not supported for the selected stream type.")
			return 1.0
	return value
	
	
func _can_change_max_polyphony(value: int) -> int:
	if value < 1:
		push_warning("The 'max_polyphony' property cannot be less than 1.")
		return max_polyphony
	
	if is_instance_valid(_current_stream) and _current_stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME]:
		if value != 1:
			push_warning("'max_polyphony' is not supported for the selected stream type.")
			return 1
	return value
	

func _can_change_autoplay(value: bool) -> bool:
	return value
	
	
func _can_change_loop(value: bool) -> bool:
	if is_instance_valid(_current_stream) and _current_stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_RANDOMIZER_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME]:
		if value == true:
			push_warning("'loop' is not supported for the selected stream type.")
			return false

	return value
	

func _can_change_pause_onblur(value: bool) -> bool:
	return value
	

func _can_change_use_clipper(value: bool) -> bool:
	if is_playing or is_paused:
		push_warning("The 'use_flipper' property cannot be changed when audio is playing or paused.")
		return use_clipper

	if _current_stream and _current_stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_RANDOMIZER_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME, AUDIO_STREAM_PLAYLIST_CLASS_NAME]:
		if value == true:
			push_warning("'use_clipper' is not supported for the selected stream type.")
			return false
	return value
	

func _can_change_playback_type(value: AudioServer.PlaybackType) -> AudioServer.PlaybackType:
	return value
	

func _can_change_bus(value: StringName) -> StringName:
	if value.strip_edges() == "":
		push_warning("The 'bus' property cannot be an empty value. Consider assigning a valid value or using the default value 'Master'.")
		return "Master"
	return value


func _can_change_panning_strength(value: float) -> float:
	if value < 0:
		push_warning("The 'panning_strength' property cannot be negative.")
		return panning_strength

	return value


func _can_change_area_mask(value: int) -> int:
	return value


func _can_change_emission_angle_enabled(value: bool) -> bool:
	return value


func _can_change_emission_angle_degrees(value: float) -> float:
	return value


func _can_change_emission_angle_filter_attenuation_db(value: float) -> float:
	return value


func _can_change_attenuation_filter_cutoff_hz(value: int) -> int:
	return value


func _can_change_attenuation_filter_db(value: float) -> float:
	return value


func _can_change_doppler_tracking(value: AudioStreamPlayer3D.DopplerTracking) -> AudioStreamPlayer3D.DopplerTracking:
	return value


func _can_change_max_distance(value: float) -> float:
	if value < 0:
		push_warning("The 'max_distance' property cannot be negative.")
		return max_distance

	return value


func _can_change_unit_size(value: float) -> float:
	return value


func _can_change_attenuation_model(value: AudioStreamPlayer3D.AttenuationModel) -> AudioStreamPlayer3D.AttenuationModel:
	return value


func _update_properties(_stream: AudioStream) -> void:
	if not Engine.is_editor_hint(): return
	if not is_instance_valid(_stream): return

	max_polyphony = _can_change_max_polyphony(max_polyphony)
	loop = _can_change_loop(loop)
	start_time = _can_change_start_time(start_time)
	end_time = _can_change_end_time(end_time)
	pitch_scale = _can_change_pitch_scale(pitch_scale)
	use_clipper = _can_change_use_clipper(use_clipper)
	volume_db = _can_change_volume_db(volume_db)
	max_db = _can_change_volume_db(max_db)

	autoplay = _can_change_autoplay(autoplay)
	pause_onblur = _can_change_pause_onblur(pause_onblur)
	playback_type = _can_change_playback_type(playback_type)
	bus = _can_change_bus(bus)
	panning_strength = _can_change_panning_strength(panning_strength)
	area_mask = _can_change_area_mask(area_mask)
	emission_angle_enabled = _can_change_emission_angle_enabled(emission_angle_enabled)
	emission_angle_degrees = _can_change_emission_angle_degrees(emission_angle_degrees)
	emission_angle_filter_attenuation_db = _can_change_emission_angle_filter_attenuation_db(emission_angle_filter_attenuation_db)
	attenuation_filter_cutoff_hz = _can_change_attenuation_filter_cutoff_hz(attenuation_filter_cutoff_hz)
	attenuation_filter_db = _can_change_attenuation_filter_db(attenuation_filter_db)
	doppler_tracking = _can_change_doppler_tracking(doppler_tracking)
	max_distance = _can_change_max_distance(max_distance)
	unit_size = _can_change_unit_size(unit_size)
	attenuation_model = _can_change_attenuation_model(attenuation_model)

	if _stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		_stream.loop = loop
#endregion *****************************************************************************************
	
	
#region HELPERS ====================================================================================
var _can_print_wait: bool = true
var _can_emit: bool = true
enum print_wait_enum {RICH, WAR, ERR}


func print_wait(_msg: String, _type: print_wait_enum = print_wait_enum.RICH, _time: float = 0.3) -> void:
	if not is_node_ready(): return
	if _can_print_wait:
		_can_print_wait = false
		await get_tree().create_timer(_time).timeout

		match _type:
			print_wait_enum.RICH: print_rich(_msg.dedent())
			print_wait_enum.WAR: push_warning(_msg.dedent())
			print_wait_enum.ERR: push_error(_msg.dedent())
			_: print_rich(_msg.dedent())

		_can_print_wait = true
		
		
func emit_wait(_signal: Signal, _time: float = 0.1, args: Array = []) -> void:
	if not is_node_ready(): return
	if _can_emit:
		_can_emit = false
		await get_tree().create_timer(_time).timeout
		match args.size():
			0: _signal.emit()
			1: _signal.emit(args[0])
			2: _signal.emit(args[0], args[1])
			3: _signal.emit(args[0], args[1], args[2])
			4: _signal.emit(args[0], args[1], args[2], args[3])
		_can_emit = true
#endregion =========================================================================================
