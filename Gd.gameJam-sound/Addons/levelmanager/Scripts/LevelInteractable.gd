class_name LevelInteractable
extends VBoxContainer

@export var button:Button
@export var labelTime:Label
@export var labelCollectables:Label

func SetButton(buttonText:String, callable:Callable) -> void:
	if !button || !callable: return
	button.text = buttonText
	button.pressed.connect(callable)
	
func SetTimeLabel(time:float) -> void:
	if !labelTime: return
	labelTime.text = "Best Time: " + str("%0.2f" % time,  "s")

func SetCollectablesLabel(collectables:Dictionary) -> void:
	if !labelCollectables: return
	labelCollectables.text = "%d/%s" % [_HowManyCollected(collectables.values()), _GetTotalCollectable(collectables.size())]

func _HowManyCollected(values:Array[bool]) -> int:
	return values.map(func(value): value == true).size()

func _GetTotalCollectable(collectableCount:int) -> String:
	return str(collectableCount) if collectableCount > 0 else "?"
