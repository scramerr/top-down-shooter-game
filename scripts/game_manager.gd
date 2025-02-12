extends Node2D

const PLAYER = preload("res://scenes/player.tscn")
const ORB = preload("res://scenes/orb.tscn")

var player: Player = null
var orb_thrown = false
var orb = null

var teleport_position = Vector2(400, 200)

func _ready() -> void:
	spawn_player(Vector2(400,200))
	

func _process(delta: float) -> void:
		
	if Input.is_action_just_pressed("right_click"):
		if !orb_thrown:
			remove_player()
		
		else:
			spawn_player(orb.position)
			orb.queue_free()

func remove_player():
	if player:
		player.queue_free()
		player = null
		orb_thrown = true

func spawn_player(pos):
	player = PLAYER.instantiate()
	add_child(player)
	player.position = pos
	orb_thrown = false
	player.gun.onShoot.connect(on_entered)
	print(player.position)
	
func on_entered(node: Node2D) -> void:
	orb = node
	teleport_position = node.position
	print(node.position)
	
