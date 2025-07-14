extends AudioStreamPlayer2D

@onready var hoveredSFX = [preload("res://Audio/SFX/UI Button Hover_1.wav"),
							preload("res://Audio/SFX/UI Button Hover_2.wav"),
							preload("res://Audio/SFX/UI Button Hover_3.wav"),
							preload("res://Audio/SFX/UI Button Hover_4.wav"),
							preload("res://Audio/SFX/UI Button Hover_5.wav")];
@onready var acceptSFX = preload("res://Audio/SFX/UI Accept.wav");

func playHovered():
	stop();
	stream = hoveredSFX[randi_range(0,4)];
	play();

func playAccept():
	stop();
	stream = acceptSFX;
	play();
