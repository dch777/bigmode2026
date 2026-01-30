class_name Arm extends RigidBody2D

# func _integrate_forces(state: PhysicsDirectBodyState2D):
# 	var facing = Vector2.from_angle(rotation)
# 	state.apply_torque(1000 * facing.angle_to(get_local_mouse_position()))

func _physics_process(delta):
	# var facing = Vector2.from_angle(rotation)
	# print(get_local_mouse_position().angle_to(facing))
	look_at(get_global_mouse_position())
