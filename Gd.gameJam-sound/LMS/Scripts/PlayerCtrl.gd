class_name PlayerCtrl
extends RigidBody2D

@export var _TorqueImpluse: float = 4000
@export var _Torque: float = 8000
@export var _AirVelocity: float = 300

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Move_Left"):
		if (angular_velocity >= -0.1):
			apply_torque_impulse(-_TorqueImpluse)
	if event.is_action_pressed("Move_Right"):
		if (angular_velocity <= 0.1):
			apply_torque_impulse(_TorqueImpluse)
		
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Move_Left"):
		apply_torque(-_Torque)
		if !_IsOnGround():
			apply_force(Vector2.LEFT * _AirVelocity)
	if Input.is_action_pressed("Move_Right"):
		apply_torque(_Torque)
		if !_IsOnGround():
			apply_force(Vector2.RIGHT * _AirVelocity)

func _IsOnGround() -> bool:
	return get_colliding_bodies().size() > 0
