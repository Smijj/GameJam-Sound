@tool
extends EditorPlugin

var AUTOLOAD_NAME: String = "StateManager"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://Addons/statemanager/Scripts/StateManager.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
