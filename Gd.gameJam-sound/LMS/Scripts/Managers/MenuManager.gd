extends Node

const _MenuScenesResource: MenuScenes = preload("res://Resources/MenuScenes.tres")
var _Scenes: Dictionary = {}

var _CurrentMenu:String = ""

func _init() -> void:
	# Preload all the packed menu scenes
	for key in _MenuScenesResource.Scenes.keys():
		var value:PackedScene = _MenuScenesResource.Scenes[key]
		var newScene:CanvasLayer = value.instantiate()
		if newScene == null: continue
		 
		newScene.visible = false
		_Scenes[key] = newScene
		add_child(newScene)

func OpenMenu(menuName:String) -> void:
	if !_Scenes.has(menuName): return
	
	if _CurrentMenu != "":
		_Scenes[_CurrentMenu].visible = false
	
	_Scenes[menuName].visible = true
	_CurrentMenu = menuName
	
	StateManager.GameState = StateManager.States.MENU

func CloseMenus() -> void:
	if _CurrentMenu == "" || !_Scenes.has(_CurrentMenu): return
	_Scenes[_CurrentMenu].visible = false
	_CurrentMenu = ""
