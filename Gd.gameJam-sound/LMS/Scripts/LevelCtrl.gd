class_name LevelCtrl
extends Node2D

@export var _StartPosition:Marker2D = null

var _PlayerInstance: PlayerCtrl = null

func _ready() -> void:
	if !_StartPosition: _StartPosition = $"./StartPoint"
	_PlayerInstance = GameManager.GetPlayerInstance()
	if _PlayerInstance:
		add_child(_PlayerInstance)
		_PlayerInstance.global_position = _StartPosition.global_position
	
	StateManager.GameState = StateManager.States.GAMEPLAY
