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
	collision.set_deferred("disabled", to);
	if(!open && to):
		$Sprite2D/AnimationPlayer.play("open")
		position = positionOriginal + offsetOn;
	elif(open && !to):
		$Sprite2D/AnimationPlayer.play("open", -1, -1, true)
		position = positionOriginal;
	open = to;
	#sprite.visible = !open

func reset():
	$Sprite2D/AnimationPlayer.play("reset")
	setState(false)
