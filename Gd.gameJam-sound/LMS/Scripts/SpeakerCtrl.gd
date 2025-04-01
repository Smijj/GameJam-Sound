extends Node2D

@export_group("Settings")
@export var _SpeakerStrength: float = 1000

@export_group("Audio")
@export var _SFXSpeakerPulse: AudioStream

@export_group("Refs")
@export var _Indicator: Sprite2D
@export var _LineColour: Color = Color.LIME_GREEN
@export var _LineTexture: Texture2D

var _CurrentPlayer: RigidBody2D = null
var _LineIndicator: Line2D=  null

var _DistortionTween:Tween = null

func _ready() -> void:
	if _Indicator: _Indicator.visible = false
	CreateLineIndicator()
	
func CreateLineIndicator() -> void:
	if _LineIndicator: return
	_LineIndicator = Line2D.new()
	_LineIndicator.default_color = _LineColour
	_LineIndicator.texture = _LineTexture
	_LineIndicator.texture_mode = Line2D.LINE_TEXTURE_TILE
	_LineIndicator.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_LineIndicator.z_index = -1
	add_child(_LineIndicator)
	_LineIndicator.visible = false

func _exit_tree() -> void:
	_ResetDistortion()

func _process(delta: float) -> void:
	if _CurrentPlayer:
		_DrawLineIndicatorToTarget(_CurrentPlayer.transform.origin)

#region Events

func _input(event: InputEvent) -> void:
	if _CurrentPlayer && event.is_action_pressed("Interact"):
		_PushPlayer()

func OnBodyEnteredArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body is RigidBody2D:
			_CurrentPlayer = body as RigidBody2D
			if _Indicator: _Indicator.visible = true
			SignalBus.OnPlayerEnterExitSpeakerRange.emit(true)


func OnBodyExitedArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_CurrentPlayer = null
		_HideLineIndicator()
		if _Indicator: _Indicator.visible = false
		SignalBus.OnPlayerEnterExitSpeakerRange.emit(false)
		

#endregion

#region Private

func _PushPlayer() -> void:
	_CurrentPlayer.linear_velocity = Vector2.ZERO
	_CurrentPlayer.apply_impulse(transform.basis_xform(Vector2.UP) * _SpeakerStrength)
	
	if _DistortionTween: _DistortionTween.kill()
	var _DistortionTween: Tween = create_tween()
	_DistortionTween.tween_method(_AnimateDistortion, 0.0, 0.7, 0.3).set_ease(Tween.EASE_OUT)
	_DistortionTween.tween_callback(_ResetDistortion)
	
	# Play SFX
	AudioHandler.PlaySFX(_SFXSpeakerPulse)

func _AnimateDistortion(size:float) -> void:
	LevelManager.CurrentLevel._GUIInstance.DistortionProcessor.material.set("shader_parameter/center", _GetScreenUV())
	LevelManager.CurrentLevel._GUIInstance.DistortionProcessor.material.set("shader_parameter/size", size)

func _ResetDistortion() -> void:
	LevelManager.CurrentLevel._GUIInstance.DistortionProcessor.material.set("shader_parameter/center", Vector2(0.5, 0.5))
	LevelManager.CurrentLevel._GUIInstance.DistortionProcessor.material.set("shader_parameter/size", 0)
	

func _DrawLineIndicatorToTarget(target: Vector2) -> void:
	if _LineIndicator.visible == false:
		_LineIndicator.visible = true
	
	_LineIndicator.clear_points()
	_LineIndicator.add_point(to_local(transform.origin))
	_LineIndicator.add_point(to_local(target))

func _HideLineIndicator() -> void:
		_LineIndicator.visible = false

func _GetScreenUV() -> Vector2:
	
	var screenCoords:Vector2 = get_viewport_transform() * global_position - Vector2(60, 90)
	var normalizedScreenCoords:Vector2 = (screenCoords/get_viewport().get_visible_rect().size)
	
	#var ratio: float = get_viewport().get_visible_rect().size.x / get_viewport().get_visible_rect().size.y
	#var scaledUV: Vector2 = ((normalizedScreenCoords - Vector2(0.5 ,0)) / Vector2(ratio, 1)) + Vector2(0.5 ,0)
	
	return normalizedScreenCoords

#endregion
