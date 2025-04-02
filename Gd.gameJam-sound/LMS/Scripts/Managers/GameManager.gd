extends Node

@export var _PlayerPrefab: PackedScene = preload("res://LMS/Prefabs/Player.tscn")
func GetPlayerInstance() -> PlayerCtrl:
	if !_PlayerPrefab: return null
	var instantiatedPlayer: PlayerCtrl = _PlayerPrefab.instantiate() as PlayerCtrl
	if !instantiatedPlayer: return null
	return instantiatedPlayer

var _GUIPrefab: PackedScene = preload("res://LMS/Prefabs/GUI.tscn")
func GetGUIInstance() -> GUI:
	if !_GUIPrefab: return null
	var instantiatedGUI: GUI = _GUIPrefab.instantiate() as GUI
	if !instantiatedGUI: return null
	return instantiatedGUI

var _Music: Array[AudioStream] = [
	preload("res://LMS/Audio/Music/Music_Bouncing-Baal_Normalised.ogg") as AudioStream,
	preload("res://LMS/Audio/Music/Music_Random-Race_Normalised.ogg") as AudioStream,
	preload("res://LMS/Audio/Music/Music_String-Theory_Normalised.ogg") as AudioStream
]

var Paused: bool = false :
	set (value): 
		# Don't paused anything unless the GameState is Gameplay
		if value == true && !StateManager.IsGameplay(): 
			return
		
		get_tree().paused = value
		Paused = value
		
		if value:
			MenuManager.OpenMenu("Pause")
			OnPaused.emit()
		else:
			MenuManager.CloseMenus()
	get: return Paused
signal OnPaused

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _ready() -> void:
	MenuManager.OpenMenu("Start")
	AudioHandler.PlayMusic(_Music.pick_random())
	
	LevelManager.OnLevelLoaded.connect(_OnLevelLoaded)
	LevelManager.OnLevelQuit.connect(_OnLevelQuit)
	MenuManager.OnMenusClosed.connect(_OnMenusClosed)
	AudioHandler.CurrentTrackFinished.connect(_OnAudioTrackFinished)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Paused = !Paused

func _OnLevelLoaded() -> void:
	MenuManager.CloseMenus(false)

func _OnLevelQuit() -> void:
	MenuManager.OpenMenu("LevelSelect")

func _OnMenusClosed() -> void:
	Paused = false

func _OnAudioTrackFinished() -> void:
	AudioHandler.PlayMusic(_Music.pick_random())
