@tool


class_name AudioMangerOmni extends Resource

var _warning_duration: int = 0
var _can_warning_duration: bool = false

var _waring_starttime_endtime: int = 0
var _can_warning_starttime_endtime: bool = false

var _owner: Variant = null
var _previous_duration = 0.0

## Audio duration
var duration: float = 0.0:
	set(value):
		duration = value
		

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
		_warning_start_time_with_end_time()
		_warning_property_null(audio_stream, "STREAM")
		if is_instance_valid(_owner):
			_owner.stream = value
			_owner.duration = duration
			
			
## Enable or disable clipper in audio.
## if true, you have to configure the start_time and and_time and the subtraction of end_time by start_time together with the loop_offset cannot be less than zero.
@export var use_clipper: bool = false:
	set(value):
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
		

## Set Unit Size
@export var mix_target: AudioStreamPlayer.MixTarget = AudioStreamPlayer.MixTarget.MIX_TARGET_STEREO:
	set(value):
		mix_target = value
		_warning_start_time_with_end_time()
		_warning_property_null(mix_target, "MIX_TARGET")
		if is_instance_valid(_owner):
			_owner.mix_target = value


## Set Loop
@export var loop: bool = false:
	set(value):
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
	pass


func _warning_start_time_with_end_time() -> void:
	if _waring_starttime_endtime >= 7:
		if not _can_warning_starttime_endtime:
			_can_warning_starttime_endtime = true
	else:
		_waring_starttime_endtime += 1
	if _can_warning_starttime_endtime and Engine.is_editor_hint() and audio_stream and use_clipper and start_time > end_time:
		push_warning("Start time cannot be greater than end time in Audio resource: %s" % audio_name)
	pass


func _warning_property_null(value: Variant, property_string: String) -> void:
	if value is String:
		if value == "":
			push_warning("The %s parameter cannot be null or empty. (%s)" % [property_string, audio_name])
	else:
		if value == null:
			push_warning("The %s parameter cannot be null or empty. (%s)" % [property_string, audio_name])
	pass
	
	
func _warning_duration_zero() -> void:
	if _warning_duration >= 7:
		if not _can_warning_duration:
			_can_warning_duration = true
	else:
		_warning_duration += 1
		
	if _can_warning_duration and Engine.is_editor_hint() and audio_stream and duration <= 0:
		push_warning("The audio duration cannot be less than or equal to zero. Check the properties: START_TIME, END_TIME and LOOP_OFFSET.")

	pass
	
	
func get_audio_stream_player() -> AudioStreamPlayer:
		return _owner as AudioStreamPlayer


func _redefine_timeout() -> void:
	if not _owner.timer.is_stopped():
		var elapsed_time = _previous_duration - _owner.timer.time_left
		var progress = elapsed_time / _previous_duration if _previous_duration > 0 else 0.0
		var new_remaining_time = duration * (1.0 - progress)
		_owner.timer.stop()
		var cb_timeout
		for connection in _owner.timer.get_signal_connection_list("timeout"):
			cb_timeout = connection.callable
			_owner.timer.disconnect("timeout", connection.callable)
		_owner.timer.wait_time = max(new_remaining_time, 0.0001)
		_owner.timer.timeout.connect(cb_timeout)
		_owner.timer.start()
	pass
