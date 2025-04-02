class_name PlayerCtrl
extends RigidBody2D

@export_group("Settings")
@export var _TorqueImpluse: float = 4000
@export var _Torque: float = 8000
@export var _AirVelocity: float = 300
@export var _WowSpeed:float = 200

@export_group("Audio")
@export var _MinMusicVol: float = -20
@export var _MaxMusicVol: float = 5
@export var _MaxSpeakerDistance: float = 250

@export var _SFXHitList: Array[AudioStream] = []
@export var _SFXStoneHit: AudioStream
@export var _SFXDie: AudioStream
@export var _SFXRolling: AudioStream

@export_group("Refs")
@export var _SpeakerShapeCast:ShapeCast2D = null
@export var _PlayerSprite: Sprite2D
@export var _PlayerSpriteDefault: Texture2D
@export var _PlayerSpriteSpeed: Texture2D

var _MinAirTimeBeforeCollisionSFX: float = 0.15
var _AirTimeCounter: float = 0
var _WowSpeedReached: bool = false
var _CollisionResult: KinematicCollision2D

#region Built-In

func _exit_tree() -> void:
	AudioHandler.StopAmbient(_SFXRolling)
	_FadeMusicToNonDiegetic()

func _ready() -> void:
	GameManager.OnPaused.connect(_OnPaused)
	LevelManager.OnLevelComplete.connect(_HandleLevelCompleteMusicVolume)

func _OnPaused() -> void:
	AudioHandler.StopAmbient(_SFXRolling)
	_FadeMusicToNonDiegetic()

func _process(delta: float) -> void:
	_HandleDiegeticMusicVolume()

func _input(event: InputEvent) -> void:
	if !StateManager.IsGameplay(): return
	# Handle Input
	if event.is_action_pressed("Move_Left"):
		if (angular_velocity >= -0.1):
			apply_torque_impulse(-_TorqueImpluse)
	if event.is_action_pressed("Move_Right"):
		if (angular_velocity <= 0.1):
			apply_torque_impulse(_TorqueImpluse)

func _physics_process(delta: float) -> void:
#endregion
	# Handle Input
	if StateManager.IsGameplay(): 
		if Input.is_action_pressed("Move_Left"):
			apply_torque(-_Torque)
			if !_IsTouchingSurface():
				apply_force(Vector2.LEFT * _AirVelocity)
		if Input.is_action_pressed("Move_Right"):
			apply_torque(_Torque)
			if !_IsTouchingSurface():
				apply_force(Vector2.RIGHT * _AirVelocity)
	
	# Handle Player sprite changing with difference speeds
	if linear_velocity.length() > _WowSpeed:
		_MakeWow()
	else:
		_MakeNotWow()

	# Handle Roll SFX changing with different speeds
	if absf(angular_velocity) > 1 && (_IsTouchingSurface() || _AirTimeCounter < _MinAirTimeBeforeCollisionSFX):
		var audioplayer:AudioStreamPlayer = AudioHandler.PlayAmbient(_SFXRolling, 0.25)
		audioplayer.pitch_scale = lerpf(0.3, 1.1, linear_velocity.length() / _WowSpeed)
	else:
		AudioHandler.StopAmbient(_SFXRolling)

	# Handle hitting a surface SFX
	if _AirTimeCounter > _MinAirTimeBeforeCollisionSFX && _IsTouchingSurface():
		AudioHandler.PlaySFX(_SFXHitList.pick_random())
		AudioHandler.PlaySFX(_SFXStoneHit)
	
	if !_IsTouchingSurface():
		_AirTimeCounter += delta
	else:
		_AirTimeCounter = 0
	
	_CheckTileData(delta)
	_CollisionResult = move_and_collide(linear_velocity * delta)

#region Private

func _HandleDiegeticMusicVolume() -> void:
	if !AudioHandler._MusicAudioPlayer || !StateManager.IsGameplay(): return
	
	var speakerDistance:float = _GetClosestSpeakerDistance()
	if speakerDistance < _MaxSpeakerDistance:
		var weight: float = speakerDistance /_MaxSpeakerDistance 
		AudioHandler._MusicAudioPlayer.volume_db = clampf(lerpf(_MaxMusicVol, _MinMusicVol, weight), _MinMusicVol, _MaxMusicVol)
	else:
		AudioHandler._MusicAudioPlayer.volume_db = _MinMusicVol

func _GetClosestSpeakerDistance() -> float:
	if !_SpeakerShapeCast: return INF
	
	var results:Array = _SpeakerShapeCast.collision_result
	if !results: return INF
	
	var closestDistance: float = INF
	for collisionData:Dictionary in results:
		if !collisionData.has("point"): continue
		var point: Vector2 = collisionData["point"]
		if global_position.distance_to(point) < closestDistance:
			closestDistance = global_position.distance_to(point)
	
	return closestDistance

var _MusicFadeTween: Tween = null
func _FadeMusicToNonDiegetic() -> void:
	if !AudioHandler._MusicAudioPlayer: return
	if _MusicFadeTween: _MusicFadeTween.kill()
	_MusicFadeTween = create_tween()
	_MusicFadeTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_MusicFadeTween.tween_property(AudioHandler._MusicAudioPlayer, "volume_db", -5, 0.5).set_ease(Tween.EASE_OUT)

var _MusicQuietTween: Tween = null
func _HandleLevelCompleteMusicVolume() -> void:
	if _MusicQuietTween: _MusicQuietTween.kill()
	_MusicQuietTween = create_tween()
	_MusicQuietTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_MusicQuietTween.tween_property(AudioHandler._MusicAudioPlayer, "volume_db", -20, 0.5).set_ease(Tween.EASE_OUT)
	_MusicQuietTween.tween_property(AudioHandler._MusicAudioPlayer, "volume_db", 0, 1).set_ease(Tween.EASE_OUT).set_delay(4)

func _OnHarmfulCollision() -> void:
	if !StateManager.IsGameplay(): return
	
	AudioHandler.PlaySFX(_SFXDie)
	LevelManager.RestartLevel()

func _MakeWow() -> void:
	if _WowSpeedReached || !_PlayerSprite: return
	_PlayerSprite.texture = _PlayerSpriteSpeed
	_WowSpeedReached = true

func _MakeNotWow() -> void:
#endregion
	if !_WowSpeedReached || !_PlayerSprite: return
	_PlayerSprite.texture = _PlayerSpriteDefault
	_WowSpeedReached = false


#region Helpers

func _IsTouchingSurface() -> bool:
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
#endregion
