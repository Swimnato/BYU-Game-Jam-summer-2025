extends Node2D

@export var door = Node

var on := false
var other_bodies: Array[Node2D]

#func _ready() -> void:
	#reset()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is RigidBody2D or body.name == "Player") and !(body in other_bodies):
		if on == false:
			$Sprite2D/AnimationPlayer.play("press")
		on = true
		other_bodies.append(body)
		updateDoor()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in other_bodies:
		other_bodies.erase(body)
	if other_bodies.is_empty():
		on = false
		$Sprite2D/AnimationPlayer.play("press", -1, -1, true)
		updateDoor()

func reset():
	$Sprite2D/AnimationPlayer.play("RESET")
	on = false
	other_bodies.clear()
	updateDoor()
	
func updateDoor():
	door.setState(on)
