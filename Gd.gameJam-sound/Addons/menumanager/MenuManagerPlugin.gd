@tool
extends EditorPlugin

var AUTOLOAD_NAME: String = "MenuManager"

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://Addons/menumanager/Scripts/MenuManager.gd")
	
func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
