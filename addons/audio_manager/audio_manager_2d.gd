@tool


class_name AudioManger2D extends Resource

var _warning_duration: int = 0
var _can_warning_duration: bool = false

var _waring_starttime_endtime: int = 0
var _can_warning_starttime_endtime: bool = false

var _owner: Variant = null

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
		

## Set Max Distance
@export_range(0.1, 4096.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		max_distance = value
		_warning_start_time_with_end_time()
		_warning_property_null(max_distance, "MAX_DISTANCE")
		if is_instance_valid(_owner):
			_owner.max_distance = value


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
		

func _increment_loop_offset() -> float:
	if loop:
		return loop_offset
	else:
		return 0.0


func _define_duration() -> void:
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
	

func get_audio_stream_player2d() -> AudioStreamPlayer2D:
	return _owner as AudioStreamPlayer2D
