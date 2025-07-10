extends Node2D

var wrapEnabled : bool = true;

func _on_in_camera_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		if(wrapEnabled):
			body.queue_free();
