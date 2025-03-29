extends Node

@export var _PlayerPrefab: PackedScene = preload("res://LMS/Prefabs/Player.tscn")
func GetPlayerInstance() -> PlayerCtrl:
	if !_PlayerPrefab: return null
	var instantiatedPlayer: PlayerCtrl = _PlayerPrefab.instantiate() as PlayerCtrl
	if !instantiatedPlayer: return null
	return instantiatedPlayer

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
	
	LevelManager.OnLevelLoaded.connect(_OnLevelLoaded)
	LevelManager.OnLevelQuit.connect(_OnLevelQuit)
	LevelManager.OnLevelComplete.connect(_OnLevelCopmlete)
	MenuManager.OnMenusClosed.connect(_OnMenusClosed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Paused = !Paused

func _OnLevelLoaded() -> void:
	MenuManager.CloseMenus(false)

func _OnLevelQuit() -> void:
	MenuManager.OpenMenu("Start")

func _OnLevelCopmlete() -> void:
	MenuManager.OpenMenu("Start")
	
func _OnMenusClosed() -> void:
	Paused = false
