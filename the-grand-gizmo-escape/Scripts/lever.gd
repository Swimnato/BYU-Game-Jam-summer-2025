extends Node2D

@export var door = Node

var on := false

func _onready():
	reset()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		on = !on
		updateDoor()
		if on:
			$Sprite2D/AnimationPlayer.play("swing")
		else: 
			$Sprite2D/AnimationPlayer.play("swing", -1, -1, true)

func reset():
	$Sprite2D/AnimationPlayer.play("RESET")
	on = false
	updateDoor()
	
func updateDoor():
	door.setState(on)

		
