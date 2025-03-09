@tool
extends EditorPlugin

var icon_omni = preload("res://addons/audio_manager/images/icon-omni-16x16.png")
var icon_2d = preload("res://addons/audio_manager/images/icon-2d-16x16.png")
var icon_3d = preload("res://addons/audio_manager/images/icon-3d-16x16.png")

var main_script = preload("res://addons/audio_manager/audio_manager.gd")

var audio_manager_omni = preload("res://addons/audio_manager/audio_manager_omni.gd")
var audio_manager_2d = preload("res://addons/audio_manager/audio_manager_2d.gd")
var audio_manager_3d = preload("res://addons/audio_manager/audio_manager_3d.gd")


func _enter_tree() -> void:
	add_custom_type("AudioManager", "Node", main_script, icon_omni)
	add_custom_type("AudioManger1D", "Resource", audio_manager_omni, icon_omni)
	add_custom_type("AudioManger2D", "Resource", audio_manager_2d, icon_2d)
	add_custom_type("AudioManger3D", "Resource", audio_manager_3d, icon_3d)
	pass


func _exit_tree() -> void:
	remove_custom_type("AudioManager")
	remove_custom_type("AudioManger1D")
	remove_custom_type("AudioManger2D")
	remove_custom_type("AudioManger3D")
	pass
