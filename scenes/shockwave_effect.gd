extends Node2D

@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@onready var animation_player: AnimationPlayer = $MeshInstance2D/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_shockwave_effect()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_shockwave_effect():
	animation_player.play("shockwave")
