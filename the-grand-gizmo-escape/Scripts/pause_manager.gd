extends Node2D


func pause():
	process_mode = PROCESS_MODE_DISABLED;


func unpause():
	process_mode = PROCESS_MODE_INHERIT;
