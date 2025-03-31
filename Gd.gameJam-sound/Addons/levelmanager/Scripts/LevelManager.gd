extends Node

signal OnLevelLoaded
signal OnLevelComplete
signal OnLevelQuit

var _LevelsResource: LevelsResource = preload("res://Addons/levelmanager/LevelsResource.tres")

var CurrentLevelData: LevelData = null
var _CurrentLevel: LevelCtrl = null

func SaveLevelData() -> void:
	if CurrentLevelData: ResourceSaver.save(CurrentLevelData)
	if _LevelsResource: ResourceSaver.save(_LevelsResource)

func LoadLevel(levelData: LevelData) -> void:
	if !levelData || !levelData.PackedLevel: return
	
	# Removes any active level is there is already one open
	if _CurrentLevel: 
		_StopLevel()
		await _CurrentLevel.tree_exited	# Waits for the level to be deleted before continuing
	
	_CurrentLevel = levelData.PackedLevel.instantiate() as LevelCtrl
	CurrentLevelData = levelData
	add_child(_CurrentLevel)
	
	OnLevelLoaded.emit()

func RestartLevel() -> void:
	if !CurrentLevelData: return
	LoadLevel(CurrentLevelData)

func CompleteLevel() -> void:
	OnLevelComplete.emit()
	_StopLevel()

func QuitLevel() -> void:
	OnLevelQuit.emit()
	_StopLevel()

func _StopLevel() -> void:
	if !_CurrentLevel: return
	_CurrentLevel.queue_free()
	CurrentLevelData = null
