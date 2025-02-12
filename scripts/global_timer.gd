extends Node

var global_time = 0.0  # Time that always runs normally

func _process(delta):
	global_time += delta  # Keeps counting time normally
