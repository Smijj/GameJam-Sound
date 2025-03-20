@tool
extends EditorPlugin

var _Dock: Node
var AUTOLOAD_NAME: String = "AudioManager"

var dicTest:Dictionary

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://Addons/audiomanager/AudioManager.gd")
	
	# Load the dock scene and instantiate it.
	_Dock = preload("res://Addons/audiomanager/audio_manger_dock.tscn").instantiate()
 	#Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _Dock)

func _exit_tree() -> void:
	# Remove the dock.
	remove_control_from_docks(_Dock)
	# Erase the control from the memory.
	_Dock.free()
	
	remove_autoload_singleton(AUTOLOAD_NAME)
	
