extends Node

@export var _PlayerPrefab: PackedScene = preload("res://LMS/Prefabs/Player.tscn")

var _CurrentLevel: LevelCtrl = null
var Paused: bool = false :
	set (value): 
		print(value)
		if value == true && !StateManager.IsGameplay(): return
		get_tree().paused = value
		Paused = value
		if value:
			MenuManager.OpenMenu("Pause")
		else:
			MenuManager.CloseMenus()
	get: return Paused

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	MenuManager.OpenMenu("Start")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Paused = !Paused

func GetPlayerInstance() -> PlayerCtrl:
	if !_PlayerPrefab: return null
	var instantiatedPlayer: PlayerCtrl = _PlayerPrefab.instantiate() as PlayerCtrl
	if !instantiatedPlayer: return null
	return instantiatedPlayer

func LoadLevel(levelData: LevelData) -> void:
	if !levelData || !levelData.PackedLevel: return
	
	if _CurrentLevel: _CurrentLevel.free()
	_CurrentLevel = levelData.PackedLevel.instantiate() as LevelCtrl
	add_child(_CurrentLevel)
	
	MenuManager.CloseMenus(false)

func QuitLevel() -> void:
	if _CurrentLevel:
		_CurrentLevel.queue_free()
	MenuManager.OpenMenu("Start")
