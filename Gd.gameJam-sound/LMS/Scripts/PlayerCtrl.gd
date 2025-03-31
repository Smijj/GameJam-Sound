class_name PlayerCtrl
extends RigidBody2D

@export var _TorqueImpluse: float = 4000
@export var _Torque: float = 8000
@export var _AirVelocity: float = 300

var _CollisionResult: KinematicCollision2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Move_Left"):
		if (angular_velocity >= -0.1):
			apply_torque_impulse(-_TorqueImpluse)
	if event.is_action_pressed("Move_Right"):
		if (angular_velocity <= 0.1):
			apply_torque_impulse(_TorqueImpluse)
		

func _physics_process(delta: float) -> void:
	_CheckTileData(delta)
	
	if Input.is_action_pressed("Move_Left"):
		apply_torque(-_Torque)
		if !_IsOnGround():
			apply_force(Vector2.LEFT * _AirVelocity)
	if Input.is_action_pressed("Move_Right"):
		apply_torque(_Torque)
		if !_IsOnGround():
			apply_force(Vector2.RIGHT * _AirVelocity)
	
	_CollisionResult = move_and_collide(linear_velocity * delta)

func _OnHarmfulCollision() -> void:
	LevelManager.RestartLevel()

func _IsOnGround() -> bool:
	return get_colliding_bodies().size() > 0

func _CheckTileData(delta:float) -> void:
	var collisionBodies:Array[Node2D] = get_colliding_bodies()
	var tileMap: TileMapLayer = null
	if collisionBodies:
		for body:Node2D in collisionBodies:
			if body is TileMapLayer:
				tileMap = body as TileMapLayer
				break
	
	if !tileMap || !_CollisionResult: return
	
	var globalPos: Vector2 = _CollisionResult.get_position() - _CollisionResult.get_normal()
	var cell:Vector2i = tileMap.local_to_map(globalPos)
	var tileData:TileData = tileMap.get_cell_tile_data(cell)
	if tileData:
		if tileData.has_custom_data("Harmful"):
			var tileIsHarmful: bool = tileData.get_custom_data("Harmful") as bool
			if tileIsHarmful:
				_OnHarmfulCollision()
