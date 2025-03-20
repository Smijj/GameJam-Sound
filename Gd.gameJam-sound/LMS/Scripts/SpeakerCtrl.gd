extends Node2D

#@export var _FacingDirection:Vector2 = Vector2.LEFT
@export var _SpeakerStrength: float = 1000
var _CurrentPlayer: RigidBody2D = null

@export var _LineColour: Color = Color.LIME_GREEN
@export var _LineTexture: Texture2D
var _LineIndicator: Line2D=  null

func _ready() -> void:
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

func _process(delta: float) -> void:
	if _CurrentPlayer:
		_DrawLineIndicatorToTarget(_CurrentPlayer.transform.origin)

#region Events

func _input(event: InputEvent) -> void:
	if _CurrentPlayer && event.is_action_pressed("Interact"):
		_CurrentPlayer.linear_velocity = Vector2.ZERO
		_CurrentPlayer.apply_impulse(transform.basis_xform(Vector2.UP) * _SpeakerStrength)

func OnBodyEnteredArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body is RigidBody2D:
			_CurrentPlayer = body as RigidBody2D


func OnBodyExitedArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_CurrentPlayer = null
		_HideLineIndicator()

#endregion

#region Private

func _DrawLineIndicatorToTarget(target: Vector2) -> void:
	if _LineIndicator.visible == false:
		_LineIndicator.visible = true
	
	_LineIndicator.clear_points()
	_LineIndicator.add_point(to_local(transform.origin))
	_LineIndicator.add_point(to_local(target))

func _HideLineIndicator() -> void:
		_LineIndicator.visible = false

#endregion
