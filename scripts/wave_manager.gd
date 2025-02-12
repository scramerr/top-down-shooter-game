extends Node2D

@export var enemy_scene: PackedScene  
@export var player: Node2D
@export var level_bounds: ColorRect 
@export var upgradeScreen: PackedScene
@onready var ui: CanvasLayer = $"../ui"
@onready var wave_timer_label: Label = $"../ui/Control/wave_timer"
@onready var wave_heading_label: Label = $"../ui/Control/wave_heading"

@export var min_distance_from_player: float = 200.0
@export var base_spawn_interval: float = 3.0 
@export var enemies_per_spawn: int = 3 
@export var wave_time: float = 15
@export var max_waves: int = 5

var current_wave: int = 1
var remaining_time: float = 0.0
var wave_timer: Timer
var spawn_timer: Timer
var spawn_area_min: Vector2
var spawn_area_max: Vector2

signal wave_started(wave: int)
signal wave_ended(wave: int)

func _ready():
	if not enemy_scene or not player or not level_bounds:
		push_error("Error: Ensure enemy scene, player, and level bounds are assigned!")
		return

	calculate_level_bounds()

	# Setup wave timer
	wave_timer = Timer.new()
	wave_timer.wait_time = wave_time
	wave_timer.autostart = false
	wave_timer.one_shot = true  # Wave timer should only run once per wave
	wave_timer.timeout.connect(_on_wave_timeout)
	add_child(wave_timer)

	# Setup enemy spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(spawn_enemies)
	add_child(spawn_timer)

	start_next_wave()

func _process(delta):
	if wave_timer and wave_timer.time_left > 0:  # Ensure wave_timer is valid
		remaining_time = wave_timer.time_left
		update_wave_timer_ui()
		
func update_wave_timer_ui():
	if wave_timer_label:
		wave_timer_label.text = str(floor(remaining_time)) 
	if remaining_time < 10:
		wave_timer_label.label_settings.font_color = Color(0.875, 0.09, 0.157)
		
func spawn_enemies():
	if not enemy_scene or not player:
		return

	for i in range(enemies_per_spawn):
		var spawn_position = get_random_position()
		if player.global_position.distance_to(spawn_position) >= min_distance_from_player:
			var enemy = enemy_scene.instantiate()
			enemy.player = player
			enemy.global_position = spawn_position
			get_parent().add_child.call_deferred(enemy)

func get_random_position() -> Vector2:
	var x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var y = randf_range(spawn_area_min.y, spawn_area_max.y)
	return Vector2(x, y)
	
func calculate_level_bounds():
	spawn_area_min = level_bounds.global_position
	spawn_area_max = spawn_area_min + level_bounds.size

func adjust_spawn_rate(wave: int):
	if wave == 1:
		spawn_timer.wait_time = 3.0  
	elif wave == 2:
		spawn_timer.wait_time = 2.0
	else:
		spawn_timer.wait_time = max(0.5, 1.0 / wave)

func start_next_wave():
	Engine.time_scale = 1
	
	wave_heading_label.text = "WAVE " + str(current_wave)
	wave_time += 5
	if current_wave >= max_waves:
		print("All waves completed!")
		return  

	current_wave += 1
	print("Starting Wave:", current_wave)

	wave_started.emit(current_wave)
	remaining_time = wave_time  

	adjust_spawn_rate(current_wave)
	spawn_timer.start()
	wave_timer.start()
	
	
func _on_wave_timeout():
	print("Wave", current_wave, "ended!")
	spawn_timer.stop()  # Stop enemy spawning
	
	clean_up_enemies()
	
	await get_tree().create_timer(2.0).timeout

	wave_ended.emit(current_wave)

	Engine.time_scale = 0
	
	# Show Upgrade Screen between waves
	if upgradeScreen:
		var wave_ui = upgradeScreen.instantiate()
		ui.add_child(wave_ui)

		# Ensure `next_wave` signal exists before connecting
		if wave_ui.has_signal("next_wave"):
			wave_ui.next_wave.connect(start_next_wave)
		else:
			print("Error: next_wave signal missing in upgradeScreen!")

	# Reset wave timer to avoid increasing wave duration
	wave_timer.stop()
	wave_timer.wait_time = wave_time  

func clean_up_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")  # Get all enemies
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			enemy.die()  # Remove the enemy
	print("All remaining enemies removed!")
