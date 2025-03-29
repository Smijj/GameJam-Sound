@tool
extends EditorPlugin

var AUTOLOAD_NAME: String = "LevelManager"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://Addons/levelmanager/Scripts/LevelManager.gd")
	
func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
