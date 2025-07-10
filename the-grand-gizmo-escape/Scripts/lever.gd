extends Node2D

@export var door = Node

var on := false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		on = !on
		door.setState(on)
