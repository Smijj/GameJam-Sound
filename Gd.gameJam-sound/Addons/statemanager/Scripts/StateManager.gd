extends Node

enum States {
	NONE,
	MENU,
	GAMEPLAY
}

signal OnGameStateChanged(newState:States)

var LastGameState:States = States.NONE
var GameState:States = States.NONE:
	set(value):
		# No need to change anything if its already the requested gamestate
		if value == GameState: return
		
		LastGameState = GameState
		GameState = value
		OnGameStateChanged.emit(GameState)
		print("new gamestate: "+str(GameState))
	get:
		return GameState

func IsGameplay() -> bool:
	if GameState == States.GAMEPLAY:
		return true
	return false

func ReturnToPreviousState() -> void:
	GameState = LastGameState
