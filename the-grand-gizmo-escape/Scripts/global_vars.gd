extends Node

var inPauseMenu = false;

var gizmoCamPTR : Camera2D;
var playerPTR : CharacterBody2D;

@export var level = 0;
@export var maxHealth = 10;
@export var health = maxHealth;
