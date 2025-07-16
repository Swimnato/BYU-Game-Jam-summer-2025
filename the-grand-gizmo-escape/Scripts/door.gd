extends Node2D

@onready var collision := $StaticBody2D/CollisionShape2D
@onready var sprite := $Sprite2D
var offsetOn := Vector2(1,1);
var positionOriginal :Vector2;

@export var open_by_default = false

var open

func _ready() -> void:
	positionOriginal = position;
	if(open_by_default):
		setState(open_by_default)

func _onready():
	open = open_by_default;


func setState(to):
	open = to
	collision.set_deferred("disabled", open)
	if(open):
		$Sprite2D/AnimationPlayer.play("open")
		position = positionOriginal + offsetOn;
	else:
		$Sprite2D/AnimationPlayer.play("open", -1, -1, true)
		position = positionOriginal;
	#sprite.visible = !open

func reset():
	$Sprite2D/AnimationPlayer.play("reset")
	setState(open_by_default)
