extends CharacterBody2D

@export var death_effect: PackedScene 
@export var SPEED: float = 120
@export var health: int = 1
@export var attack_damage: int = 1

@export var player: CharacterBody2D
@onready var enemy_sprite: AnimatedSprite2D = $enemy_sprite

var ui

enum EnemyState {
	SURROUND,
	ATTACK,
	HIT,
}

var current_state = EnemyState.SURROUND 

func _ready():
	add_to_group("enemies")  # Adds enemy to the "enemies" group

	ui = get_tree().get_root().find_child("UI", true, false)
	
	if player == null:
		push_error("Player not found! Make sure the player is in the 'player' group.")

func _physics_process(delta: float) -> void:
	if player == null:
		return  
	var direction = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	# State-based behavior
	match current_state:
		EnemyState.SURROUND:
			velocity = direction * SPEED
			move_and_slide()
			enemy_sprite.play("walk")
			
		EnemyState.ATTACK:
			velocity = Vector2.ZERO 
			attack_player()
			
		EnemyState.HIT:
			pass 
	look_at(player.global_position)  

func attack_player():
	player.take_damage(attack_damage)
	die()

func take_damage():
	health -= 1

	if health <= 0:
		die()

func die():  
	if death_effect:
		var effect_instance = death_effect.instantiate()
		get_parent().add_child(effect_instance)
		effect_instance.global_position = global_position
		
		var particles = effect_instance.get_node_or_null("explosionEffect")  
		if particles:
			var angle = (player.global_position - global_position).angle()
			particles.rotation = angle  
			particles.emitting = true
			
		get_tree().create_timer(8).timeout.connect(effect_instance.queue_free)
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print('attack')
		current_state = EnemyState.ATTACK
	
