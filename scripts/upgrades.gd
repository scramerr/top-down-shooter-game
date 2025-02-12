extends Control

signal next_wave

@onready var button = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func buttonPressed():
	next_wave.emit()
	queue_free()

func _on_button_pressed() -> void:
	buttonPressed()
