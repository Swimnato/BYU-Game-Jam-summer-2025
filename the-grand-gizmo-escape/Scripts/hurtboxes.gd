extends Node2D

@export var player: Node
@export var hurtboxes: Array[Hurtbox] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for box in hurtboxes:
		box.connectEntered(onBodyEntered)

func onBodyEntered(body: Node):
	player.die()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
