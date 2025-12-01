@tool
extends EditorPlugin


var icon = preload("res://addons/audio_manager/icons/icon.svg")
var script_main = preload("res://addons/audio_manager/audio_manager.gd")

var icon_plus = preload("res://addons/audio_manager/icons/audio_stream_plus_res.svg")
var icon_plus_2d = preload("res://addons/audio_manager/icons/audio_stream_plus_2d_res.svg")
var icon_plus_3d = preload("res://addons/audio_manager/icons/audio_stream_plus_3d_res.svg")


var script_plus = preload("res://addons/audio_manager/resources_class/audio_manager_plus.gd")
var script_plus_2d = preload("res://addons/audio_manager/resources_class/audio_manager_plus_2d.gd")
var script_plus_3d = preload("res://addons/audio_manager/resources_class/audio_manager_plus_3d.gd")


func _enable_plugin() -> void:
	add_custom_type("AudioManager", "Node", script_main, icon)
	add_custom_type("AudioManagerPlus", "Resource", script_plus, icon_plus)
	add_custom_type("AudioManagerPlus2D", "Resource", script_plus_2d, icon_plus_2d)
	add_custom_type("AudioManagerPlus3D", "Resource", script_plus_3d, icon_plus_3d)
	pass


func _disable_plugin() -> void:
	remove_custom_type("AudioManager")
	remove_custom_type("AudioManagerPlus")
	remove_custom_type("AudioManagerPlus2D")
	remove_custom_type("AudioManagerPlus3D")
	pass
