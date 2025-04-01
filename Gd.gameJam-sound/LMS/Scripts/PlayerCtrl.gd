class_name PlayerCtrl
extends RigidBody2D

@export_group("Settings")
@export var _TorqueImpluse: float = 4000
@export var _Torque: float = 8000
@export var _AirVelocity: float = 300
@export var _WowSpeed:float = 200

@export_group("Audio")
@export var _SFXHitList: Array[AudioStream] = []
@export var _SFXStoneHit: AudioStream
@export var _SFXDie: AudioStream
@export var _SFXRolling: AudioStream

@export_group("Refs")
@export var _PlayerSpriteDefault: Texture2D
@export var _PlayerSpriteSpeed: Texture2D
@export var _PlayerSprite: Sprite2D

var _MinAirTimeBeforeCollisionSFX: float = 0.15
var _AirTimeCounter: float = 0
var _WowSpeedReached: bool = false
var _CollisionResult: KinematicCollision2D

func _exit_tree() -> void:
	AudioHandler.StopAmbient(_SFXRolling)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Move_Left"):
		if (angular_velocity >= -0.1):
			apply_torque_impulse(-_TorqueImpluse)
	if event.is_action_pressed("Move_Right"):
		if (angular_velocity <= 0.1):
			apply_torque_impulse(_TorqueImpluse)
		
func _physics_process(delta: float) -> void:
	_CheckTileData(delta)
	
	if linear_velocity.length() > _WowSpeed:
		_MakeWow()
	else:
		_MakeNotWow()
	
	if Input.is_action_pressed("Move_Left"):
		apply_torque(-_Torque)
		if !_IsTouchingSurface():
			apply_force(Vector2.LEFT * _AirVelocity)
	if Input.is_action_pressed("Move_Right"):
		apply_torque(_Torque)
		if !_IsTouchingSurface():
			apply_force(Vector2.RIGHT * _AirVelocity)
	
	if absf(angular_velocity) > 1 && (_IsTouchingSurface() || _AirTimeCounter < _MinAirTimeBeforeCollisionSFX):
		var audioplayer:AudioStreamPlayer = AudioHandler.PlayAmbient(_SFXRolling, 0.25)
		audioplayer.pitch_scale = lerpf(0.3, 1.1, linear_velocity.length() / _WowSpeed)
		print(audioplayer.pitch_scale)
	else:
		AudioHandler.StopAmbient(_SFXRolling)

	if _AirTimeCounter > _MinAirTimeBeforeCollisionSFX && _IsTouchingSurface():
		AudioHandler.PlaySFX(_SFXHitList.pick_random())
		AudioHandler.PlaySFX(_SFXStoneHit)
	
	if !_IsTouchingSurface():
		_AirTimeCounter += delta
	else:
		_AirTimeCounter = 0
	
	_CollisionResult = move_and_collide(linear_velocity * delta)

func _OnHarmfulCollision() -> void:
	AudioHandler.PlaySFX(_SFXDie)
	LevelManager.RestartLevel()

func _IsTouchingSurface() -> bool:
	return get_colliding_bodies().size() > 0

func _MakeWow() -> void:
	if _WowSpeedReached || !_PlayerSprite: return
	_PlayerSprite.texture = _PlayerSpriteSpeed
	_WowSpeedReached = true
func _MakeNotWow() -> void:
	if !_WowSpeedReached || !_PlayerSprite: return
	_PlayerSprite.texture = _PlayerSpriteDefault
	_WowSpeedReached = false

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
