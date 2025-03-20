extends Sprite2D

@export var _FollowTarget: Node2D

var _FadeTween: Tween = null
@export var _FadeTime: float = 0.1

func _init() -> void:
	visible = false
	SignalBus.OnPlayerEnterExitSpeakerRange.connect(_OnPlayerEnterExitSpeakerRange)

func _process(delta: float) -> void:
	if _FollowTarget: global_position = _FollowTarget.global_position
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		self_modulate = Color.YELLOW
	elif event.is_action_released("Interact"):
		self_modulate = Color.WHITE

func _OnPlayerEnterExitSpeakerRange(isEntering: bool) -> void:
	if _FadeTween: _FadeTween.kill()
	_FadeTween = create_tween()
	if isEntering:
		modulate = Color.TRANSPARENT
		visible = true
		_FadeTween.tween_property(self, "modulate", Color.WHITE, _FadeTime)
	else:
		_FadeTween.tween_property(self, "modulate", Color.TRANSPARENT, _FadeTime)
		_FadeTween.tween_callback(func(): visible = false)
