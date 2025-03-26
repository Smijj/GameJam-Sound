extends Node

const _MenusResource: MenusResource = preload("res://Addons/menumanager/MenusResource.tres")
var _Scenes: Dictionary[String, CanvasLayer] = {}

var _CurrentMenu:String = ""
var _MenuHistory:Array[String] = []

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
	
	# Handle menu history
	if _MenuHistory.has(menuName):
		# If the menu is already in the menu history, trim the history after that entry
		var index: int = _MenuHistory.find(menuName)
		_MenuHistory = _MenuHistory.slice(0, index+1)
	else:
		_MenuHistory.push_back(menuName)
		
	if _CurrentMenu != "":
		_Scenes[_CurrentMenu].visible = false
	
	_Scenes[menuName].visible = true
	_CurrentMenu = menuName
	
	StateManager.GameState = StateManager.States.MENU

func Back() -> void:
	if _MenuHistory.size() <= 1: 
		CloseMenus()
		return
	var menuToOpen:String = _MenuHistory[-2]
	OpenMenu(menuToOpen)

func CloseMenus(revertGameState = true) -> void:
	_MenuHistory.clear()
	if _CurrentMenu == "" || !_Scenes.has(_CurrentMenu): return
	
	_Scenes[_CurrentMenu].visible = false
	_CurrentMenu = ""
	
	if revertGameState: StateManager.ReturnToPreviousState()
	GameManager.Paused = false
