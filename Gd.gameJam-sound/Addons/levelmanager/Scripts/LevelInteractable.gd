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

func SetCollectablesLabel(numberOfCollectables:int) -> void:
	if !labelCollectables: return
	labelCollectables.text = "x%d" % numberOfCollectables
