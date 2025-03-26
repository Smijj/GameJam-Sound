extends FocusButton

@export var _MenuName: String = ""

func _pressed() -> void:
	MenuManager.OpenMenu(_MenuName)
