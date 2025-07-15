extends Node2D

@onready var collision := $StaticBody2D/CollisionShape2D
@onready var sprite := $Sprite2D
var offsetOn := Vector2(1,1);
var positionOriginal :Vector2;

var open

func _ready() -> void:
	positionOriginal = position;

func _onready():
	open = false;

func setState(to):
	open = to
	collision.set_deferred("disabled", open)
	if(open):
		position = positionOriginal + offsetOn;
	else:
		position = positionOriginal;
	sprite.visible = !open

func reset():
	setState(false)
