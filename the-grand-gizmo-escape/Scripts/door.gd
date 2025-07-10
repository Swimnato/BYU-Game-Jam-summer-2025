extends Node2D

@onready var collision := $StaticBody2D/CollisionShape2D
@onready var sprite := $Sprite2D

var open := false

func setState(to):
	open = to
	collision.set_deferred("disabled", open)
	sprite.visible = !open
