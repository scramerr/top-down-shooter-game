extends Node2D
class_name Gun

#@export var teleportCharged = false

@onready var muzzle = $muzzle
@onready var gunSprite = $sprite
@onready var player = get_parent()
@onready var shootEffect = $shootEffect
@onready var shootEffectTimer = $Timer
@onready var gun_animation_player = $AnimationPlayer
@onready var sfx_shotgun: AudioStreamPlayer2D = $sfx_shotgun
@onready var sfx_teleport: AudioStreamPlayer2D = $sfx_teleport

var SHOCKWAVE = preload("res://scenes/shockwave_effect.tscn")

const BULLET1 = preload("res://scenes/bullet.tscn")
const BULLET2 = preload("res://scenes/bullet.tscn")
const BULLET3 = preload("res://scenes/bullet.tscn")
const ORB = preload("res://scenes/orb.tscn")

var kill_counter = 0
var orb_instance
var shockwave_effect_instance
var player_camera
var camera_following_orb = false
var canShoot = true
var cooldown_timer: Timer  
var teleporting = false

signal onShoot(node)

func _ready() -> void:
	shootEffect.visible = false
	var shotgun_cooldown_time = Global.shotgunCoolDown
	var teleport_charge = Global.teleportationCharge

	# Create a single cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = shotgun_cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_reset_shoot)
	add_child(cooldown_timer)
	
	player_camera = player.get_node("PlayerCamera")

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	scale.y = -1 if (rotation_degrees > 90 and rotation_degrees < 270) else 1

	if Input.is_action_just_pressed("left_click") and canShoot:
		shoot()
	
	if Input.is_action_just_pressed("right_click") and !teleporting:
		player.animation_shrink()
		gun_animation_player.play("shrink")
		sfx_teleport.play()
		Global.camera.shake(0.3, 3)
		get_tree().create_timer(0.6).timeout.connect(func(): shoot_orb())
	elif Input.is_action_just_pressed("right_click") and teleporting:
		Engine.time_scale = 1.0
		spawn_player_at_orb()
	if camera_following_orb and orb_instance:
		player_camera.global_position = orb_instance.global_position
		
func shoot():
	sfx_shotgun.play()
	canShoot = false 
	Global.camera.shake(0.2, 2)
	
	var bullet1_instance = BULLET1.instantiate()
	var bullet2_instance = BULLET2.instantiate()
	var bullet3_instance = BULLET3.instantiate()

	get_tree().current_scene.add_child(bullet1_instance)
	get_tree().current_scene.add_child(bullet2_instance)
	get_tree().current_scene.add_child(bullet3_instance)

	shootEffect.visible = true
	shootEffectTimer.start()

	bullet1_instance.rotation = global_rotation
	bullet2_instance.rotation = global_rotation - randf_range(0.2, 0.3)
	bullet3_instance.rotation = global_rotation + randf_range(0.1, 0.4)

	bullet1_instance.global_position = muzzle.global_position
	bullet2_instance.global_position = muzzle.global_position
	bullet3_instance.global_position = muzzle.global_position

	cooldown_timer.start()  

func shoot_orb():
	canShoot = false
	
	orb_instance = ORB.instantiate()
	get_tree().root.add_child(orb_instance)
	orb_instance.global_position = muzzle.global_position
	onShoot.emit(orb_instance)
	teleporting = true
	player.collision_layer = 0
	player.collision_mask = 0
	player.set_physics_process(false)
	player.set_process(false)
	
	Engine.time_scale = 0.15
	
	camera_following_orb = true
	player_camera.global_position = orb_instance.global_position
	
	for c in player.get_children():
		if c is CollisionShape2D:
			c.disabled = true

func _reset_shoot():
	canShoot = true  

func _on_timer_timeout() -> void:
	shootEffect.visible = false

func spawn_player_at_orb():
	if orb_instance == null:
		print("Error: orb_instance is null")
		return
	
	shockwave_effect_instance = SHOCKWAVE.instantiate()
	add_child(shockwave_effect_instance)
	
	kill_enemies_on_orb_radius()
	
	Global.camera.shake(0.4, 4)
	player.position = orb_instance.position
	player.visible = true
	player.collision_layer = 1
	player.collision_mask = 1
	player.set_physics_process(true)
	player.set_process(true)
	
	for c in player.get_children():
		if c is CollisionShape2D:
			c.disabled = false
	
	player.animation_unshrink()
	gun_animation_player.play("unshrink")
	
	var tween = get_tree().create_tween()
	tween.tween_property(player_camera, "global_position", player.global_position, 0.1) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	
	teleporting = false
	
	orb_instance.queue_free()
	orb_instance = null
	
	canShoot = true

func kill_enemies_on_orb_radius():
	var enemies = orb_instance.get_node("Area2D").get_overlapping_bodies()
	for e in enemies:
		if e.has_method("die"):
			e.die()
