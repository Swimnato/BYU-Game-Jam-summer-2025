extends Node2D

var wrapEnabled : bool = true;

const scaleFactor : Vector2 = Vector2(1920.0, 1080.0); #This is the native resolution of the scene

func _ready() -> void:
	scale = (Vector2(get_viewport().size) / scaleFactor) / $"../GizmoCam".zoom;

func _process(delta: float) -> void:
	rotation = - $"..".rotation;

func _on_in_camera_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		if(wrapEnabled):
			body.removeCloneFurthestFromCamera(global_position);
	else:
		body.set_collision_layer_value(1, false);
		body.set_collision_layer_value(8, true);

func _on_in_camera_body_entered(body: Node2D) -> void:
	if(body.name != "Player"):
		body.set_collision_layer_value(1, true);
		body.set_collision_layer_value(8, false);


func _on_sidebox_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		if(wrapEnabled):
			body.removeCloneFurthestFromCamera(global_position);


func _on_top_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scaleFactor * Vector2(0,1) + Vector2(0,1));


func _on_bottom_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scaleFactor * Vector2(0,-1) + Vector2(0,-1));


func _on_left_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scaleFactor * Vector2(1,0) + Vector2(1,0));


func _on_right_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scaleFactor * Vector2(-1,0) + Vector2(-1,0));
