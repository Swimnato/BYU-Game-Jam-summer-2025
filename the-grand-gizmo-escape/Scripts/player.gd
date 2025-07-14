extends CharacterBody2D

@export var SPEED = 1500.0
@export var ACCELERATION = 8500.0
@export var FRICTION = 4500.0

@export var GRAVITY = 6000.0
@export var FALL_GRAVITY = 7500.0
@export var FAST_FALL_GRAVITY = 9000.0
@export var WALL_GRAVITY = 50.0

@export var JUMP_VELOCITY = -3000.0
@export var WALL_JUMP_VELOCITY = -3000.0
@export var WALL_JUMP_PUSHBACK = 3000.0 # 300.0

@export var INPUT_BUFFER_PATIENCE = 0.1
@export var COYOTE_TIME = 0.08

@export var TERMINAL_VELOCITY_SQUARED = 7500 ** 2;

var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available : bool = true
var A_Side = true;

@onready var pickupControllers = [$A_Side/PickupController_A, $B_Side/PickupController_B];
@onready var collisions: Array[CollisionShape2D] = [$Collision_A, $Collision_B];
@onready var sides = [$A_Side, $B_Side];

const LAYER_SPIKES = 1 << 2
const LAYER_GIZMO = 1 << 1

var spawn_point: Vector2

signal player_death

@onready var sprites = [$A_Side/Texture_A, $B_Side/Texture_B]

#func _unhandled_input(event: InputEvent) -> void:
	#if (event.is_action_pressed("Use")):
		#addClone(Vector2(500,0));

func _ready():
	# Setup input buffer timer
	GlobalVars.playerPTR = self;
	disableSide(1);
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)
	
	# Setup coyote timer
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyoteTimeout)

func _physics_process(delta: float) -> void:
	var horizontal_input = Input.get_axis("Left", "Right")
	var jump_attempted = Input.is_action_just_pressed("Jump")
	
	# Handle jumping
	if (jump_attempted or input_buffer.time_left > 0):
		if (coyote_jump_available):
			velocity.y = JUMP_VELOCITY
			coyote_jump_available = false
		elif (is_on_wall() and horizontal_input != 0):
			velocity.y = WALL_JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK * -sign(horizontal_input)
		elif (jump_attempted):
			input_buffer.start()
	
	# Fall faster when you don't hold jump key
	if (Input.is_action_just_released("Jump") and velocity.y < 0):
		velocity.y = JUMP_VELOCITY / 4
	
	if (is_on_floor()):
		coyote_jump_available = true
		coyote_timer.stop()
	else:
		if coyote_jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()
		velocity.y += getGravity(horizontal_input) * delta
		
	# Horizontal motion
	var floor_damping : float = 1.0 if is_on_floor() else 0.2
	# var dash_multiplier : float 2.0 if Input.ison_pressed("Dash")
	if (horizontal_input):
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
	
	var velocitySquared = velocity.length_squared();
	if(velocitySquared > TERMINAL_VELOCITY_SQUARED):
		velocity = velocity * (TERMINAL_VELOCITY_SQUARED / velocitySquared);
	
	move_and_slide();
	handleAnimations(velocity, !is_on_floor())
	
	for object in range(get_slide_collision_count()):
		var collider = get_slide_collision(object).get_collider();
		if(collider.is_in_group("Conveyer Belt")):
			if(collider.direction == collider.DIRECTIONS.LEFT):
				velocity.x = -collider.beltSpeed;
			elif(collider.direction == collider.DIRECTIONS.RIGHT):
				velocity.x = collider.beltSpeed;
			elif(collider.direction == collider.DIRECTIONS.UP):
				pass
			elif(collider.direction == collider.DIRECTIONS.DOWN):
				pass
	
	# reset level
	if(Input.is_action_just_released("ResetLvl")):
		get_tree().reload_current_scene()


func getGravity(input_dir : float = 0) -> float:
	# if Input.is_action_pressed("FastFall")
	#	return FAST_FALL_GRAVITY
	if is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		return WALL_GRAVITY
	return GRAVITY if (velocity.y < 0) else FALL_GRAVITY


func coyoteTimeout():
	# reset coyote jump when you timeout
	coyote_jump_available = false


func die():
	self.position = spawn_point
	player_death.emit()
	print("TODO respawn gizmo logic")

func setSpawnPoint(pos: Vector2):
	spawn_point = pos

func addClone(offset : Vector2):
	if(!sides[0].visible or !sides[1].visible):
		if(A_Side):
			enableSide(1);
			var newCoords = sides[0].global_position + offset;
			sides[1].global_position = newCoords;
			collisions[1].global_position = newCoords;
		else:
			enableSide(0);
			var newCoords = sides[1].global_position + offset;
			sides[0].global_position = newCoords;
			collisions[0].global_position = newCoords;

func disableSide(side: int):
	pickupControllers[side].enabled = false;
	collisions[side].set_deferred("disabled", true);
	sides[side].visible = false;

func enableSide(side: int):
	pickupControllers[side].enabled = true;
	collisions[side].set_deferred("disabled", false);
	sides[side].visible = true;

func removeCloneFurthestFromCamera(cameraPos : Vector2):
	if(sides[0].visible and sides[1].visible):
		var aToCam = (sides[0].global_position - cameraPos).length_squared();
		var bToCam = (sides[1].global_position - cameraPos).length_squared();
		if(aToCam > bToCam):
			A_Side = false;
			disableSide(0);
		else:
			A_Side = true;
			disableSide(1);

func handleAnimations(velocity: Vector2, jumping: bool):
	for sprite in sprites:
		sprite.handleAnimation(velocity, jumping)
