@tool


class_name AudioManger3D extends Resource

var _warning_duration: int = 0
var _can_warning_duration: bool = false

var _warning_randomizer_count: int = 0

var _waring_starttime_endtime: int = 0
var _can_warning_starttime_endtime: bool = false

var _owner: Variant = null
var _previous_duration: float = 0.0

## Audio duration
var duration: float = 0.0:
	set(value):
		duration = value

var is_randomizer: bool = false
var is_interactive: bool = false
var is_synchronized: bool = false
var is_playlist: bool = false

## Name of the audio to be called in the code
@export var audio_name: String = "":
	set(value):
		audio_name = value
		_warning_start_time_with_end_time()
		_warning_property_null(audio_name, "NAME")


## Audio file
@export var audio_stream: AudioStream = null:
	set(value):
		audio_stream = value
		is_randomizer = value is AudioStreamRandomizer
		is_interactive = value is AudioStreamInteractive
		is_synchronized = value is AudioStreamSynchronized
		is_playlist = value is AudioStreamPlaylist

		if is_randomizer or is_interactive or is_playlist:
			if loop: loop = false
			if use_clipper: use_clipper = false
			if start_time != 0.0: start_time = 0.0
			if end_time != 0.0: end_time = 0.0
			if loop_offset != 0.0: loop_offset = 0.0
		_warning_start_time_with_end_time()
		_warning_property_null(audio_stream, "STREAM")
		if is_instance_valid(_owner):
			_owner.stream = value
			_owner.duration = duration


## Enable or disable clipper in audio.
## if true, you have to configure the start_time and and_time and the subtraction of end_time by start_time together with the loop_offset cannot be less than zero.
@export var use_clipper: bool = false:
	set(value):
		if is_randomizer or is_interactive or is_playlist:
			_warning_randomizer("AudioStream of type Randomizer, Playlist or Interactive cannot be trimmed.")
			return
		use_clipper = value
		_warning_start_time_with_end_time()
		_warning_property_null(use_clipper, "USE_CLIPPER")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.use_clipper = value
			_owner.duration = duration
			_redefine_timeout()


## Start time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var start_time: float = 0.0:
	set(value):
		if is_randomizer or is_interactive or is_playlist:
			_warning_randomizer("AudioStream of type Randomizer, Playlist or Interactive cannot be trimmed.")
			return
		start_time = value
		_warning_start_time_with_end_time()
		_warning_property_null(start_time, "START_TIME")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.start_time = value
			_owner.duration = duration
			_redefine_timeout()


## End time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var end_time: float = 0.0:
	set(value):
		if is_randomizer or is_interactive or is_playlist:
			_warning_randomizer("AudioStream of type Randomizer, Playlist or Interactive cannot be trimmed.")
			return
		end_time = value
		_warning_start_time_with_end_time()
		_warning_property_null(end_time, "END_TIME")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.duration = duration
			_redefine_timeout()


## Set Volume Db
@export_range(-80.0, 80.0, 0.01, "suffix:db") var volume_db: float = 0.0:
	set(value):
		volume_db = value
		_warning_start_time_with_end_time()
		_warning_property_null(volume_db, "VOLUME_DB")
		if is_instance_valid(_owner):
			_owner.volume_db = value


## Set Max Db
@export_range(-24.0, 6.0, 0.01, "suffix:db") var max_db: float = 3.0:
	set(value):
		max_db = value
		_warning_start_time_with_end_time()
		_warning_property_null(max_db, "MAX_DB")
		if is_instance_valid(_owner):
			_owner.max_db = value


## Set Pitch Scale
@export_range(0.1, 4.0, 0.001) var pitch_scale: float = 1.0:
	set(value):
		pitch_scale = value
		_warning_start_time_with_end_time()
		_warning_property_null(pitch_scale, "PITCH_SCALE")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.pitch_scale = value
			_owner.duration = duration
			_redefine_timeout()


## Set Max Distance
@export_range(0.1, 4096.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		max_distance = value
		_warning_start_time_with_end_time()
		_warning_property_null(max_distance, "MAX_DISTANCE")
		if is_instance_valid(_owner):
			_owner.max_distance = value


## Set Unit Size
@export_range(0.1, 100.0, 0.1, "or_greater") var unit_size: float = 10.0:
	set(value):
		unit_size = value
		_warning_start_time_with_end_time()
		_warning_property_null(unit_size, "UNIT_SIZE")
		if is_instance_valid(_owner):
			_owner.unit_size = value


## Set Loop
@export var loop: bool = false:
	set(value):
		if is_randomizer or is_interactive or is_playlist:
			_warning_randomizer("AudioStream of type Randomizer, Playlist or Interactive cannot loop.")
			return
		loop = value
		_warning_start_time_with_end_time()
		_warning_property_null(loop, "LOOP")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.loop = value
			_owner.duration = duration
			_redefine_timeout()


## Audio rewinds in seconds when looping.
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 1.0, 0.0001, "or_greater", "suffix:sec") var loop_offset: float = 0.0:
	set(value):
		if is_randomizer or is_interactive or is_playlist:
			_warning_randomizer("AudioStream of the Randomizer, Playlist or Interactive type cannot have a loop and therefore does not have a loopoffset.")
			return
		loop_offset = value
		_warning_start_time_with_end_time()
		_warning_property_null(loop_offset, "LOOP_OFFSET")
		_define_duration()
		if is_instance_valid(_owner):
			_owner.duration = duration
			_redefine_timeout()


## Play the audio as soon as you enter the scene.
@export var auto_play: bool = false:
	set(value):
		auto_play = value
		_warning_start_time_with_end_time()
		_warning_property_null(auto_play, "AUTO_PLAY")


## Set Max Polyphony
@export_range(1, 100, 1, "or_greater") var max_polyphony: int = 1:
	set(value):
		max_polyphony = value
		_warning_start_time_with_end_time()
		_warning_property_null(max_polyphony, "MAX_POLYPHONY")
		if is_instance_valid(_owner):
			_owner.max_polyphony = value


## Set Panning Strength
@export_range(0.0, 3.0, 0.01) var panning_strength: float = 1.0:
	set(value):
		panning_strength = value
		_warning_start_time_with_end_time()
		_warning_property_null(panning_strength, "PANNING_STRENGTH")
		if is_instance_valid(_owner):
			_owner.panning_strength = value


@export_flags_2d_physics var area_mask: int = 1:
	set(value):
		area_mask = value
		if is_instance_valid(_owner):
			_owner.area_mask = value


@export var bus: StringName = "Master":
	set(value):
		bus = value
		if AudioServer.get_bus_index(value) == -1:
			push_warning("Audio bus '%s' not found in AudioServer." % value)
			return
		if is_instance_valid(_owner):
			_owner.bus = value


@export var playback_type: AudioServer.PlaybackType = AudioServer.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = value
		if is_instance_valid(_owner):
			_owner.playback_type = value


@export var emission_angle_enabled: bool = false:
	set(value):
		emission_angle_enabled = value
		if is_instance_valid(_owner):
			_owner.emission_angle_enabled = value


@export_range(0.1, 90.0, 0.001, "suffix:deg") var emission_angle_degrees: float = 45.0:
	set(value):
		emission_angle_degrees = value
		if is_instance_valid(_owner):
			_owner.emission_angle_degrees = value


@export_range(-80.0, 0.0, 0.001, "suffix:db") var emission_angle_filter_attenuation_db: float = -12.0:
	set(value):
		emission_angle_filter_attenuation_db = value
		if is_instance_valid(_owner):
			_owner.emission_angle_filter_attenuation_db = value


@export_range(1, 20500, 1, "suffix:hz") var attenuation_filter_cutoff_hz: int = 5000:
	set(value):
		attenuation_filter_cutoff_hz = value
		if is_instance_valid(_owner):
			_owner.attenuation_filter_cutoff_hz = value


@export_range(-80.0, 0.0, 0.001, "suffix:db") var attenuation_filter_db: float = -24.0:
	set(value):
		attenuation_filter_db = value
		if is_instance_valid(_owner):
			_owner.attenuation_filter_db = value


@export var doppler_tracking: AudioStreamPlayer3D.DopplerTracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_DISABLED:
	set(value):
		doppler_tracking = value
		if is_instance_valid(_owner):
			_owner.doppler_tracking = value


func _increment_loop_offset() -> float:
	if loop:
		return loop_offset
	else:
		return 0.0


func _define_duration() -> void:
	_previous_duration = duration
	if use_clipper:
		if audio_stream:
			duration = min(max(((end_time - start_time) - _increment_loop_offset()) / pitch_scale, 0.0), audio_stream.get_length())
		else:
			duration = 0.0
	else:
		if not is_instance_valid(audio_stream):
			duration = 0.0
		else:
			duration = max((audio_stream.get_length() - _increment_loop_offset()) / pitch_scale, 0.0)
	_warning_duration_zero()


func _warning_start_time_with_end_time() -> void:
	if _waring_starttime_endtime >= 7:
		if not _can_warning_starttime_endtime:
			_can_warning_starttime_endtime = true
	else:
		_waring_starttime_endtime += 1
	if _can_warning_starttime_endtime and Engine.is_editor_hint() and audio_stream and use_clipper and start_time > end_time:
		push_warning("Start time cannot be greater than end time in Audio resource: %s" % audio_name)


func _warning_property_null(value: Variant, property_string: String) -> void:
	if value is String:
		if value == "":
			push_warning("The %s parameter cannot be null or empty. (%s)" % [property_string, audio_name])
	else:
		if value == null:
			push_warning("The %s parameter cannot be null or empty. (%s)" % [property_string, audio_name])


func _warning_duration_zero() -> void:
	if _warning_duration >= 7:
		if not _can_warning_duration:
			_can_warning_duration = true
	else:
		_warning_duration += 1

	if not is_randomizer and _can_warning_duration and Engine.is_editor_hint() and audio_stream and duration <= 0:
		push_warning("The audio duration cannot be less than or equal to zero. Check the properties: START_TIME, END_TIME and LOOP_OFFSET.")


func _warning_randomizer(value: String) -> void:
	if _warning_randomizer_count > 5:
		push_warning(value)
	else:
		_warning_randomizer_count += 1


func get_audio_stream_player3d() -> AudioStreamPlayer3D:
	return _owner as AudioStreamPlayer3D


func _redefine_timeout() -> void:
	if not _owner.timer.is_stopped():
		var elapsed_time: float = _previous_duration - _owner.timer.time_left
		var progress: float = elapsed_time / _previous_duration if _previous_duration > 0 else 0.0
		var new_remaining_time: float = duration * (1.0 - progress)
		_owner.timer.stop()
		var cb_timeout: Callable
		for connection: Variant in _owner.timer.get_signal_connection_list("timeout"):
			cb_timeout = connection.callable
			_owner.timer.disconnect("timeout", connection.callable)
		_owner.timer.wait_time = max(new_remaining_time, 0.0001)
		_owner.timer.timeout.connect(cb_timeout)
		_owner.timer.start()
