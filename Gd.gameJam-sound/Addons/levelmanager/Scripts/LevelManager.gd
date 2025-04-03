extends Node

signal OnLevelLoaded
signal OnLevelComplete
signal OnLevelQuit

const SAVE_PATH: String = "user://"

var _LevelsResource: LevelsResource = preload("res://Addons/levelmanager/LevelsResource.tres")

func _GetSavePath(levelData:LevelData) -> String:
	if !levelData: return ""
	return SAVE_PATH + str(levelData.LevelName) + ".tres"

var CurrentLevelData: LevelData = null :
	set (value):
		if !value || _GetSavePath(value) == "": return
		if !ResourceLoader.exists(_GetSavePath(value), "LevelData"):
			print("resource doesnt exist at: ", _GetSavePath(value))
			ResourceSaver.save(value, _GetSavePath(value))
		var levelData:LevelData = ResourceLoader.load(_GetSavePath(value), "LevelData", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		
		CurrentLevelData = levelData
		print("Saved CurrentLevel data ONSET: ", _GetSavePath(value))
	get: 
		return CurrentLevelData
var CurrentLevel: LevelCtrl = null

## Current level data
# Get:
# Returns user://leveldata if exists
# Set:
# Looks for user:// leveldata and sets LevelData to that if exists
# Otherwise creates it using the base resource and then sets the LevelData to the created thing

#func GetLevelData() -> LevelData:
	

func SaveLevelData() -> void:
	if CurrentLevelData && ResourceLoader.exists(_GetSavePath(CurrentLevelData), "LevelData"): 
		if _GetSavePath(CurrentLevelData) == "": return
		ResourceSaver.save(CurrentLevelData, _GetSavePath(CurrentLevelData))
		print("Saved CurrentLevel data: ", _GetSavePath(CurrentLevelData))
		#ResourceSaver.save(CurrentLevelData)
	#if _LevelsResource: ResourceSaver.save(_LevelsResource)

func LoadLevel(levelData: LevelData) -> void:
	if !levelData || !levelData.PackedLevel: return
	
	# Removes any active level is there is already one open
	if CurrentLevel: 
		_StopLevel()
		await CurrentLevel.tree_exited	# Waits for the level to be deleted before continuing
	
	CurrentLevel = levelData.PackedLevel.instantiate() as LevelCtrl
	CurrentLevelData = levelData
	add_child(CurrentLevel)
	
	OnLevelLoaded.emit()

func RestartLevel() -> void:
	if !CurrentLevelData: return
	LoadLevel(CurrentLevelData)

func CompleteLevel() -> void:
	OnLevelComplete.emit()
	#_StopLevel()

func QuitLevel() -> void:
	OnLevelQuit.emit()
	_StopLevel()

func _StopLevel() -> void:
	if !CurrentLevel: return
	CurrentLevel.queue_free()
	CurrentLevelData = null
