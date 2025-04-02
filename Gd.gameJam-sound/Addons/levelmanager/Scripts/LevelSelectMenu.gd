extends CanvasLayer

@export var _LevelInteractablesContainer: GridContainer
@export var _LevelInteractablePrefab: PackedScene

var _LevelsResource: LevelsResource = preload("res://Addons/levelmanager/LevelsResource.tres")

var _Buttons:Array[Button] = []
var _LevelInteractables: Dictionary[LevelData, LevelInteractable] = {}

func _ready() -> void:
	_SetupLevelInteractables()
	visibility_changed.connect(_ReloadInteractables)

func _SetupLevelInteractables() -> void:
	if !_LevelInteractablesContainer || _LevelsResource.Levels.is_empty(): return
	for levelData:LevelData in _LevelsResource.Levels:
		_SetupInteractable(levelData)

func _SetupInteractable(levelData: LevelData):
	if !_LevelInteractablePrefab: return
	
	var levelInteractable:LevelInteractable = _LevelInteractablePrefab.instantiate() as LevelInteractable
	_LevelInteractablesContainer.add_child(levelInteractable)
	
	# Set level select button onClick function
	levelInteractable.SetButton(levelData.LevelName, func(): LevelManager.LoadLevel(levelData))
	
	# Handle Personal Complete Time label's text  
	if levelData.PersonalCompleteTime != -1:
		levelInteractable.SetTimeLabel(levelData.PersonalCompleteTime)
	
	# Handle Collectables Time label's text  
	levelInteractable.SetCollectablesLabel(levelData.Collectables)
	
	_LevelInteractables.set(levelData, levelInteractable)

func _ReloadInteractables() -> void:
	if visible == false || _LevelInteractables.is_empty(): return
	
	var levelDatas:Array[LevelData] = _LevelInteractables.keys()
	for index in levelDatas.size():
		# Handle Personal Complete Time label's text  
		if levelDatas[index].PersonalCompleteTime != -1:
			_LevelInteractables[levelDatas[index]].SetTimeLabel(levelDatas[index].PersonalCompleteTime)
		
		# Handle Collectables label
		_LevelInteractables[levelDatas[index]].SetCollectablesLabel(levelDatas[index].Collectables)
		
		# Handle if the level button is disabled or not. Also focuses the button for the level the player has yet to complete
		if index > 0:
			if levelDatas[index-1].Completed:
				_LevelInteractables[levelDatas[index]].button.disabled = false
				# if the previous level has been completed, focus this button instead
				_LevelInteractables[levelDatas[index]].button.grab_focus()
			else:
				# if the previous level hasn't been compeleted, this level is locked
				_LevelInteractables[levelDatas[index]].button.disabled = true
		else:
			# If its the first button in the list select it
			_LevelInteractables[levelDatas[index]].button.grab_focus()
