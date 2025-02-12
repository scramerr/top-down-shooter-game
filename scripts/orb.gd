extends CharacterBody2D

@onready var orb_sprite: AnimatedSprite2D = $orbSprite

@onready var teleport_shader = $orbSprite.material


const MAX_SPEED = 500
const ACCELERATION = 10
const FRICTION = 0.2


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if teleport_shader:
		var time_val = GlobalTimer.global_time
		teleport_shader.set_shader_parameter("custom_time", time_val)
		$orbSprite.queue_redraw()
		
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	# Make delta independent of time scale
	var adjusted_delta = delta / Engine.time_scale
	
	if direction != Vector2.ZERO:
		velocity = velocity.lerp(direction * MAX_SPEED, ACCELERATION * adjusted_delta)  # Smooth acceleration
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)  # Smooth deceleration
	
	position += velocity * adjusted_delta
