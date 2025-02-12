extends Node2D

@export var enemy_scene: PackedScene  
@export var player: Node2D
@export var min_distance_from_player: float = 200.0
@export var level_bounds: ColorRect 
@export var base_spawn_interval: float = 3.0 
@export var enemies_per_spawn: int = 3 

@onready var wave_manager = $"../WaveManager"
var spawn_timer: Timer
var spawn_area_min: Vector2
var spawn_area_max: Vector2

func _ready(): 
	if not enemy_scene:
		push_error("Error: Enemy scene not assigned!")
		return
	if not player:
		push_error("Error: Player not assigned!")
		return
	if not level_bounds:
		push_error("Error: Level bounds not assigned!")
		return

	calculate_level_bounds()
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.autostart = false  # Controlled by WaveManager
	spawn_timer.timeout.connect(spawn_enemies)
	add_child(spawn_timer)

	# Connect to WaveManager (if found)
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_ended.connect(_on_wave_ended)

func calculate_level_bounds():
	spawn_area_min = level_bounds.global_position
	spawn_area_max = spawn_area_min + level_bounds.size

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

### **WaveManager Interaction**
func _on_wave_started(wave: int):
	print("Wave started:", wave)
	
	# Adjust spawn rate based on wave number
	if wave == 1:
		spawn_timer.wait_time = 3.0  # First wave: 3s interval
	elif wave == 2:
		spawn_timer.wait_time = 1.0  # Second wave: 1s interval
	else:
		spawn_timer.wait_time = max(0.5, 1.0 / wave)  # Further waves reduce time (min 0.5s)
	
	spawn_timer.start()

func _on_wave_ended(wave: int):
	print("Wave ended:", wave)
	spawn_timer.stop()
