extends Node2D

var countup : float = 0.0;
var explosionHappened : bool = false;
var menuAppeared : bool = false;
@onready var gameScn = preload("res://Scenes/testing/MovementDemo.tscn");
@onready var creditsScn = preload("res://Scenes/UI/Credits.tscn");

@onready var explodedTexture = preload("res://Assets/The_explosion.png");

@onready var prisionBuildingSprite = $"Prision Building";
@onready var menuButtons = $Main_Menu/Menu_Buttons;
@onready var menuCam = $Main_Menu/Main_Menu_Cam;

@export var startToExplosionDelay = 2;
@export var startToMenuDelay = 4;

func _ready() -> void:
	menuButtons.visible = false;

func _process(delta: float) -> void:
	if(!explosionHappened or !menuAppeared):
		countup += delta;
		if(countup >= startToExplosionDelay and !explosionHappened):
			prisionBuildingSprite.texture = explodedTexture;
			explosionHappened = true;
		elif(countup >= startToMenuDelay and !menuAppeared):
			menuAppeared = true;
			menuButtons.visible = true;
			


func _on_play_button_pressed() -> void:
	menuButtons.visible = false;
	prisionBuildingSprite.visible = false;
	var mainScn = gameScn.instantiate();
	menuCam.enabled = false;
	add_child(mainScn);


func _on_credits_pressed() -> void:
	menuButtons.visible = false;
	prisionBuildingSprite.visible = false;
	var scn = creditsScn.instantiate();
	menuCam.enabled = false;
	add_child(scn);


func _on_quit_pressed() -> void:
	get_tree().quit();
