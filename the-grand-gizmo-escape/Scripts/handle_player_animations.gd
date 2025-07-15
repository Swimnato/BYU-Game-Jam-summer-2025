extends Sprite2D

var default_scale
var jumped

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
	elif on_wall:
		$AnimationPlayer.play("wall_slide")
	elif jumping:
		if velocity.y < 0:
			$AnimationPlayer.play("jump", -1, 0.5)
		else:
			$AnimationPlayer.play("fall")
		if !jumped:
			jumped = true
	elif abs(velocity.x) == 0:
		$AnimationPlayer.play("idle")
		jumped = false
	else:
		$AnimationPlayer.stop()
		jumped = false
