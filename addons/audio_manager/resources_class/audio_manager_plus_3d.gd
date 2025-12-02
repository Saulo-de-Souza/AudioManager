@tool
@icon("res://addons/audio_manager/icons/audio_stream_plus_3d_res.svg")
class_name AudioManagerPlus3D extends Resource


## The audio file name. Remember: Each AudioStreamPlus file must have a unique name.
@export_placeholder("Audio name") var audio_name: String:
	set(value):
		audio_name = _can_change_audio_name(value)
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## The AudioStream resource to be played. Setting this property stops all currently playing sounds. If left empty, the AudioStreamPlayer does not work.
@export var stream: AudioStream:
	set(value):
		stream = value
		_update_properties(stream)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.stream = stream
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()


@export_subgroup("Clipper")
## Enable or disable clipper in audio.
## if true, you have to configure the start_time and and_time and the subtraction of end_time by start_time cannot be less than zero.
@export var use_clipper: bool = false:
	set(value):
		use_clipper = _can_change_use_clipper(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.use_clipper = use_clipper
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Start time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time cannot be less than zero.
@export_range(0.0, 2.0, 0.0001, "or_greater", "suffix:sec") var start_time: float = 0.0:
	set(value):
		start_time = _can_change_start_time(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.start_time = start_time
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## End time of audio in seconds when use_clipper is true.
## Remember: the value of end_time minus the value of start_time cannot be less than zero.
@export_range(0.0, 2.0, 0.0001, "or_greater", "suffix:sec") var end_time: float = 0.0:
	set(value):
		end_time = _can_change_end_time(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.end_time = end_time
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Ignore time scaling for audio clipping. If you notice any lack of synchronization between audio clipping playbacks, enable this.
## This affects behavior when the game changes time scaling.
@export var clipper_ignore_time_scale: bool = false:
	set(value):
		clipper_ignore_time_scale = _can_change_clipper_ignore_time_scale(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.clipper_ignore_time_scale = clipper_ignore_time_scale
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()


@export_subgroup("Main Controls")
## If true, this node calls play() when entering the tree.
@export var autoplay: bool = false:
	set(value):
		autoplay = _can_change_autoplay(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.autoplay = autoplay
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## Enable Loop.
## If you are using AudioStreamPlaylist, its loop will be disregarded and this one will be accepted.
@export var loop: bool = false:
	set(value):
		loop = _can_change_loop(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.loop = loop
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## Volume of sound, in decibels. This is an offset of the stream's volume.
## Note: To convert between decibel and linear energy (like most volume sliders do), use volume_linear, or @GlobalScope.db_to_linear() and @GlobalScope.linear_to_db().
@export_range(-80.0, 80.0, 0.01, "suffix:db") var volume_db: float = 0.0:
	set(value):
		volume_db = _can_change_volume_db(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.volume_db = volume_db
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Sets the absolute maximum of the sound level, in decibels.
@export_range(-24.0, 6.0, 0.01, "suffix:db") var max_db: float = 3.0:
	set(value):
		max_db = _can_change_max_db(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.max_db = max_db
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## The audio's pitch and tempo, as a multiplier of the stream's sample rate. A value of 2.0 doubles the audio's pitch, while a value of 0.5 halves the pitch.
## This does not work for AudioStreamInteractive.
@export_range(0.1, 4.0, 0.001) var pitch_scale: float = 1.0:
	set(value):
		pitch_scale = _can_change_pitch_scale(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.pitch_scale = pitch_scale
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The maximum number of sounds this node can play at the same time. Calling play() after this value is reached will cut off the oldest sounds.
## AudioStreamInteractive does not support polyphony.
@export_range(1, 100, 1, "or_greater") var max_polyphony: int = 1:
	set(value):
		max_polyphony = _can_change_max_polyphony(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.max_polyphony = max_polyphony
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The factor for the attenuation effect. Higher values make the sound audible over a larger distance.
@export_range(0.1, 100.0, 0.1, "or_greater") var unit_size: float = 10.0:
	set(value):
		unit_size = _can_change_unit_size(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.unit_size = unit_size
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The distance past which the sound can no longer be heard at all. 
## Only has an effect if set to a value greater than 0.0. 
## max_distance works in tandem with unit_size. However, unlike unit_size whose behavior depends on the attenuation_model, max_distance always works in a linear fashion. 
## This can be used to prevent the AudioStreamPlayer3D from requiring audio mixing when the listener is far away, which saves CPU resources.
@export_range(0.1, 4096.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		max_distance = _can_change_max_distance(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.max_distance = max_distance
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		

@export_subgroup("Controls")
## Experimental: Pause audio when the browser tab loses focus and unpause audio when it regains focus.
@export var pause_onblur: bool = false:
	set(value):
		pause_onblur = _can_change_pause_onblur(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.pause_onblur = pause_onblur
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Experimental: This property may be changed or removed in future versions.
## The playback type of the stream player. If set other than to the default value, it will force that playback type.
@export var playback_type: AudioServer.PlaybackType = AudioServer.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = _can_change_playback_type(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.playback_type = playback_type
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Decides in which step the Doppler effect should be calculated.
## Note: If doppler_tracking is not DOPPLER_TRACKING_DISABLED but the current Camera3D/AudioListener3D has doppler tracking disabled, the Doppler effect will be heard but will not take the movement of the current listener into account. 
## If accurate Doppler effect is desired, doppler tracking should be enabled on both the AudioStreamPlayer3D and the current Camera3D/AudioListener3D.
@export var doppler_tracking: AudioStreamPlayer3D.DopplerTracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_DISABLED:
	set(value):
		doppler_tracking = _can_change_doppler_tracking(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.doppler_tracking = doppler_tracking
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The target bus name. All sounds from this node will be playing on this bus.
## Note: At runtime, if no bus with the given name exists, all sounds will fall back on "Master". See also AudioServer.get_bus_name().
@export var bus: StringName = "Master":
	set(value):
		bus = _can_change_bus(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.bus = bus
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Scales the panning strength for this node by multiplying the base Audio > General > 3D Panning Strength with this factor. Higher values will pan audio from left to right more dramatically than lower values.
@export_range(0.0, 3.0, 0.01) var panning_strength: float = 1.0:
	set(value):
		panning_strength = _can_change_panning_strength(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.panning_strength = panning_strength
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## Determines which Area3D layers affect the sound for reverb and audio bus effects. Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
## An example of how you might use this is making a "water" area so that sounds played in the water are redirected through an audio bus to make them sound like they are being played underwater.
@export_flags_3d_physics var area_mask: int = 1:
	set(value):
		area_mask = _can_change_area_mask(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.area_mask = area_mask
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()


@export_subgroup("Emission")
## If true, the audio should be attenuated according to the direction of the sound.
@export var emission_angle_enabled: bool = false:
	set(value):
		emission_angle_enabled = _can_change_emission_angle_enabled(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.emission_angle_enabled = emission_angle_enabled
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The angle in which the audio reaches a listener unattenuated.
@export_range(0.1, 90.0, 0.001, "suffix:deg") var emission_angle_degrees: float = 45.0:
	set(value):
		emission_angle_degrees = _can_change_emission_angle_degrees(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.emission_angle_degrees = emission_angle_degrees
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## Attenuation factor used if listener is outside of emission_angle_degrees and emission_angle_enabled is set, in decibels.
@export_range(-80.0, 0.0, 0.001, "suffix:db") var emission_angle_filter_attenuation_db: float = -12.0:
	set(value):
		emission_angle_filter_attenuation_db = _can_change_emission_angle_filter_attenuation_db(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		

@export_subgroup("Attenuation")
## Decides if audio should get quieter with distance linearly, quadratically, logarithmically, or not be affected by distance, effectively disabling attenuation.
@export var attenuation_model: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_INVERSE_DISTANCE:
	set(value):
		attenuation_model = _can_change_attenuation_model(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.attenuation_model = attenuation_model
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The cutoff frequency of the attenuation low-pass filter, in Hz. 
## A sound above this frequency is attenuated more than a sound below this frequency. 
## To disable this effect, set this to 20500 as this frequency is above the human hearing limit.
@export_range(1, 20500, 1, "suffix:hz") var attenuation_filter_cutoff_hz: int = 5000:
	set(value):
		attenuation_filter_cutoff_hz = _can_change_attenuation_filter_cutoff_hz(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## Amount how much the filter affects the loudness, in decibels.
@export_range(-80.0, 0.0, 0.001, "suffix:db") var attenuation_filter_db: float = -24.0:
	set(value):
		attenuation_filter_db = _can_change_attenuation_filter_db(value)
		if is_instance_valid(_audio_stream_plus3d):
			_audio_stream_plus3d.attenuation_filter_db = attenuation_filter_db
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		

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


static var _count_name: int = 0
var _owner: AudioManager
var _audio_stream_plus3d: AudioStreamPlus3D


func _init_owner(p_owner: AudioManager) -> void:
	_owner = p_owner
	
	if not is_instance_valid(_audio_stream_plus3d):
		_audio_stream_plus3d = _create_audio_stream_player3d()
		
	if not _audio_stream_plus3d.is_inside_tree():
		if not _audio_stream_plus3d.get_parent():
			_owner.add_child(_audio_stream_plus3d)
	
	if not _audio_stream_plus3d.finished.is_connected(_on_audio_plus_finished):
		_audio_stream_plus3d.finished.connect(_on_audio_plus_finished)
		
	if not _audio_stream_plus3d.finished_loop_in_clipper.is_connected(_on_audio_plus_finished_loop_in_clipper):
		_audio_stream_plus3d.finished_loop_in_clipper.connect(_on_audio_plus_finished_loop_in_clipper)
		
	if not _audio_stream_plus3d.pause_unpause_focus.is_connected(_on_audio_plus_pause_unpause_focus):
		_audio_stream_plus3d.pause_unpause_focus.connect(_on_audio_plus_pause_unpause_focus)
		
	
func _remove() -> void:
	if not is_instance_valid(_audio_stream_plus3d): return
		
	if _audio_stream_plus3d.is_inside_tree():
		_owner.remove_child(_audio_stream_plus3d)
	
	if _audio_stream_plus3d.finished.is_connected(_on_audio_plus_finished):
		_audio_stream_plus3d.finished.disconnect(_on_audio_plus_finished)
		
	if _audio_stream_plus3d.finished_loop_in_clipper.is_connected(_on_audio_plus_finished_loop_in_clipper):
		_audio_stream_plus3d.finished_loop_in_clipper.disconnect(_on_audio_plus_finished_loop_in_clipper)
		
	if _audio_stream_plus3d.pause_unpause_focus.is_connected(_on_audio_plus_pause_unpause_focus):
		_audio_stream_plus3d.pause_unpause_focus.disconnect(_on_audio_plus_pause_unpause_focus)
	
	
func _create_audio_stream_player3d() -> AudioStreamPlus3D:
	var new_audio: AudioStreamPlus3D = AudioStreamPlus3D.new()
	new_audio.stream = stream
	new_audio.use_clipper = use_clipper
	new_audio.start_time = start_time
	new_audio.end_time = end_time

	new_audio.volume_db = volume_db
	new_audio.max_db = max_db
	new_audio.pitch_scale = pitch_scale
	new_audio.max_polyphony = max_polyphony
	new_audio.autoplay = autoplay
	new_audio.loop = loop
	new_audio.pause_onblur = pause_onblur
	new_audio.playback_type = playback_type
	new_audio.bus = bus

	new_audio.max_distance = max_distance
	new_audio.panning_strength = panning_strength

	new_audio.area_mask = area_mask

	new_audio.unit_size = unit_size
	new_audio.max_distance = max_distance
	new_audio.doppler_tracking = doppler_tracking
	new_audio.emission_angle_enabled = emission_angle_enabled
	new_audio.emission_angle_degrees = emission_angle_degrees
	new_audio.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
	new_audio.attenuation_model = attenuation_model
	new_audio.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
	new_audio.attenuation_filter_db = attenuation_filter_db
	new_audio.clipper_ignore_time_scale = clipper_ignore_time_scale

	if audio_name.strip_edges() != "":
		new_audio.name = audio_name
	else:
		_count_name += 1
		var new_name := "audio_plus3d_%s" % _count_name
		new_audio.name = new_name
		audio_name = new_name

	return new_audio


func _on_audio_plus_finished() -> void:
	if is_instance_valid(_owner):
		_owner.finished_plus3d.emit(audio_name)
		
	
func _on_audio_plus_finished_loop_in_clipper() -> void:
	if is_instance_valid(_owner):
		_owner.finished_plus3d_loop_in_clipper.emit(audio_name)
	 
	
func _on_audio_plus_pause_unpause_focus(pause: bool) -> void:
	if is_instance_valid(_owner):
		_owner.pause_unpause_changed_plus3d.emit(audio_name, pause)
	

func get_audio_plus() -> AudioStreamPlus3D:
	return _audio_stream_plus3d

	
#region PRIVATE METHODS - CAN CHANGE ***************************************************************
func _can_change_audio_name(value: String) -> String:
	if value.strip_edges() == "":
		if is_instance_valid(_owner) and _owner.get_plus3d(audio_name):
				_owner.get_plus3d(audio_name).name = audio_name

		push_warning("The 'audio_name' property cannot be empty or null. Consider assigning a unique value to each audio file.")
		return audio_name

	if is_instance_valid(_owner) and _owner.get_plus3d(audio_name):
		_owner.get_plus3d(audio_name).name = value

	return value


func _can_change_pitch_scale(value: float) -> float:
	if value < 0.1 or value > 4.0:
		push_warning("The value of the 'pitch_scale' property must be between 0.1 and 4.0.")
		return pitch_scale
		
	if is_instance_valid(stream) and stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_PLAYLIST_CLASS_NAME]:
		if value != 1.0:
			push_warning("'pitch_scale' is not supported for the selected stream type.")
			return 1.0

	return value
	
	
func _can_change_max_polyphony(value: int) -> int:
	if value < 1:
		push_warning("The 'max_polyphony' property cannot be less than 1.")
		return max_polyphony

	if is_instance_valid(stream) and stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME]:
		if value != 1:
			push_warning("'max_polyphony' is not supported for the selected stream type.")
			return 1

	return value
	
	
func _can_change_loop(value: bool) -> bool:
	if is_instance_valid(stream) and stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_RANDOMIZER_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME]:
		if value == true:
			push_warning("'loop' is not supported for the selected stream type.")
			return false

	return value
	

func _can_change_use_clipper(value: bool) -> bool:
	if is_instance_valid(_audio_stream_plus3d) and (_audio_stream_plus3d.is_playing or _audio_stream_plus3d.is_paused):
		push_warning("The 'use_flipper' property cannot be changed when audio is playing or paused.")
		return use_clipper

	if is_instance_valid(stream) and stream.get_class() in [AUDIO_STREAM_INTERACTIVE_CLASS_NAME, AUDIO_STREAM_RANDOMIZER_CLASS_NAME, AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME, AUDIO_STREAM_PLAYLIST_CLASS_NAME]:
		if value == true:
			push_warning("'use_clipper' is not supported for the selected stream type.")
			return false

	return value
	

func _can_change_bus(value: StringName) -> StringName:
	if value.strip_edges() == "":
		push_warning("The 'bus' property cannot be an empty value. Consider assigning a valid value or using the default value 'Master'.")
		return "Master"
	return value
	

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


func _can_change_max_distance(value: float) -> float:
	if value < 0:
		push_warning("The 'max_distance' property cannot be negative.")
		return max_distance
		
	return value


func _can_change_panning_strength(value: float) -> float:
	if value < 0:
		push_warning("The 'panning_strength' property cannot be negative.")
		return panning_strength
		
	return value


func _can_change_autoplay(value: bool) -> bool:
	return value


func _can_change_unit_size(value: float) -> float:
	if value < 0.1:
		push_warning("The 'unit_size' property cannot be less than 0.1.")
		return unit_size

	return value


func _can_change_pause_onblur(value: bool) -> bool:
	return value


func _can_change_playback_type(value: AudioServer.PlaybackType) -> AudioServer.PlaybackType:
	return value


func _can_change_area_mask(value: int) -> int:
	return value


func _can_change_doppler_tracking(value: AudioStreamPlayer3D.DopplerTracking) -> AudioStreamPlayer3D.DopplerTracking:
	return value
	

func _can_change_emission_angle_enabled(value: bool) -> bool:
	return value


func _can_change_emission_angle_degrees(value: float) -> float:
	return value

	
func _can_change_emission_angle_filter_attenuation_db(value: float) -> float:
	return value

	
func _can_change_attenuation_model(value: AudioStreamPlayer3D.AttenuationModel) -> AudioStreamPlayer3D.AttenuationModel:
	return value

	
func _can_change_attenuation_filter_cutoff_hz(value: int) -> int:
	return value

	
func _can_change_attenuation_filter_db(value: float) -> float:
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
	clipper_ignore_time_scale = _can_change_clipper_ignore_time_scale(clipper_ignore_time_scale)

	if _stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		_stream.loop = loop
#endregion *****************************************************************************************
