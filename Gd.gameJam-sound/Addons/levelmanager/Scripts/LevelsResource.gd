@tool
class_name LevelsResource
extends Resource

@export_tool_button("CLEAR Saved Data", "Callable") var clear_action:Callable = ClearSavedData
@export_tool_button("Reset Defaults", "Callable") var reset_action:Callable = _ResetDefaults
@export var Levels: Array[LevelData] = []

func _ResetDefaults() -> void:
	if Levels.is_empty(): return
	for level:LevelData in Levels:
		level.Completed = false
		level.PersonalCompleteTime = -1
		level.Collectables = {}
		ResourceSaver.save(level)
	print("Reset Defaults")

func ClearSavedData() -> void:
	if Levels.is_empty(): return
	for level:LevelData in Levels:
		var path:String = "user://" + level.LevelName + ".tres"
		if !ResourceLoader.exists(path): continue
		DirAccess.remove_absolute(path)
		print("Removing ", path)

	print("CLEARED Saved Data")
