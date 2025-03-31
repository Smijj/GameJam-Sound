extends Area2D

func _ready() -> void:
	# Don't show collectable if its already been collected
	if LevelManager.CurrentLevelData.Collectables.has(get_path()): 
		_Hide()
		return
	
	body_entered.connect(_OnBodyEnteredArea)
	
func _OnBodyEnteredArea(body: Node2D) -> void:
	# Collect
	LevelManager.CurrentLevelData.Collectables.append(get_path())
	LevelManager.SaveLevelData()
	
	# TODO: Play collect SFX
	
	_Hide()

func _Hide() -> void:
	visible = false
	monitoring = false
