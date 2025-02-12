extends CharacterBody2D

@export var playerHealth: int = 10
@export var MAX_SPEED: float = 230.0 
@export var ACCELERATION: float = 10.0
@export var FRICTION: float = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Gun = $Gun
@onready var player_animation_player = $AnimationPlayer

var ui


func _ready() -> void:
	add_to_group("player")
	Global.player = self
	ui = get_parent().get_node("ui")

func _exit_tree() -> void:
	Global.player = null

func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	if direction != Vector2.ZERO:
		velocity = velocity.lerp(direction * MAX_SPEED, ACCELERATION * delta)  # Smooth acceleration
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)  # Smooth deceleration
	
	move_and_slide()
	
func take_damage(damageAmount: int) -> void:
	ui.update_health(damageAmount)

func dissolve():
	sprite.set("shader_param/dissolve_amount", 0.5) 
	
func animation_shrink():
	player_animation_player.play("shrink")

func animation_unshrink():
	player_animation_player.play("unshrink")
