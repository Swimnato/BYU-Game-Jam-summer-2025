extends Node2D


@export var menuCam: Node2D;
@export var gizmo: Node2D;

signal pause_game;
signal unpause_game;

@export var firstButton : Control;

func _ready() -> void:
	visible = false;

func _process(delta: float) -> void:
	if(GlobalVars.inPauseMenu):
		global_position = gizmo.global_position;

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("Menu")):
		toggle_menu();
	elif(event.is_action_pressed("Up")):
		var current : Control = get_viewport().gui_get_focus_owner();
		if(current == null):
			firstButton.grab_focus();
	elif(event.is_action_pressed("Down")):
		var current : Control = get_viewport().gui_get_focus_owner();
		if(current == null):
			firstButton.grab_focus();

func toggle_menu():
	GlobalVars.inPauseMenu = !GlobalVars.inPauseMenu;
	visible = GlobalVars.inPauseMenu;
	menuCam.enabled = GlobalVars.inPauseMenu;
	GlobalVars.gizmoCamPTR.enabled = !GlobalVars.inPauseMenu;
	if(GlobalVars.inPauseMenu):
		pause_game.emit();
	else:
		unpause_game.emit();

func _on_resume_pressed() -> void:
	toggle_menu();


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene();


func _on_quit_pressed() -> void:
	get_tree().quit()
