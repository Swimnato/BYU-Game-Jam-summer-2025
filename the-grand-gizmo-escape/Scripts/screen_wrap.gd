extends Node2D

var wrapEnabled : bool = true;

@export var gizmoCam : Camera2D;

const scaleFactor : Vector2 = Vector2(1920.0, 1080.0); #This is the native resolution of the scene

var solidAreas : Array[Vector2];

func _ready() -> void:
	scale = (Vector2(get_viewport().size) / scaleFactor) / $"../GizmoCam".zoom;
	GlobalVars.gizmoCamPTR = gizmoCam;

func _process(delta: float) -> void:
	rotation = - $"..".rotation;
	solidAreas = checkForCollisionsBetweenSides(global_position + scaleFactor/2 * Vector2(1,-1), global_position + scaleFactor/2 );
	queue_redraw();

func _draw() -> void:
	if(len(solidAreas) == 0):
		return;
	for area in solidAreas:
		print(area); 
		draw_rect(Rect2(Vector2(scaleFactor.x/2 - 10, to_local(area).y),Vector2(scaleFactor.x/2 + 10, to_local(Vector2(0, area.x)).y)), Color.RED);

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

func checkForCollisionsBetweenSides(point_a : Vector2, point_b : Vector2):
	var returnVal: Array[Vector2];
	var bodiesFound: Array;
	
	var space = get_world_2d().direct_space_state;
	var searchingForObjects = true;
	
	#find bottom coord
	while(searchingForObjects):
		var query = PhysicsRayQueryParameters2D.create(point_a, point_b);
		query.exclude = bodiesFound;
		var resultsFromCast = space.intersect_ray(query);
		if(!resultsFromCast):
			searchingForObjects = false;
		else:
			bodiesFound.append(resultsFromCast.rid);
			if(point_a.x == point_b.x):
				returnVal.append(Vector2(resultsFromCast.position.y, 0));
			elif(point_a.y == point_b.y):
				returnVal.append(Vector2(resultsFromCast.position.x, 0));
	
	#check from the opposite direction (if you start a raycast in the middle of an object it won't detect it)
	while(searchingForObjects):
		var query = PhysicsRayQueryParameters2D.create(point_b, point_a);
		query.exclude = bodiesFound;
		var resultsFromCast = space.intersect_ray(query);
		if(!resultsFromCast):
			searchingForObjects = false;
		else:
			bodiesFound.append(resultsFromCast.rid);
			if(point_a.x == point_b.x):
				returnVal.append(Vector2(point_a.y, resultsFromCast.position.y));
			elif(point_a.y == point_b.y):
				returnVal.append(Vector2(point_a.x, resultsFromCast.position.x));
	
	#find top coords of first found bodies
	for body in range(len(bodiesFound)):
		if(returnVal[body].y == 0):
			var exclusionList = bodiesFound.duplicate(true);
			exclusionList.remove_at(body);
			var query = PhysicsRayQueryParameters2D.create(point_b, point_a);
			query.exclude = exclusionList;
			var resultsFromCast = space.intersect_ray(query);
			if(resultsFromCast):
				if(point_a.x == point_b.x):
					returnVal[body].y = resultsFromCast.position.y;
				elif(point_a.y == point_b.y):
					returnVal[body].y = resultsFromCast.position.x;
			else:
				if(point_a.x == point_b.x):
					returnVal[body].y = point_b.y;
				elif(point_a.y == point_b.y):
					returnVal[body].y = point_b.x;
	
	return returnVal;




var h;
