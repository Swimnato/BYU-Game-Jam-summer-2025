extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("Menu") || event.is_action_pressed("Jump") || event.is_action_pressed("Use")):
		queue_free();
