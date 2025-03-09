class_name AudioManager extends Node3D


enum AudioTypeEnum {ONE_D, TWO_D, THREE_D}


@export_group("Audio Manager")
@export var audios_1d: Array[AudioManger1D] = []
@export var audios_2d: Array[AudioManger2D] = []
@export var audios_3d: Array[AudioManger3D] = []


var audios_manager_controller_1d: Dictionary = {}
var audios_manager_controller_2d: Dictionary = {}
var audios_manager_controller_3d: Dictionary = {}


func _ready() -> void:
	_init_audios_1d()
	_init_audios_2d()
	_init_audios_3d()
	pass


## Play audio by name
func play_audio(_audio_name: String, _type: AudioTypeEnum) -> void:
	var audio = _validate_audio_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _validate_audio_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _validate_audio_2d(_audio_name)
	if not audio:
		return
		
	if float(audio.duration) <= 0.0:
		return

	var timer: Timer = _setup_timer_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _setup_timer_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _setup_timer_2d(_audio_name)

	if audio.use_clipper:
		audio.play(audio.start_time)
	else:
		audio.play()

	timer.start()
	pass


## Pause audio by name
func pause_audio(_audio_name: String, _type: AudioTypeEnum) -> void:
	var audio = _validate_audio_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _validate_audio_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _validate_audio_2d(_audio_name)
	if not audio or audio.stream_paused:
		return

	var timer: Timer = _setup_timer_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _setup_timer_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _setup_timer_2d(_audio_name)
	audio.stream_paused = true
	audio.time_remain = timer.time_left
	timer.stop()
	pass


## Continue audio by name
func continue_audio(_audio_name: String, _type: AudioTypeEnum) -> void:
	var audio = _validate_audio_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _validate_audio_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _validate_audio_2d(_audio_name)
	if not audio or not audio.stream_paused:
		return

	var timer: Timer = _setup_timer_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _setup_timer_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _setup_timer_2d(_audio_name)
	audio.stream_paused = false
	timer.start(audio.time_remain)
	pass


## Stop audio by name
func stop_audio(_audio_name: String, _type: AudioTypeEnum) -> void:
	var audio = _validate_audio_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _validate_audio_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _validate_audio_2d(_audio_name)
	if not audio or not audio.playing:
		return
	
	var timer: Timer = _setup_timer_3d(_audio_name) if _type == AudioTypeEnum.THREE_D else _setup_timer_1d(_audio_name) if _type == AudioTypeEnum.ONE_D else _setup_timer_2d(_audio_name)
	
	timer.stop()
	audio.stop()
	pass


## Play all audios
func play_all() -> void:
	for a in audios_1d:
		play_audio(a.audio_name, AudioTypeEnum.ONE_D)
		
	for a in audios_2d:
		play_audio(a.audio_name, AudioTypeEnum.TWO_D)
		
	for a in audios_3d:
		play_audio(a.audio_name, AudioTypeEnum.THREE_D)
	pass


## Stop all audios
func stop_all() -> void:
	for a in audios_1d:
		stop_audio(a.audio_name, AudioTypeEnum.ONE_D)
		
	for a in audios_2d:
		stop_audio(a.audio_name, AudioTypeEnum.TWO_D)
		
	for a in audios_3d:
		stop_audio(a.audio_name, AudioTypeEnum.THREE_D)
	pass


## Pause all audios
func pause_all() -> void:
	for a in audios_1d:
		pause_audio(a.audio_name, AudioTypeEnum.ONE_D)
	
	for a in audios_2d:
		pause_audio(a.audio_name, AudioTypeEnum.TWO_D)
	
	for a in audios_3d:
		pause_audio(a.audio_name, AudioTypeEnum.THREE_D)
	pass


## Continue all audios
func continue_all() -> void:
	for a in audios_1d:
		continue_audio(a.audio_name, AudioTypeEnum.ONE_D)
		
	for a in audios_2d:
		continue_audio(a.audio_name, AudioTypeEnum.TWO_D)
		
	for a in audios_3d:
		continue_audio(a.audio_name, AudioTypeEnum.THREE_D)
	pass


## Get audio 3D (AudioManger3D)
func get_audio_3d(_audio_name: String) -> AudioManger3D:
	for aud in audios_3d:
		if aud.audio_name == _audio_name:
			return aud
	push_warning("AudioManger3D %s not find."%_audio_name)
	return null
	
	
## Get audio 1D (AudioManger1D)
func get_audio_1d(_audio_name: String) -> AudioManger1D:
	for aud in audios_1d:
		if aud.audio_name == _audio_name:
			return aud
	push_warning("AudioManger1D %s not find."%_audio_name)
	return null
	
	
## Get audio 2D (AudioManger2D)
func get_audio_2d(_audio_name: String) -> AudioManger2D:
	for aud in audios_2d:
		if aud.audio_name == _audio_name:
			return aud
	push_warning("AudioManger2D %s not find."%_audio_name)
	return null


## Init audios instances
func _init_audios_1d() -> void:
	for audio_1d in audios_1d:
		if not _check_audio(audio_1d):
			continue
		_warning_audio(audio_1d)

		var new_audio_manager_controller_1d: AudioManagerController1D = AudioManagerController1D.new(
			audio_1d.start_time, audio_1d.duration, audio_1d.use_clipper, audio_1d.loop, 0.0, false
			)
		
		audio_1d._owner = new_audio_manager_controller_1d
		_setup_audio_properties_1d(new_audio_manager_controller_1d, audio_1d)
		audios_manager_controller_1d[audio_1d.audio_name] = new_audio_manager_controller_1d
		add_child(new_audio_manager_controller_1d)

		if audio_1d.duration > 0 and audio_1d.auto_play:
			play_audio(audio_1d.audio_name, AudioTypeEnum.ONE_D)
	pass


func _init_audios_2d() -> void:
	for audio_2d in audios_2d:
		if not _check_audio(audio_2d):
			continue
		_warning_audio(audio_2d)

		var new_audio_manager_controller_2d: AudioManagerController2D = AudioManagerController2D.new(
			audio_2d.start_time, audio_2d.duration, audio_2d.use_clipper, audio_2d.loop, 0.0, false
			)
		
		audio_2d._owner = new_audio_manager_controller_2d
		_setup_audio_properties_2d(new_audio_manager_controller_2d, audio_2d)
		audios_manager_controller_2d[audio_2d.audio_name] = new_audio_manager_controller_2d
		add_child(new_audio_manager_controller_2d)

		if audio_2d.duration > 0 and audio_2d.auto_play:
			play_audio(audio_2d.audio_name, AudioTypeEnum.TWO_D)
	pass
	
	
func _init_audios_3d() -> void:
	for audio_3d in audios_3d:
		if not _check_audio(audio_3d):
			continue
		_warning_audio(audio_3d)

		var new_audio_manager_controller_3d: AudioManagerController3D = AudioManagerController3D.new(
			audio_3d.start_time, audio_3d.duration, audio_3d.use_clipper, audio_3d.loop, 0.0, false
			)
		
		audio_3d._owner = new_audio_manager_controller_3d
		_setup_audio_properties_3d(new_audio_manager_controller_3d, audio_3d)
		audios_manager_controller_3d[audio_3d.audio_name] = new_audio_manager_controller_3d
		add_child(new_audio_manager_controller_3d)

		if audio_3d.duration > 0 and audio_3d.auto_play:
			play_audio(audio_3d.audio_name, AudioTypeEnum.THREE_D)
	pass
	
	
func _setup_audio_properties_1d(audio: AudioStreamPlayer, a: AudioManger1D) -> void:
	audio.stream = a.audio_stream
	audio.volume_db = a.volume_db
	audio.pitch_scale = a.pitch_scale
	audio.mix_target = a.mix_target
	audio.max_polyphony = a.max_polyphony
	pass
	

func _setup_audio_properties_2d(audio: AudioStreamPlayer2D, a: AudioManger2D) -> void:
	audio.stream = a.audio_stream
	audio.volume_db = a.volume_db
	audio.pitch_scale = a.pitch_scale
	audio.max_distance = a.max_distance
	audio.max_polyphony = a.max_polyphony
	audio.panning_strength = a.panning_strength
	pass


func _setup_audio_properties_3d(audio: AudioStreamPlayer3D, a: AudioManger3D) -> void:
	audio.stream = a.audio_stream
	audio.volume_db = a.volume_db
	audio.max_db = a.max_db
	audio.pitch_scale = a.pitch_scale
	audio.max_distance = a.max_distance
	audio.unit_size = a.unit_size
	audio.max_polyphony = a.max_polyphony
	audio.panning_strength = a.panning_strength
	pass
	

func _validate_audio_3d(_audio_name: String) -> AudioManagerController3D:
	var audio = _get_audio_controller_3d(_audio_name)
	if not audio:
		push_warning("AudioManger3D name (%s) not found." % _audio_name)
	return audio
	
	
func _validate_audio_1d(_audio_name: String) -> AudioManagerController1D:
	var audio = _get_audio_controller_1d(_audio_name)
	if not audio:
		push_warning("AudioManger1D name (%s) not found." % _audio_name)
	return audio
	
	
func _validate_audio_2d(_audio_name: String) -> AudioManagerController2D:
	var audio = _get_audio_controller_2d(_audio_name)
	if not audio:
		push_warning("AudioManger2D name (%s) not found." % _audio_name)
	return audio


func _setup_timer_1d(_audio_name: String) -> Timer:
	var audio = _get_audio_controller_1d(_audio_name) as AudioManagerController1D
	audio.timer.one_shot = not audio.loop
	audio.timer.wait_time = max(audio.duration, 0.00001)
	if not audio.is_timer_connected:
		audio.timer.timeout.connect(Callable(_on_timer_timeout_1d).bind(audio, _audio_name, func(): play_audio(_audio_name, AudioTypeEnum.ONE_D)))
		audio.is_timer_connected = true
	return audio.timer
	

func _setup_timer_2d(_audio_name: String) -> Timer:
	var audio = _get_audio_controller_2d(_audio_name) as AudioManagerController2D
	audio.timer.one_shot = not audio.loop
	audio.timer.wait_time = max(audio.duration, 0.00001)
	if not audio.is_timer_connected:
		audio.timer.timeout.connect(Callable(_on_timer_timeout_2d).bind(audio, _audio_name, func(): play_audio(_audio_name, AudioTypeEnum.TWO_D)))
		audio.is_timer_connected = true
	return audio.timer
	

func _setup_timer_3d(_audio_name: String) -> Timer:
	var audio = _get_audio_controller_3d(_audio_name) as AudioManagerController3D
	audio.timer.one_shot = not audio.loop
	audio.timer.wait_time = max(audio.duration, 0.00001)
	if not audio.is_timer_connected:
		audio.timer.timeout.connect(Callable(_on_timer_timeout_3d).bind(audio, _audio_name, func(): play_audio(_audio_name, AudioTypeEnum.THREE_D)))
		audio.is_timer_connected = true
	return audio.timer


func _on_timer_timeout_1d(_audio: AudioManagerController1D, _audio_name: String, cb: Callable) -> void:
	if _audio.loop:
		cb.call()
	else:
		_audio.stop()
	pass


func _on_timer_timeout_2d(_audio: AudioManagerController2D, _audio_name: String, cb: Callable) -> void:
	if _audio.loop:
		cb.call()
	else:
		_audio.stop()
	pass
	
	
func _on_timer_timeout_3d(_audio: AudioManagerController3D, _audio_name: String, cb: Callable) -> void:
	if _audio.loop:
		cb.call()
	else:
		_audio.stop()
	pass


func _get_audio_controller_1d(_audio_name: String) -> AudioManagerController1D:
	return audios_manager_controller_1d.get(_audio_name, null) as AudioManagerController1D


func _get_audio_controller_2d(_audio_name: String) -> AudioManagerController2D:
	return audios_manager_controller_2d.get(_audio_name, null) as AudioManagerController2D


func _get_audio_controller_3d(_audio_name: String) -> AudioManagerController3D:
	return audios_manager_controller_3d.get(_audio_name, null) as AudioManagerController3D


func _warning_audio(_audio: Variant) -> void:
	if not _audio.audio_stream:
		push_warning("The STREAM property cannot be null. (%s)" % _audio.audio_name)
	if _audio.duration <= 0.0:
		push_warning("AudioManger duration cannot be less than or equal to zero. Check START_TIME, END_TIME. (%s)" % _audio.audio_name)
	if _audio.use_clipper and _audio.start_time > _audio.end_time:
		push_warning("Start time cannot be greater than end time in AudioMangerResource resource: (%s)" % _audio.audio_name)
	pass
	
	
func _check_audio(_audio: Variant) -> bool:
	if not _audio or not _audio.audio_stream:
		push_warning("AudioManger resource or its stream is not properly defined.")
		return false
	if _audio.start_time > _audio.end_time:
		push_warning("AudioManger start time cannot be greater than end time for '%s'. AudioMangerResource deleted from ManagerList." % _audio.audio_name)
		return false
	return true
	
	
#*****************************************************************************
class AudioManagerController1D extends AudioStreamPlayer:
	var timer: Timer
	var start_time: float
	var duration: float
	var use_clipper: bool
	var loop: bool:
		set(value):
			loop = value
			if (!loop and !timer.is_stopped()):
				timer.stop()
		
	var time_remain: float
	var is_timer_connected: bool
	
	func _init(_start_time: float, _duration: float, _use_clipper: bool, _loop: bool, _time_remain: float, _is_timer_connected: bool) -> void:
		timer = Timer.new()
		timer.name = "timer"
		add_child(timer)
		
		self.start_time = _start_time
		self.duration = _duration
		self.use_clipper = _use_clipper
		self.loop = _loop
		self.time_remain = _time_remain
		self.is_timer_connected = _is_timer_connected
		pass
	
	
#*****************************************************************************
class AudioManagerController2D extends AudioStreamPlayer2D:
	var timer: Timer
	var start_time: float
	var duration: float
	var use_clipper: bool
	var loop: bool:
		set(value):
			loop = value
			if (!loop and !timer.is_stopped()):
				timer.stop()
		
	var time_remain: float
	var is_timer_connected: bool

	func _init(_start_time: float, _duration: float, _use_clipper: bool, _loop: bool, _time_remain: float, _is_timer_connected: bool) -> void:
		timer = Timer.new()
		timer.name = "timer"
		add_child(timer)
		
		self.start_time = _start_time
		self.duration = _duration
		self.use_clipper = _use_clipper
		self.loop = _loop
		self.time_remain = _time_remain
		self.is_timer_connected = _is_timer_connected
		pass


#*******************************************************************
class AudioManagerController3D extends AudioStreamPlayer3D:
	var timer: Timer
	var start_time: float
	var duration: float
	var use_clipper: bool
	var loop: bool:
		set(value):
			loop = value
			if (!loop and !timer.is_stopped()):
				timer.stop()
		
	var time_remain: float
	var is_timer_connected: bool
	pass

	func _init(_start_time: float, _duration: float, _use_clipper: bool, _loop: bool, _time_remain: float, _is_timer_connected: bool) -> void:
		timer = Timer.new()
		timer.name = "timer"
		add_child(timer)
		
		self.start_time = _start_time
		self.duration = _duration
		self.use_clipper = _use_clipper
		self.loop = _loop
		self.time_remain = _time_remain
		self.is_timer_connected = _is_timer_connected
		pass
