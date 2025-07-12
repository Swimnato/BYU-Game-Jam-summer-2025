extends Node

class_name PickupController
## Handles pickup and dropping of a "Gizmo" (RigidBody2D)

@export var socket_path		: NodePath		# The hold socket on the player
@export var pickup_area_path	: NodePath	# The path to the Area2D that defines which objects can grab the Gizmo
@export var pickup_action	: String = "Use"
@export var tween_time		: float = 0.15 # seconds for animation to fly to hand? Or we could just have it instant

var held : RigidBody2D = null
var candidates : Array[RigidBody2D] = []

var enabled = true;

@onready var socket : Node2D = get_node(socket_path)
@onready var area	: Area2D = get_node(pickup_area_path)


## INITIALIZATION
func _ready() -> void:
	area.body_entered.connect(onBodyEntered)
	area.body_exited.connect(onBodyExited)

## HANDLE INPUT
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed(pickup_action) and enabled):
		drop() if held else tryPickup()

## PICKUP AREA SIGNALS
func onBodyEntered(body: Node) -> void:
	if (body is RigidBody2D and body.is_in_group('pickable')): # TODO: make group 'pickable'
		candidates.append(body)

func onBodyExited(body: Node) -> void:
	if (body is RigidBody2D):
		candidates.erase(body)

## PICK-UP AND DROP LOGIC
func tryPickup() -> void:
	if (candidates.is_empty()):
		return
	candidates.sort_custom(compareDistance) # I know we won't have more than one gizmo but maybe?
	pickup(candidates[0])

func compareDistance(a, b) -> bool:
	return	a.global_position.distance_to(area.global_position) \
		  < b.global_position.distance_to(area.global_position)

func pickup(gizmo : RigidBody2D) -> void:
	held = gizmo
	
	# disable physics for gizmo
	gizmo.freeze = true
	gizmo.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC # TODO: correct mode?
	gizmo.sleeping = true
	gizmo.linear_velocity = Vector2.ZERO
	gizmo.angular_velocity = 0.0
	
	gizmo.get_node("Screen_Wrap").wrapEnabled = false;
	
	for child in gizmo.get_children():
		if (child is CollisionShape2D):
			child.disabled = true
			
	
	# "tween" is a word I just learned. don't know how I feel about it
	var tween := create_tween()
	tween.tween_property(
		gizmo, "global_position", socket.global_position, tween_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(Callable(self, "attachToSocket").bind(gizmo))

func attachToSocket(gizmo: RigidBody2D) -> void:
	gizmo.reparent(socket)
	gizmo.position = Vector2.ZERO # aligns gizmo exactly with the socket

func drop() -> void:
	var gizmo := held
	held = null
	if not gizmo:
		return
	
	gizmo.reparent(get_tree().current_scene) # release the gizmo back into the wild
	gizmo.global_rotation = 0
	
	# enable physics for gizmo
	gizmo.freeze = false
	gizmo.sleeping = false
	
	for child in gizmo.get_children():
		if (child is CollisionShape2D):
			child.disabled = false
	
	gizmo.apply_impulse(Vector2.ZERO, Vector2.DOWN * 400)
	
	gizmo.get_node("Screen_Wrap").wrapEnabled = true;
