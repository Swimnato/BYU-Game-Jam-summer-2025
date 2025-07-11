extends Node2D

@onready var TextureAndCollision = preload("res://Scenes/Player/Player_Texture_And_Collision.tscn");

func _ready() -> void:
	var mainClone = TextureAndCollision.instantiate();
	add_child(mainClone);

func _removeChild(toRemove : Node):
	toRemove.queue_free();

func _AddChild():
	pass
