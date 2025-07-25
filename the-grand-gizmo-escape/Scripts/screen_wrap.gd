extends Node2D

var wrapEnabled : bool = true;

@export var gizmoCam : Camera2D;

const scaleFactor : Vector2 = Vector2(1920.0, 1080.0); #This is the native resolution of the scene
const defaultScaling : Vector2 = Vector2(2.0/3.0,2.0/3.0)

@export var screenWrapBlockerLeft : StaticBody2D;
@export var screenWrapBlockerRight : StaticBody2D;
@export var screenWrapBlockerUp : StaticBody2D;
@export var screenWrapBlockerDown : StaticBody2D;

@export var debugRaycastingEdges : bool = false;

@export var offScreenOffset = 100;


enum SIDES {LEFT, RIGHT, UP, DOWN};

@export var sideBlockSize = 1;

func _ready() -> void:
	scale = defaultScaling / gizmoCam.zoom;
	GlobalVars.gizmoCamPTR = gizmoCam;

func _process(_delta: float) -> void:
	rotation = - $"..".rotation;
	if(debugRaycastingEdges):
		queue_redraw();
	else:
		processSideBlocking(SIDES.LEFT);
		processSideBlocking(SIDES.RIGHT);
		processSideBlocking(SIDES.UP);
		processSideBlocking(SIDES.DOWN);


func _draw() -> void:
	if(debugRaycastingEdges):
		processSideBlocking(SIDES.LEFT);
		processSideBlocking(SIDES.RIGHT);
		processSideBlocking(SIDES.UP);
		processSideBlocking(SIDES.DOWN);
		
func _on_in_camera_body_exited(body: Node2D) -> void:
	if body is TileMap:
		handleTiles(body, disableCollision)
	elif(!body.is_in_group("Collision_Off_Screen_Enabled") and body.name != "Player"):
		disableCollision(body)

func _on_in_camera_body_entered(body: Node2D) -> void:
	if(body.name != "Player"):
		if body is TileMap:
			handleTiles(body, enableCollision)
		else:
			enableCollision(body)

func disableCollision(body: Node2D):
	if body:
		body.set_collision_layer_value(1, false);
		body.set_collision_layer_value(8, true);

func enableCollision(body: Node2D):
	if body:
		body.set_collision_layer_value(1, true);
		body.set_collision_layer_value(8, false);
	
func handleTiles(body, fn: Callable):
	var pos = body.get_coords_for_body_rid(body);
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
		body.addClone(scale * scaleFactor * Vector2(0,1) + Vector2(0,1));


func _on_bottom_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scale * scaleFactor * Vector2(0,-1) + Vector2(0,-1));


func _on_left_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scale * scaleFactor * Vector2(1,0) + Vector2(1,0));


func _on_right_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.addClone(scale * scaleFactor * Vector2(-1,0) + Vector2(-1,0));

func checkForCollisionsBetweenSides(point_a : Vector2, point_b : Vector2):
	var returnVal: Array[Vector2];
	var bodiesFound: Array;
	var IgnoredObjects : Array;
	if(GlobalVars.playerPTR != null):
		IgnoredObjects.append(GlobalVars.playerPTR.get_rid());
		IgnoredObjects.append(screenWrapBlockerDown.get_rid());
		IgnoredObjects.append(screenWrapBlockerRight.get_rid());
		IgnoredObjects.append(screenWrapBlockerUp.get_rid());
		IgnoredObjects.append(screenWrapBlockerLeft.get_rid());
	
	var space = get_world_2d().direct_space_state;
	var searchingForObjects = true;
	
	#find bottom coord
	while(searchingForObjects):
		var query = PhysicsRayQueryParameters2D.create(point_a, point_b);
		query.exclude = bodiesFound + IgnoredObjects;
		var resultsFromCast = space.intersect_ray(query);
		if(!resultsFromCast):
			searchingForObjects = false;
		else:
			bodiesFound.append(resultsFromCast.rid);
			if(debugRaycastingEdges):
				draw_circle(to_local(resultsFromCast.position), 20, Color.AQUA);
			if(point_a.x == point_b.x):
				returnVal.append(Vector2(to_local(resultsFromCast.position).y, -999999));
			elif(point_a.y == point_b.y):
				returnVal.append(Vector2(to_local(resultsFromCast.position).x, -999999));
	
	searchingForObjects = true;
	#check from the opposite direction (if you start a raycast in the middle of an object it won't detect it)
	while(searchingForObjects):
		var query = PhysicsRayQueryParameters2D.create(point_b, point_a);
		query.exclude = bodiesFound + IgnoredObjects;
		var resultsFromCast = space.intersect_ray(query);
		if(!resultsFromCast):
			searchingForObjects = false;
		else:
			bodiesFound.append(resultsFromCast.rid);
			if(debugRaycastingEdges):
				draw_circle(to_local(resultsFromCast.position), 15, Color.MEDIUM_SEA_GREEN);
			if(point_a.x == point_b.x):
				returnVal.append(Vector2(to_local(point_a).y, to_local(resultsFromCast.position).y));
			elif(point_a.y == point_b.y):
				returnVal.append(Vector2(to_local(point_a).x, to_local(resultsFromCast.position).x));
	
	#find top coords of first found bodies
	for body in range(len(bodiesFound)):
		if(body + 1 > len(returnVal)):
			#There is a weird crashing bug where bodies found has objects but the returnVal is empty, 
			#it is only usually on one single frame though so I just put this so that it wouldn't 
			#crash and it will re-calculate everything on the next frame.
			break;
		if(returnVal[body].y == -999999):
			var exclusionList = bodiesFound.duplicate(true);
			exclusionList.erase(bodiesFound[body]);
			var query = PhysicsRayQueryParameters2D.create(point_b, point_a);
			query.exclude = exclusionList + IgnoredObjects;
			var resultsFromCast = space.intersect_ray(query);
			if(resultsFromCast):
				if(debugRaycastingEdges):
					draw_circle(to_local(resultsFromCast.position), 10, Color.PURPLE);
				if(point_a.x == point_b.x):
					returnVal[body].y = to_local(resultsFromCast.position).y;
				elif(point_a.y == point_b.y):
					returnVal[body].y = to_local(resultsFromCast.position).x;
			else:
				if(point_a.x == point_b.x):
					returnVal[body].y = to_local(point_b).y;
				elif(point_a.y == point_b.y):
					returnVal[body].y = to_local(point_b).x;
	
	return returnVal;

func findPosAndSizeOfBlocking(side: SIDES, minMax: Vector2):
	var returnVal : Array[Vector2];
	if(side == SIDES.LEFT):
		returnVal.append(Vector2(-scaleFactor.x/2.0 + sideBlockSize/2.0, (minMax.x + minMax.y)/2.0));
		returnVal.append(Vector2(sideBlockSize,abs(minMax.x - minMax.y)-1));
	elif(side == SIDES.RIGHT):
		returnVal.append(Vector2(scaleFactor.x/2.0 - sideBlockSize/2.0, (minMax.x + minMax.y)/2.0));
		returnVal.append(Vector2(sideBlockSize,abs(minMax.x - minMax.y)-1));
	elif(side == SIDES.UP):
		returnVal.append(Vector2((minMax.x + minMax.y)/2.0, -scaleFactor.y/2.0 + sideBlockSize/2.0));
		returnVal.append(Vector2(abs(minMax.x - minMax.y)-1,sideBlockSize));
	elif(side == SIDES.DOWN):
		returnVal.append(Vector2((minMax.x + minMax.y)/2.0, scaleFactor.y/2.0 - sideBlockSize/2.0));
		returnVal.append(Vector2(abs(minMax.x - minMax.y)-1,sideBlockSize));
	return returnVal;

func processSideBlocking(side : SIDES):
	var startPoints;
	var endPoints;
	var solidAreas : Array[Vector2];
	var screenColiderObject : StaticBody2D;
	
	if(side == SIDES.LEFT):
		startPoints = [to_global(scaleFactor/2 * Vector2(1,-1))];
		startPoints.append(startPoints[0] + Vector2(offScreenOffset, 0));
		startPoints.append(startPoints[0] + Vector2(offScreenOffset * 2, 0));
		endPoints = [to_global(scaleFactor/2)]; 
		endPoints.append(endPoints[0] + Vector2(offScreenOffset, 0));
		endPoints.append(endPoints[0] + Vector2(offScreenOffset * 2, 0));
		screenColiderObject = screenWrapBlockerLeft;
	elif(side == SIDES.RIGHT):
		startPoints = [to_global(scaleFactor/2 * Vector2(-1,-1))];
		startPoints.append(startPoints[0] + Vector2(-offScreenOffset, 0));
		startPoints.append(startPoints[0] + Vector2(-offScreenOffset * 2, 0));
		endPoints = [to_global(scaleFactor/2 * Vector2(-1,1))];
		endPoints.append(endPoints[0] + Vector2(-offScreenOffset, 0));
		endPoints.append(endPoints[0] + Vector2(-offScreenOffset * 2, 0));
		screenColiderObject = screenWrapBlockerRight;
	elif(side == SIDES.UP):
		startPoints = [to_global(scaleFactor/2 * Vector2(-1,1))];
		startPoints.append(startPoints[0] + Vector2(0, offScreenOffset));
		startPoints.append(startPoints[0] + Vector2(0, offScreenOffset * 2));
		endPoints = [to_global(scaleFactor/2 * Vector2(1,1))];
		endPoints.append(endPoints[0] + Vector2(0, offScreenOffset));
		endPoints.append(endPoints[0] + Vector2(0, offScreenOffset * 2));
		screenColiderObject = screenWrapBlockerUp;
	elif(side == SIDES.DOWN):
		startPoints = [to_global(scaleFactor/2 * Vector2(-1,-1))];
		startPoints.append(startPoints[0] + Vector2(0, -offScreenOffset));
		startPoints.append(startPoints[0] + Vector2(0, -offScreenOffset * 2));
		endPoints = [to_global(scaleFactor/2 * Vector2(1,-1))];
		endPoints.append(endPoints[0] + Vector2(0, -offScreenOffset));
		endPoints.append(endPoints[0] + Vector2(0, -offScreenOffset * 2));
		screenColiderObject = screenWrapBlockerDown;
	
	solidAreas = checkForCollisionsBetweenSides(startPoints[0], endPoints[0]);
	solidAreas += checkForCollisionsBetweenSides(startPoints[1], endPoints[1]);
	solidAreas += checkForCollisionsBetweenSides(startPoints[2], endPoints[2]);
	for child : CollisionShape2D in screenColiderObject.get_children():
		var stillExists = false;
		if(solidAreas.is_empty()):
			child.queue_free();
		for area : Vector2 in solidAreas:
			var rectSizeAndPos = findPosAndSizeOfBlocking(side, area);
			var rectPos : Vector2 = rectSizeAndPos[0];
			var rectSize : Vector2 = rectSizeAndPos[1];
			if(child.position == rectPos and child.shape.size == rectSize):
				stillExists = true;
				solidAreas.erase(area);
		if(!stillExists):
			child.queue_free();
	if(solidAreas.is_empty()):
		return;
	for area in solidAreas:
		var rectSizeAndPos = findPosAndSizeOfBlocking(side, area);
		var rectPos : Vector2 = rectSizeAndPos[0];
		var rectSize : Vector2 = rectSizeAndPos[1];
		var shape : RectangleShape2D = RectangleShape2D.new();
		shape.set_size(abs(rectSize));
		var newCollider : CollisionShape2D = CollisionShape2D.new()
		newCollider.position = rectPos;
		newCollider.shape = shape
		screenColiderObject.add_child(newCollider);
