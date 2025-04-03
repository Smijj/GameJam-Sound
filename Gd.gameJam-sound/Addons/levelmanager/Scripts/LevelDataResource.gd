class_name LevelData
extends Resource

@export var PackedLevel: PackedScene

@export_category("Settings")
@export var LevelName: String = "Level"

@export_category("Data")
@export var Completed: bool = false
@export var PersonalCompleteTime: float = -1
@export var Collectables: Dictionary[NodePath, bool] = {}

func CurrentCollectedCount() -> int:
	var collectedCount: int = 0
	for collectable:bool in Collectables.values():
		if collectable == true: collectedCount += 1
	return collectedCount

func TotalCollectables() -> int:
	return Collectables.size()
