extends Node2D

@export var player: Node
@export var central_spawn_point: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(central_spawn_point != null):
		player.setSpawnPoint(central_spawn_point.global_position)
	player.player_death.connect(func(): get_tree().call_group("resettable", "reset"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
