extends StaticBody2D

enum DIRECTIONS {UP, DOWN, RIGHT, LEFT};
enum PIECES {END_LEFT, MIDDLE, END_RIGHT};

@export var direction : DIRECTIONS;
@export var piece : PIECES;
@export var beltSpeed : int = 2000;
