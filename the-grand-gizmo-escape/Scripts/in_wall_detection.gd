extends Node2D

@export var player : CharacterBody2D;
@export var in_wall_threshold = 2;

func _ready() -> void:
	for child in get_children():
		if child is RayCast2D:
			child.add_exception_rid(player.get_rid());

func _process(delta: float) -> void:
	if(get_parent().visible):
		var insideWallCount = 0;
		for child in get_children():
			if child is RayCast2D:
				child.force_raycast_update();
				if(child.is_colliding() and !(child.get_collider() is Area2D)):
					print(child.name);
					print(child.get_collider());
					insideWallCount += 1;
		if(insideWallCount >= in_wall_threshold):
			player.die();
