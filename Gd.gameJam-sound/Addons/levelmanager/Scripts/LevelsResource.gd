@tool
class_name LevelsResource
extends Resource

@export_tool_button("Reset Save Data", "Callable") var reset_action:Callable = _ResetSavedData
@export var Levels: Array[LevelData] = []

func _ResetSavedData() -> void:
	if Levels.is_empty(): return
	for level:LevelData in Levels:
		level.Completed = false
		level.PersonalCompleteTime = -1
		level.Collectables.clear()
		ResourceSaver.save(level)
	print("Reset Saved Data")
