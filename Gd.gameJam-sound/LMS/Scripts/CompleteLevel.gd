extends Area2D

@export var _SFXLevelComplete: AudioStream

func _ready() -> void:
	body_entered.connect(_OnBodyEnteredArea)
	
func _OnBodyEnteredArea(body: PhysicsBody2D) -> void:
	if body.is_in_group("Player"):
		LevelManager.CompleteLevel()
		AudioHandler.PlaySFX(_SFXLevelComplete)
