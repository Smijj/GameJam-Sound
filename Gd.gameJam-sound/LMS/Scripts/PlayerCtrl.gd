extends RigidBody2D

@export var _TorqueImpluse: float = 4000
@export var _Torque: float = 8000

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		pass
	if event.is_action_pressed("Move_Left"):
		apply_torque_impulse(-_TorqueImpluse)
	if event.is_action_pressed("Move_Right"):
		apply_torque_impulse(_TorqueImpluse)
		
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Move_Left"):
		apply_torque(-_Torque)
	if Input.is_action_pressed("Move_Right"):
		apply_torque(_Torque)
