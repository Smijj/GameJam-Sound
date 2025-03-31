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
	
	levelInteractable.button.text = levelData.LevelName
	levelInteractable.button.pressed.connect(func(): LevelManager.LoadLevel(levelData))
	
	if levelData.PersonalCompleteTime != -1:
		levelInteractable.label.text = "Best Time: " + str(levelData.PersonalCompleteTime as int) + "s"
	
	_LevelInteractables.set(levelData, levelInteractable)

func _ReloadInteractables() -> void:
	if visible == false || _LevelInteractables.is_empty(): return
	
	var keys:Array[LevelData] = _LevelInteractables.keys()
	
	for index in keys.size():
		if keys[index].PersonalCompleteTime != -1:
			_LevelInteractables[keys[index]].label.text = "Best Time: " + str("%0.2f" % keys[index].PersonalCompleteTime,  "s")
		if index > 0:
			if keys[index-1].Completed:
				_LevelInteractables[keys[index]].button.disabled = false
				# if the previous level has been completed, focus this button instead
				_LevelInteractables[keys[index]].button.grab_focus()
			else:
				# if the previous level hasn't been compeleted, this level is locked
				_LevelInteractables[keys[index]].button.disabled = true
		else:
			# If its the first button in the list select it
			_LevelInteractables[keys[index]].button.grab_focus()
