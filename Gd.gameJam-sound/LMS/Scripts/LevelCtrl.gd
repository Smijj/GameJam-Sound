class_name LevelCtrl
extends Node2D

@export var _StartPosition:Marker2D = null

var _PlayerInstance: PlayerCtrl = null
var _GUIInstance: GUI = null
var _LevelTime: float = 0

func _ready() -> void:
	_SetupLevel()
	LevelManager.OnLevelComplete.connect(_OnLevelComplete)

func _SetupLevel() -> void:
	if !_StartPosition: _StartPosition = $"./StartPoint"
	_PlayerInstance = GameManager.GetPlayerInstance()
	if _PlayerInstance:
		add_child(_PlayerInstance)
		_PlayerInstance.global_position = _StartPosition.global_position
	_GUIInstance = GameManager.GetGUIInstance()
	if _GUIInstance:
		add_child(_GUIInstance)
	
	StateManager.GameState = StateManager.States.GAMEPLAY

func _process(delta: float) -> void:
	_LevelTime += delta
	

func _OnLevelComplete() -> void:
	var existingTime:float = LevelManager.CurrentLevelData.PersonalCompleteTime
	if existingTime > _LevelTime || existingTime < 0:
		LevelManager.CurrentLevelData.PersonalCompleteTime = _LevelTime
	LevelManager.CurrentLevelData.Completed = true
	
	LevelManager.SaveLevelData()
