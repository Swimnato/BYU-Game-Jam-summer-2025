extends Node2D


func _ready() -> void:
	var mainClone = TextureAndCollision.instantiate();
	add_child(mainClone);

func _removeChild(toRemove : Node):
	toRemove.queue_free();

func _AddChild():
	pass
