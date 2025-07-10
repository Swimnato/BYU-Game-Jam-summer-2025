extends Node2D

@export var door = Node

var on := false
var other_body: Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D or body.name == "Player":
		on = true
		other_body = body
		updateDoor()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == other_body:
		on = false
		updateDoor()

func reset():
	on = false
	updateDoor()
	
func updateDoor():
	door.setState(on)
