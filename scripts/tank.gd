class_name Tank extends RigidBody2D

@export var skidding: bool = false

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var throttle = Input.get_axis("decelerate", "accelerate")
	var steering = Input.get_axis("turn_left", "turn_right")
	var facing = Vector2.from_angle(rotation)

	var forward_velocity = state.linear_velocity.project(facing)
	var sideways_velocity = state.linear_velocity.slide(facing)

	var scaled_speed = forward_velocity.length() / 100.0
	var acceleration_curve = 100 * (scaled_speed + 0.5) * exp(-(scaled_speed - 2.0))
	var throttle_force = acceleration_curve * facing * throttle

	var slip_angle = state.linear_velocity.angle_to(facing if sign(throttle) >= 0 else -facing) if state.linear_velocity.length() > 1.0 else 0.0
	var steer_curve = exp(-state.linear_velocity.length()) + 1
	var steering_torque = 750 * steer_curve * steering

	state.apply_force(throttle_force)
	state.apply_torque(steering_torque)

	var forward_friction = 35 * -forward_velocity.normalized()
	var slip_curve = abs(slip_angle) / PI if abs(slip_angle) > PI/8 and steering != 0.0 else 1.0
	var sideways_friction = 150 * slip_curve * -sideways_velocity.normalized()

	state.apply_force(forward_friction)
	state.apply_force(sideways_friction)

	if Input.is_action_pressed("brake"):
		var brake_friction = 275 * -state.linear_velocity.normalized()
		state.apply_force(brake_friction)
	
	print(state.linear_velocity.length())
	skidding = abs(slip_angle) > PI/3 and state.linear_velocity.length() > 100
