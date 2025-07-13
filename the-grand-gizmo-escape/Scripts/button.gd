extends Node2D

@export var door = Node

var on := false
var other_bodies: Array[Node2D]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is RigidBody2D or body.name == "Player") and !(body in other_bodies):
		on = true
		other_bodies.append(body)
		updateDoor()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in other_bodies:
		other_bodies.erase(body)
	if other_bodies.is_empty():
		on = false
		updateDoor()

func reset():
	on = false
	other_bodies.clear()
	updateDoor()
	
func updateDoor():
	door.setState(on)
