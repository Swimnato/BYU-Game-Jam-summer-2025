extends RigidBody2D

func _ready() -> void:
	set_contact_monitor(true);
	set_max_contacts_reported(3);

func _physics_process(delta: float) -> void:
	for collider in get_colliding_bodies():
		if(collider.is_in_group("Conveyer Belt")):
			if(collider.direction == collider.DIRECTIONS.LEFT):
				linear_velocity.x = -collider.beltSpeed;
				angular_velocity = 0;
			elif(collider.direction == collider.DIRECTIONS.RIGHT):
				linear_velocity.x = collider.beltSpeed;
				angular_velocity = 0;
			elif(collider.direction == collider.DIRECTIONS.UP):
				pass
			elif(collider.direction == collider.DIRECTIONS.DOWN):
				pass
