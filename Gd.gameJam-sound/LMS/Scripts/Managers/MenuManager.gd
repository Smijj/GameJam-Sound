extends Node

const _MenusResource: MenusResource = preload("res://Resources/MenusResource.tres")
var _Scenes: Dictionary[String, CanvasLayer] = {}

var _CurrentMenu:String = ""

func _init() -> void:
	# Preload all the packed menu scenes
	for key in _MenusResource.Scenes.keys():
		var menuScene:PackedScene = _MenusResource.Scenes[key]
		var newScene:CanvasLayer = menuScene.instantiate()
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
