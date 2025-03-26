class_name FocusButton 
extends Button

@export var _FocusFirst:bool = false

func _ready() -> void:
	if (_FocusFirst):
		visibility_changed.connect(_OnVisibilityChanged)
		grab_focus()

func _OnVisibilityChanged() -> void:
	if visible == false: return
	grab_focus()
