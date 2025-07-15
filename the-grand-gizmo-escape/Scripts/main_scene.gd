extends Node2D

var countup : float = 0.0;
var timeSinceBlinkText = 0.0;
var explosionHappened : bool = false;
var bldngRasiated : bool = false;
var menuAppeared : bool = false;
@onready var gameScn = preload("res://Scenes/Levels/Level_Swimn.tscn");
@onready var creditsScn = preload("res://Scenes/UI/Credits.tscn");

@onready var explodedTexture = preload("res://Assets/The_explosion.png");
@onready var postExplodedTexture = preload("res://Assets/rasiated.png");

@onready var Explosion = preload("res://Audio/SFX/Explosion.wav");
@onready var MainMenuMusic = preload("res://Audio/Music/Main Menu Music (120 bpm).wav");
@onready var TitleScreenTheme = preload("res://Audio/Music/Title Screen (115 bpm, 2-29).wav");
@onready var MainTheme = preload("res://Audio/Music/Main Theme (105 bpm, 2-102).wav");

@onready var prisionBuildingSprite = $"Prision Building";
@onready var menuButtons = $Main_Menu;
@onready var menuCam = $Main_Menu_Cam;
@onready var blowupTxt = $"Blowup Text";
@onready var playBtn = $"Main_Menu/Menu_Buttons/Play Button";
@onready var musicBox = $MusicBox;

@export var startToRasiatedDelay = 0.5;
@export var startToMenuDelay = 2;
@export var blinkDuration = 1.5;

@export var mainMenuBegRot : float = 20;
var mainMenuEndRot : float;
@export var mainMenuBegPos : Vector2 = Vector2(30,20);
var mainMenuEndPos : Vector2;
@export var mainMenuBegScale: Vector2 = Vector2(.01,.01);
var mainMenuEndScale : Vector2;


func _ready() -> void:
	menuButtons.visible = false;
	blowupTxt.visible = true;
	mainMenuEndRot = menuButtons.rotation;
	mainMenuEndPos = menuButtons.position;
	mainMenuEndScale = menuButtons.scale;
	musicBox.stream = MainMenuMusic;
	musicBox.connect("finished", Callable(self,"playSongAgain"));
	musicBox.play();


func _process(delta: float) -> void:
	if(explosionHappened):
		countup += delta;
		if(countup > startToRasiatedDelay and !bldngRasiated):
			bldngRasiated = true;
			prisionBuildingSprite.texture = postExplodedTexture;
		elif(countup >= startToMenuDelay and !menuAppeared):
			menuAppeared = true;
			playBtn.grab_focus();
			musicBox.stop();
			musicBox.stream = TitleScreenTheme;
			musicBox.play();
	else:
		timeSinceBlinkText += delta;
		if(timeSinceBlinkText > blinkDuration):
			timeSinceBlinkText = 0.0;
			blowupTxt.visible = !blowupTxt.visible;


func playSongAgain():
	musicBox.play();


func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("Use") and !explosionHappened):
		prisionBuildingSprite.texture = explodedTexture;
		explosionHappened = true;
		blowupTxt.visible = false;
		menuButtons.visible = true;
		menuButtons.rotation = mainMenuBegRot;
		menuButtons.position = mainMenuBegPos;
		menuButtons.scale = mainMenuBegScale;
		var tween : Tween = self.create_tween();
		tween.set_parallel();
		tween.tween_property(menuButtons, "position", mainMenuEndPos, startToMenuDelay);
		tween.tween_property(menuButtons, "rotation", mainMenuEndRot, startToMenuDelay);
		tween.tween_property(menuButtons, "scale", mainMenuEndScale, startToMenuDelay);
		musicBox.stop();
		musicBox.stream = Explosion;
		musicBox.play();


func _on_play_button_pressed() -> void:
	if(menuAppeared):
		musicBox.stream = MainTheme;
		musicBox.play();
		menuButtons.visible = false;
		prisionBuildingSprite.visible = false;
		var mainScn = gameScn.instantiate();
		menuCam.enabled = false;
		add_child(mainScn);


func _on_credits_pressed() -> void:
	if(menuAppeared):
		menuButtons.visible = false;
		prisionBuildingSprite.visible = false;
		var scn = creditsScn.instantiate();
		menuCam.enabled = false;
		add_child(scn);


func _on_quit_pressed() -> void:
	if(menuAppeared):
		get_tree().quit();
