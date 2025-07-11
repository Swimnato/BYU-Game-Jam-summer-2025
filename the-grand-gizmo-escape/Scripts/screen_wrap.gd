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
			body.queue_free();
	else:
		print("Body exited: ", body);
		body.set_collision_layer_value(1, false);
		body.set_collision_layer_value(8, true);

func _on_in_camera_body_entered(body: Node2D) -> void:
	if(body.name != "Player"):
		print("Body entered: ", body);
		body.set_collision_layer_value(1, true);
		body.set_collision_layer_value(8, false);
