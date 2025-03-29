extends Area2D

func _ready() -> void:
	body_entered.connect(_OnBodyEnteredArea)
	
func _OnBodyEnteredArea(body: PhysicsBody2D) -> void:
	if body.is_in_group("Player"):
		LevelManager.CompleteLevel()
