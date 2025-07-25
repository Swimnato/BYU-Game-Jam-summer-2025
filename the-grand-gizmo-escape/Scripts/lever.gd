extends Node2D

@export var door = Node
@export var default_state := false

@onready var on := default_state

@onready var leverActuatedSound = preload("res://Audio/SFX/Mechanical Lever Pull.wav");
@onready var sfxPlayer = $SFX;

func _ready():
	sfxPlayer.stream = leverActuatedSound;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		on = !on
		updateDoor()
		sfxPlayer.play(0);
		if on:
			$Sprite2D/AnimationPlayer.play("swing")
		else: 
			$Sprite2D/AnimationPlayer.play("swing", -1, -1, true)

func reset():
	$Sprite2D/AnimationPlayer.play("RESET")
	on = default_state
	updateDoor()
	
func updateDoor():
	door.setState(on)
