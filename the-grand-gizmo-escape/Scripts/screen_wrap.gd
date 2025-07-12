extends Node2D

var wrapEnabled : bool = true;

@export var gizmoCam : Camera2D;

const scaleFactor : Vector2 = Vector2(1920.0, 1080.0); #This is the native resolution of the scene

func _ready() -> void:
	scale = (Vector2(get_viewport().size) / scaleFactor) / $"../GizmoCam".zoom;
	GlobalVars.gizmoCamPTR = gizmoCam;

func _process(delta: float) -> void:
	rotation = - $"..".rotation;

func _on_in_camera_body_exited(body: Node2D) -> void:
	if(body.name == "Player"):
		if(wrapEnabled):
			body.removeCloneFurthestFromCamera(global_position);
	else:
		if body is TileMap:
			handleTiles(body, enableCollision)
		else:
			disableCollision(body)
		

func _on_in_camera_body_entered(body: Node2D) -> void:
	if(body.name != "Player"):
		if body is TileMap:
			handleTiles(body, enableCollision)
		else:
			enableCollision(body)

func disableCollision(body: Node2D):
	body.set_collision_layer_value(1, false);
	body.set_collision_layer_value(8, true);

func enableCollision(body: Node2D):
	body.set_collision_layer_value(1, true);
	body.set_collision_layer_value(8, false);
	
func handleTiles(body: Node2D, fn: Callable):
	var pos = body.get_coords_for_body_rid(body)
	var tile_data = body.get_cell_tile_data(0, pos)
	if tile_data:
		var physics_layer = tile_data.get_custom_data("physics_layer")
		fn.call(physics_layer)

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
