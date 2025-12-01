@tool
@icon("res://addons/audio_manager/icons/icon.svg")

## Audio Manager is the node that manages all the audio in your game, both omnidirectional audio (AudioStreamPlayer) and 2D and 3D audio (AudioStreamPlayer2D and 3D, respectively).
class_name AudioManager extends Node


#region EXPORTS ************************************************************************************
@export_category("Audios Plus")
## Inserts omnidirectional audio files (AudioStreamPlus) in AudioManagerPlus format. 
## This is an array of AudioManagerPlus files; to insert via code use $AudioManager.add_plus("audio_name", audio_manager_plus) and to remove use $AudioManager.remove_plus("audio_name").
@export var audios_plus: Array[AudioManagerPlus]:
	set(value):
		audios_plus = value
		for audio in audios_plus:
			if audio:
				audio._init_owner(self)
		update_configuration_warnings()


@export_category("Audios Plus 2D")
## This is the parent node for the 2D audio files in the scene. Select a Node2D to be the parent of the audio files. 
## If you don't select this, the audio files will be created in the AudioManager parent node.
@export var parent_2d: Node2D:
	set(value):
		parent_2d = value
		_reparent_2d()

## Inserts 2d audio files (AudioStreamPlus2D) in AudioManagerPlus2D format. 
## This is an array of AudioManagerPlus2D files; to insert via code use $AudioManager.add_plus2d("audio_name", audio_manager_plus_2d) and to remove use $AudioManager.remove_plus2d("audio_name").	
@export var audios_plus2d: Array[AudioManagerPlus2D]:
	set(value):
		audios_plus2d = value
		for audio in audios_plus2d:
			if audio:
				audio._init_owner(self)
		update_configuration_warnings()


@export_category("Audios Plus 3D")
## This is the parent node for the 3D audio files in the scene. Select a Node3D to be the parent of the audio files. 
## If you don't select this, the audio files will be created in the AudioManager parent node.
@export var parent_3d: Node3D:
	set(value):
		parent_3d = value
		_reparent_3d()

## Inserts 3d audio files (AudioStreamPlus3D) in AudioManagerPlus3D format. 
## This is an array of AudioManagerPlus3D files; to insert via code use $AudioManager.add_plus3d("audio_name", audio_manager_plus_3d) and to remove use $AudioManager.remove_plus3d("audio_name").	
@export var audios_plus3d: Array[AudioManagerPlus3D]:
	set(value):
		audios_plus3d = value
		for audio in audios_plus3d:
			if audio:
				audio._init_owner(self)
		update_configuration_warnings()
#endregion *****************************************************************************************


#region SIGNALS ************************************************************************************
## Emitted when a sound AudioStreamPlus finishes playing without interruptions. This signal is not emitted when calling stop(), or when exiting the tree while sounds are playing.
signal finished_plus(audio_name: String)
## Emitted when the sound AudioStreamPlus is looping and ends its playback cycle before repeating when the use_clipper option is true.
signal finished_plus_loop_in_clipper(audio_name: String)
## A signal is emitted every time the audio AudioStreamPlus is paused or unpaused when pause_onblur is activated (pause_onblur = true).
signal pause_unpause_changed_plus(audio_name: String, pause: bool)

## Emitted when a sound AudioStreamPlus finishes playing without interruptions. This signal is not emitted when calling stop(), or when exiting the tree while sounds are playing.
signal finished_plus2d(audio_name: String)
## Emitted when the sound AudioStreamPlus is looping and ends its playback cycle before repeating when the use_clipper option is true.
signal finished_plus2d_loop_in_clipper(audio_name: String)
## A signal is emitted every time the audio AudioStreamPlus is paused or unpaused when pause_onblur is activated (pause_onblur = true).
signal pause_unpause_changed_plus2d(audio_name: String, pause: bool)

## Emitted when a sound AudioStreamPlus finishes playing without interruptions. This signal is not emitted when calling stop(), or when exiting the tree while sounds are playing.
signal finished_plus3d(audio_name: String)
## Emitted when the sound AudioStreamPlus is looping and ends its playback cycle before repeating when the use_clipper option is true.
signal finished_plus3d_loop_in_clipper(audio_name: String)
## A signal is emitted every time the audio AudioStreamPlus is paused or unpaused when pause_onblur is activated (pause_onblur = true).
signal pause_unpause_changed_plus3d(audio_name: String, pause: bool)
#endregion *****************************************************************************************


#region ENGINE METHODS *****************************************************************************
func _ready():
	_reparent_2d()
	_reparent_3d()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	_warnings_plus(warnings)
	_warnings_plus2d(warnings)
	_warnings_plus3d(warnings)
	return warnings
#endregion *****************************************************************************************


#region PRIVATE METHODS ****************************************************************************
func _reparent_2d() -> void:
	if not is_node_ready(): await ready
	for audio in audios_plus2d:
		if audio:
			var a := audio.get_audio_plus()
			if parent_2d:
				if a.get_parent() and a.get_parent() != parent_2d:
					a.reparent.call_deferred(parent_2d)
					await get_tree().process_frame
					a.position = Vector2.ZERO
			else:
				if a.get_parent() and a.get_parent() != self:
					a.reparent.call_deferred(self)
					await get_tree().process_frame
					a.position = Vector2.ZERO


func _reparent_3d() -> void:
	if not is_node_ready(): await ready
	for audio in audios_plus3d:
		if audio:
			var a := audio.get_audio_plus()
			if parent_3d:
				if a.get_parent() and a.get_parent() != parent_3d:
					a.reparent.call_deferred(parent_3d)
					await get_tree().process_frame
					a.position = Vector3.ZERO
			else:
				if a.get_parent() and a.get_parent() != self:
					a.reparent.call_deferred(self)
					await get_tree().process_frame
					a.position = Vector3.ZERO
#endregion *****************************************************************************************


#region AUDIO STREAM PLUS **************************************************************************
## Play the audio plus containing the given name.
func play_plus(audio_name: String, from_position: float = 0.0) -> void:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.play(from_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		

## Stop audio plus playback using the provided name.
func stop_plus(audio_name: String) -> void:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.stop()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		
		
## Pause audio plus playback using the provided name.
func pause_plus(audio_name: String) -> void:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.pause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Unpause audio plus playback using the provided name.
func unpause_plus(audio_name: String) -> void:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.unpause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Add an audio plus to the node tree.
func add_plus(audio_name: String, audio_plus: AudioManagerPlus) -> void:
	audio_plus.audio_name = audio_name
	audios_plus.append(audio_plus)
	audio_plus._init_owner(self)
	

## Remove the audio plus from the node tree.
func remove_plus(audio_name: String) -> bool:
	var find_index: int = find_plus_index(audio_name)
	if find_index > -1:
		var audio: AudioManagerPlus = audios_plus[find_index]
		if audio.get_audio_plus().is_inside_tree():
			audio._remove()
			audios_plus.remove_at(find_index)
			return true
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	return false
				
				
## Returns the audio plus with the name. If it is not found, it will return null.
func get_plus(audio_name: String) -> AudioStreamPlus:
	for audio in audios_plus:
		if audio:
			if audio.audio_name == audio_name:
				return audio.get_audio_plus()
	return null
	

## Returns all audio plus inserted into the scene.
func get_all_plus() -> Array[AudioStreamPlus]:
	var audios: Array[AudioStreamPlus] = []
	for audio in audios_plus:
		if audio:
			audios.append(audio.get_audio_plus())
	return audios


## Returns the index audio plus with the name. If it is not found, it will return -1.
func find_plus_index(audio_name: String) -> int:
	for i in range(audios_plus.size()):
		if audios_plus[i].audio_name == audio_name:
			return i
	return -1
	

## Check if the audio plus with that name exists.
func has_plus(audio_name: String) -> bool:
	for audio in audios_plus:
		if audio:
			if audio.audio_name == audio_name:
				return true
	return false


## Returns whether audio plus is currently playing or not.
func is_plus_playing(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.is_playing
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false
	
	
## Returns whether the audio plus is paused or not.
func is_plus_paused(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.is_paused
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Returns the stream size of audio plus without considering pitch scaling.
func get_plus_length(audio_name: String) -> float:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.get_length()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
## Note: The position is not always accurate, as the AudioServer does not mix audio every processed frame. To get more accurate results, add AudioServer.get_time_since_last_mix() to the returned position.
## Note: This method always returns 0.0 if the stream is an AudioStreamInteractive, since it can have multiple clips playing at once.
func get_plus_playback_position(audio_name: String) -> float:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.get_playback_position()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). If no sounds are playing, this method fails and returns an empty playback.
func get_plus_stream_playback(audio_name: String) -> AudioStreamPlayback:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.get_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return null


## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_plus_stream_playback(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.has_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_plus(audio_name: String, to_position: float) -> void:
	var find_audio: AudioStreamPlus = get_plus(audio_name)
	if find_audio:
		return find_audio.seek(to_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)


func _warnings_plus(warnings: PackedStringArray) -> void:
	for audio in audios_plus:
		if audio:
			var plus: AudioStreamPlus = audio.get_audio_plus()

			if audio.audio_name.strip_edges() == "":
				warnings.append("There are audio files in audios_plus with missing names. Consider giving each audio file a unique name.")

			if plus and not plus.stream:
				warnings.append("The 'stream' property needs to be defined in one of the audios_plus.")

			if plus and plus.use_clipper and plus.start_time >= plus.end_time:
				warnings.append("In one of the audios_plus, the 'start_time' property cannot be greater than or equal to the 'end_time' property. Change start_time or end_time so that they are different and end_time is greater than start_time.")
			
			if plus and plus.bus.strip_edges() == "":
				warnings.append("In one of the audios_plus, the 'bus' property cannot be empty or null. Consider setting a valid value or the default value 'Master'.")

			if plus and AudioServer.get_bus_index(plus.bus) == -1:
				warnings.append("In one of the audios_plus, the property 'bus' has an invalid value. The value '%s' does not exist. Consider using an existing value or use the default value 'Master'."%plus.bus)

			if plus and plus.use_clipper and plus._current_stream and plus.end_time > plus.get_length():
				warnings.append("In one of the audios_plus, the end_time property cannot be larger than the size of the audio track. Consider placing the end_time value within the audio track.")

			for audio2 in audios_plus:
				if audio2:
					if audio != audio2 and audio.audio_name == audio2.audio_name:
						warnings.append("There are duplicate names in audios_plus. Consider giving each audio a unique name.")
		else:
			warnings.append("You added a new audio file to audios_plus but haven't finished configuring it. Consider completing the configuration or remove it if you won't be using it.")

#endregion *****************************************************************************************


#region AUDIO STREAM PLUS 2D ***********************************************************************
## Play the audio plus2d containing the given name.
func play_plus2d(audio_name: String, from_position: float = 0.0) -> void:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.play(from_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		

## Stop audio plus2d playback using the provided name.
func stop_plus2d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.stop()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		
		
## Pause audio plus2d playback using the provided name.
func pause_plus2d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.pause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Unpause audio plus2d playback using the provided name.
func unpause_plus2d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.unpause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Add an audio plus2d to the node tree.
func add_plus2d(audio_name: String, audio_plus2d: AudioManagerPlus2D) -> void:
	audio_plus2d.audio_name = audio_name
	audios_plus2d.append(audio_plus2d)
	audio_plus2d._init_owner(self)
	

## Remove the audio plus2d from the node tree.
func remove_plus2d(audio_name: String) -> bool:
	var find_index: int = find_plus2d_index(audio_name)
	if find_index > -1:
		var audio: AudioManagerPlus2D = audios_plus2d[find_index]
		if audio.get_audio_plus().is_inside_tree():
			audio._remove()
			audios_plus2d.remove_at(find_index)
			return true
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	return false
				
				
## Returns the audio plus2d with the name. If it is not found, it will return null.
func get_plus2d(audio_name: String) -> AudioStreamPlus2D:
	for audio in audios_plus2d:
		if audio:
			if audio.audio_name == audio_name:
				return audio.get_audio_plus()
	return null
	

## Returns all audio plus2d inserted into the scene.
func get_all_plus2d() -> Array[AudioStreamPlus2D]:
	var audios: Array[AudioStreamPlus2D] = []
	for audio in audios_plus2d:
		if audio:
			audios.append(audio.get_audio_plus())
	return audios


## Returns the index audio plus2d with the name. If it is not found, it will return -1.
func find_plus2d_index(audio_name: String) -> int:
	for i in range(audios_plus2d.size()):
		if audios_plus2d[i].audio_name == audio_name:
			return i
	return -1
	

## Check if the audio plus2d with that name exists.
func has_plus2d(audio_name: String) -> bool:
	for audio in audios_plus2d:
		if audio:
			if audio.audio_name == audio_name:
				return true
	return false


## Returns whether audio plus2d is currently playing or not.
func is_plus2d_playing(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.is_playing
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false
	
	
## Returns whether the audio plus2d is paused or not.
func is_plus2d_paused(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.is_paused
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Returns the stream size of audio plus2d without considering pitch scaling.
func get_plus2d_length(audio_name: String) -> float:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.get_length()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
## Note: The position is not always accurate, as the AudioServer does not mix audio every processed frame. To get more accurate results, add AudioServer.get_time_since_last_mix() to the returned position.
## Note: This method always returns 0.0 if the stream is an AudioStreamInteractive, since it can have multiple clips playing at once.
func get_plus2d_playback_position(audio_name: String) -> float:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.get_playback_position()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). If no sounds are playing, this method fails and returns an empty playback.
func get_plus2d_stream_playback(audio_name: String) -> AudioStreamPlayback:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.get_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return null


## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_plus2d_stream_playback(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.has_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_plus2d(audio_name: String, to_position: float) -> void:
	var find_audio: AudioStreamPlus2D = get_plus2d(audio_name)
	if find_audio:
		return find_audio.seek(to_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)


func _warnings_plus2d(warnings: PackedStringArray) -> void:
	for audio in audios_plus2d:
		if audio:
			var plus: AudioStreamPlus2D = audio.get_audio_plus()
			
			if audio.audio_name.strip_edges() == "":
				warnings.append("There are audio files in audios_plus2d with missing names. Consider giving each audio file a unique name.")

			if plus and not plus.stream:
				warnings.append("The 'stream' property needs to be defined in one of the audios_plus2d.")

			if plus and plus.use_clipper and plus.start_time >= plus.end_time:
				warnings.append("In one of the audios_plus2d, the 'start_time' property cannot be greater than or equal to the 'end_time' property. Change start_time or end_time so that they are different and end_time is greater than start_time.")
			
			if plus and plus.bus.strip_edges() == "":
				warnings.append("In one of the audios_plus2d, the 'bus' property cannot be empty or null. Consider setting a valid value or the default value 'Master'.")

			if plus and AudioServer.get_bus_index(plus.bus) == -1:
				warnings.append("In one of the audios_plus2d, the property 'bus' has an invalid value. The value '%s' does not exist. Consider using an existing value or use the default value 'Master'."%plus.bus)

			if plus and plus.use_clipper and plus._current_stream and plus.end_time > plus.get_length():
				warnings.append("In one of the audios_plus2d, the end_time property cannot be larger than the size of the audio track. Consider placing the end_time value within the audio track.")

			for audio2 in audios_plus2d:
				if audio2:
					if audio != audio2 and audio.audio_name == audio2.audio_name:
						warnings.append("There are duplicate names in audios_plus2d. Consider giving each audio a unique name.")
		else:
			warnings.append("You added a new audio file to audios_plus2d but haven't finished configuring it. Consider completing the configuration or remove it if you won't be using it.")

#endregion *****************************************************************************************


#region AUDIO STREAM PLUS 3D ***********************************************************************
## Play the audio plus3d containing the given name.
func play_plus3d(audio_name: String, from_position: float = 0.0) -> void:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.play(from_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		

## Stop audio plus3d playback using the provided name.
func stop_plus3d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.stop()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		
		
## Pause audio plus3d playback using the provided name.
func pause_plus3d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.pause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Unpause audio plus3d playback using the provided name.
func unpause_plus3d(audio_name: String) -> void:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree():
			push_error("The audio is not included in the node tree. If you have added it, consider using `call_deferred` to schedule it for the next fame.")
			return
		find_audio.unpause()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	
	
## Add an audio plus3d to the node tree.
func add_plus3d(audio_name: String, audio_plus3d: AudioManagerPlus3D) -> void:
	audio_plus3d.audio_name = audio_name
	audios_plus3d.append(audio_plus3d)
	audio_plus3d._init_owner(self)
	

## Remove the audio plus3d from the node tree.
func remove_plus3d(audio_name: String) -> bool:
	var find_index: int = find_plus3d_index(audio_name)
	if find_index > -1:
		var audio: AudioManagerPlus3D = audios_plus3d[find_index]
		if audio.get_audio_plus().is_inside_tree():
			audio._remove()
			audios_plus3d.remove_at(find_index)
			return true
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
	return false
				
				
## Returns the audio plus3d with the name. If it is not found, it will return null.
func get_plus3d(audio_name: String) -> AudioStreamPlus3D:
	for audio in audios_plus3d:
		if audio:
			if audio.audio_name == audio_name:
				return audio.get_audio_plus()
	return null
	

## Returns all audio plus3d inserted into the scene.
func get_all_plus3d() -> Array[AudioStreamPlus3D]:
	var audios: Array[AudioStreamPlus3D] = []
	for audio in audios_plus3d:
		if audio:
			audios.append(audio.get_audio_plus())
	return audios


## Returns the index audio plus3d with the name. If it is not found, it will return -1.
func find_plus3d_index(audio_name: String) -> int:
	for i in range(audios_plus3d.size()):
		if audios_plus3d[i].audio_name == audio_name:
			return i
	return -1
	

## Check if the audio plus3d with that name exists.
func has_plus3d(audio_name: String) -> bool:
	for audio in audios_plus3d:
		if audio:
			if audio.audio_name == audio_name:
				return true
	return false


## Returns whether audio plus3d is currently playing or not.
func is_plus3d_playing(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.is_playing
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false
	
	
## Returns whether the audio plus3d is paused or not.
func is_plus3d_paused(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.is_paused
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Returns the stream size of audio plus3d without considering pitch scaling.
func get_plus3d_length(audio_name: String) -> float:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.get_length()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
## Note: The position is not always accurate, as the AudioServer does not mix audio every processed frame. To get more accurate results, add AudioServer.get_time_since_last_mix() to the returned position.
## Note: This method always returns 0.0 if the stream is an AudioStreamInteractive, since it can have multiple clips playing at once.
func get_plus3d_playback_position(audio_name: String) -> float:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.get_playback_position()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return 0.0


## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). If no sounds are playing, this method fails and returns an empty playback.
func get_plus3d_stream_playback(audio_name: String) -> AudioStreamPlayback:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.get_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return null


## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_plus3d_stream_playback(audio_name: String) -> bool:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.has_stream_playback()
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)
		return false


## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_plus3d(audio_name: String, to_position: float) -> void:
	var find_audio: AudioStreamPlus3D = get_plus3d(audio_name)
	if find_audio:
		return find_audio.seek(to_position)
	else:
		push_warning("Audio with the name %s not found. Please check the name correctly."%audio_name)


func _warnings_plus3d(warnings: PackedStringArray) -> void:
	for audio in audios_plus3d:
		if audio:
			var plus: AudioStreamPlus3D = audio.get_audio_plus()
			
			if audio.audio_name.strip_edges() == "":
				warnings.append("There are audio files in audios_plus3d with missing names. Consider giving each audio file a unique name.")

			if plus and not plus.stream:
				warnings.append("The 'stream' property needs to be defined in one of the audios_plus3d.")

			if plus and plus.use_clipper and plus.start_time >= plus.end_time:
				warnings.append("In one of the audios_plus3d, the 'start_time' property cannot be greater than or equal to the 'end_time' property. Change start_time or end_time so that they are different and end_time is greater than start_time.")
			
			if plus and plus.bus.strip_edges() == "":
				warnings.append("In one of the audios_plus3d, the 'bus' property cannot be empty or null. Consider setting a valid value or the default value 'Master'.")

			if plus and AudioServer.get_bus_index(plus.bus) == -1:
				warnings.append("In one of the audios_plus3d, the property 'bus' has an invalid value. The value '%s' does not exist. Consider using an existing value or use the default value 'Master'."%plus.bus)

			if plus and plus.use_clipper and plus._current_stream and plus.end_time > plus.get_length():
				warnings.append("In one of the audios_plus3d, the end_time property cannot be larger than the size of the audio track. Consider placing the end_time value within the audio track.")

			for audio2 in audios_plus3d:
				if audio2:
					if audio != audio2 and audio.audio_name == audio2.audio_name:
						warnings.append("There are duplicate names in audios_plus3d. Consider giving each audio a unique name.")
		else:
			warnings.append("You added a new audio file to audios_plus3d but haven't finished configuring it. Consider completing the configuration or remove it if you won't be using it.")

#endregion *****************************************************************************************
