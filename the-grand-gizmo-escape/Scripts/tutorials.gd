extends Node2D

@onready var tutorials = [$GizmoTutorial, $JumpTutorial, $MoveTutorial];
var disabled : Array[bool] = [false, false, false];
@export var fadeTime = 2.5;

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("Use") and !disabled[0]):
		var tween := create_tween();
		tween.tween_property(tutorials[0], "self_modulate:a", 0, fadeTime);
		tween.tween_callback(Callable(tween, "queue_free"));
		disabled[0] = true;
	elif(event.is_action_pressed("Jump") and !disabled[1]):
		var tween := create_tween();
		tween.tween_property(tutorials[1], "self_modulate:a", 0, fadeTime);
		tween.tween_callback(Callable(tween, "queue_free"));
		disabled[1] = true;
	elif((event.is_action_pressed("Up") or event.is_action_pressed("Down") or event.is_action_pressed("Right") or event.is_action_pressed("Left")) and !disabled[2]):
		var tween := create_tween();
		tween.tween_property(tutorials[2], "self_modulate:a", 0, fadeTime);
		tween.tween_callback(Callable(tween, "queue_free"));
		disabled[2] = true;
		
		#tutorials[0].self_modulate.a = 
