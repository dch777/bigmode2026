extends RigidBody2D

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position

	var target_angle = to_mouse.angle()
	var angle_diff = wrapf(target_angle - rotation, -PI, PI)
	
	var stiffness := 1200.0
	var dampness := 200.0

	var torque = angle_diff * stiffness - angular_velocity * dampness
	apply_torque(torque)
