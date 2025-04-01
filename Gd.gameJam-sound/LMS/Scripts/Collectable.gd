extends Area2D

@export var _SFXCollect: AudioStream

func _ready() -> void:
	# Don't show collectable if its already been collected
	if LevelManager.CurrentLevelData.Collectables.has(get_path()): 
		_Hide()
		return
	
	body_entered.connect(_OnBodyEnteredArea)
	
func _OnBodyEnteredArea(body: Node2D) -> void:
	# Collect
	if !LevelManager.CurrentLevelData.Collectables.has(get_path()):
		LevelManager.CurrentLevelData.Collectables.append(get_path())
		LevelManager.SaveLevelData()
	
	# Play collect SFX
	AudioHandler.PlaySFX(_SFXCollect)
	
	_Hide()

func _Hide() -> void:
	visible = false
	monitoring = false
