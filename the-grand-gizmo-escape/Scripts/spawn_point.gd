extends Node2D

func _ready() -> void:
	$Sprite2D.visible = false;
	

func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.setSpawnPoint(global_position);
