extends Control
class_name AbilityPresentationIcon


@onready var image = $TextureRect
@onready var background = $BackGround
@export var background_rotate_speed :float = 200.0

@onready var animationPlayer :AnimationPlayer = $AnimationPlayer
@onready var timer :Timer = $Timer


func _ready() -> void:
	image.scale = Vector2.ZERO
	background.scale = Vector2.ZERO
	image.visible = false
	background.visible = false


func init(ability :StateRes, animationDelay :float = 0) -> void:
	image.texture = ability.icon
	timer.start(animationDelay)


func _process(delta: float) -> void:
	background.rotation_degrees += delta * background_rotate_speed


func _on_timer_timeout() -> void:
	animationPlayer.play("appearing")
