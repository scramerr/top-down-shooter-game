extends CanvasLayer

@onready var health_bar = $Control/health_bar
@onready var health_bar_label: Label = $Control/health_bar/Label
@onready var wave_timer: Label = $Control/wave_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func update_health(health):
	health_bar.value -= 1
	health_bar_label.text = str(health_bar.value) + "/" + str(health_bar.max_value)
	if health_bar.value == 0:
		get_tree().quit()
