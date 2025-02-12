extends Area2D

@export var impact_effect: PackedScene  # Drag your `BulletImpactEffect.tscn` here
@export var SPEED: float = 500
@export var RANGE: float = 100
@onready var bullet_sprite = $sprite

var distance_traveled := 0.0
var direction := Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	var movement = direction * SPEED * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= RANGE:
		spawn_effect()
		queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	bullet_sprite.visible = false
	
	
func spawn_effect():
	if impact_effect:
		var effect_instance = impact_effect.instantiate()
		get_parent().add_child(effect_instance)
		effect_instance.global_position = global_position
		
		var particles = effect_instance.get_node_or_null("bulletEffect")  # Adjust the node name if needed
		if particles:
			particles.emitting = true  # Force the particle system to play
			
	
