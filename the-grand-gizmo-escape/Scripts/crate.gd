extends RigidBody2D

var start_pos;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = self.position


func reset() -> void:
	self.position = start_pos
