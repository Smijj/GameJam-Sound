@tool
class_name LevelsResource
extends Resource

@export_tool_button("Save Data", "Callable") var save_action:Callable = _SaveData
@export_tool_button("CLEAR Saved Data", "Callable") var reset_action:Callable = _ResetSavedData
@export var Levels: Array[LevelData] = []

func _ResetSavedData() -> void:
	if Levels.is_empty(): return
	for level:LevelData in Levels:
		level.Completed = false
		level.PersonalCompleteTime = -1
		level.Collectables.clear()
		ResourceSaver.save(level)
	print("CLEARED Save Data")

func _SaveData() -> void:
	if Levels.is_empty(): return
	for level:LevelData in Levels:
		ResourceSaver.save(level)
	
	print("Saved Data")
