extends Area2D

@export var _SFXCollect: AudioStream

func _ready() -> void:
	# Gets the status of the collectable from the saved LeveData if its already recorded the LeveData, 
	# otherwise add this collectable to the LeveData with a value of false
	var collectableFound: bool = LevelManager.CurrentLevelData.Collectables.get_or_add(get_path(), false)
	LevelManager.SaveLevelData()
	# if its in the LevelData and been found already, hide this collectable
	if collectableFound == true:
		_Hide()
		return
	
	body_entered.connect(_OnBodyEnteredArea)
	
func _OnBodyEnteredArea(body: Node2D) -> void:
	# Collect
	if LevelManager.CurrentLevelData.Collectables.has(get_path()):
		LevelManager.CurrentLevelData.Collectables.set(get_path(), true)
		LevelManager.SaveLevelData()
	
	# Play collect SFX
	AudioHandler.PlaySFX(_SFXCollect)
	
	_Hide()

func _Hide() -> void:
	queue_free()
