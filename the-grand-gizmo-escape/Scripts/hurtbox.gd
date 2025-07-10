extends Node2D
class_name Hurtbox

@onready var area := $area
#@onready var area := Area2D.new()
#@onready var collision := CollisionShape2D.new()
#@onready var rect := RectangleShape2D.new()

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#collision.set_shape()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func connectEntered(fn: Callable) -> void:
	area.body_entered.connect(fn)
