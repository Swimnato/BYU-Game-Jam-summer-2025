extends Sprite2D

var default_scale
var jumped
var was_on_wall

func _ready():
	jumped = false
	default_scale = self.scale.x

func face(dir):
	self.scale.x = -default_scale if dir < 0 else default_scale if dir > 0 else self.scale.x

func handleAnimation(velocity, jumping, on_wall):
	face(velocity.x)
	if abs(velocity.x) > 0 and !jumping:
		$AnimationPlayer.play("walk")
		jumped = false
		was_on_wall = false
	elif on_wall:
		$AnimationPlayer.play("wall_slide")
		was_on_wall = true
	elif jumping:
		if was_on_wall:
			if velocity.y < 0:
				$AnimationPlayer.play("wall_jump", -1, 0.5)
			else:
				$AnimationPlayer.play("fall")
		else:
			if velocity.y < 0:
				$AnimationPlayer.play("jump", -1, 0.5)
			else:
				$AnimationPlayer.play("fall")
		if !jumped:
			jumped = true
	elif abs(velocity.x) == 0:
		$AnimationPlayer.play("idle")
		jumped = false
		was_on_wall = false
	else:
		$AnimationPlayer.stop()
		jumped = false
		was_on_wall = false
