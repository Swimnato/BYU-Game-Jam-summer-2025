extends Sprite2D

var default_scale

func _ready():
	default_scale = self.scale.x

func face(dir):
	self.scale.x = -default_scale if dir < 0 else default_scale if dir > 0 else self.scale.x

func handleAnimation(velocity, jumping):
	face(velocity.x)
	if abs(velocity.x) > 0 and !jumping:
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.stop()
