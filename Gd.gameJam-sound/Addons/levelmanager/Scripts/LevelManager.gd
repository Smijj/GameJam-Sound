extends Node

signal OnLevelLoaded
signal OnLevelComplete
signal OnLevelQuit

var CurrentLevelData: LevelData = null
var _CurrentLevel: LevelCtrl = null

func LoadLevel(levelData: LevelData) -> void:
	if !levelData || !levelData.PackedLevel: return
	
	if _CurrentLevel: _StopLevel(true)
		
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

func _StopLevel(immediate:bool = false) -> void:
	if !_CurrentLevel: return
	if immediate:
		_CurrentLevel.free()
	else:
		_CurrentLevel.queue_free()
	
	CurrentLevelData = null
