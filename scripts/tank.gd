class_name Tank extends RigidBody2D

@export var default_throttle: float = 0.0

var slip_curve: float = 0.0
var audio_throttle: float
var rpm: float
var boost: float = 0.0

func _ready():
	$engine_polyphony.load_lib("res://assets/audio/engine/", AudioStreamPlayer2D)
	$engine_polyphony.state(true)
	$engine_polyphony.update(100, 0, true)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var throttle = Input.get_axis("decelerate", "accelerate")
	var steering = Input.get_axis("turn_left", "turn_right")

	if default_throttle != 0:
		throttle = default_throttle

		if abs(global_position.x) > 740:
			state.transform.origin.x = -740 * sign(global_position.x)
		if abs(global_position.y) > 420:
			state.transform.origin.y = -420 * sign(global_position.y)

	var facing = global_transform.x

	var forward_velocity = state.linear_velocity.project(facing)
	var sideways_velocity = state.linear_velocity.slide(facing)

	var scaled_speed = forward_velocity.length() / 175.0
	var acceleration_curve = 175 * (scaled_speed + 0.5) * exp(-(scaled_speed - 2.0))
	var throttle_force = acceleration_curve * facing * throttle

	var steer_curve = exp(-state.linear_velocity.length()) + 1
	var steering_torque = 1000 * steer_curve * steering

	if Input.is_action_pressed("brake") and state.linear_velocity.length() > 200:
		steering_torque *= 1.75
	
	var forward_friction = 35 * -forward_velocity.normalized()

	var slip_angle = state.linear_velocity.angle_to(facing if sign(throttle) >= 0 else -facing) if state.linear_velocity.length() > 30.0 else 0.0
	slip_curve = exp(-state.linear_velocity.length() / (600 * abs(slip_angle))) if abs(slip_angle) > 0.01 else 0.0
	var sideways_friction = 650 * slip_curve * -sideways_velocity.normalized()
	if Input.is_action_pressed("brake") and slip_curve > 0.3 and throttle != 0 and steering != 0:
		boost += 8 * state.step * slip_curve
	if slip_curve > 0.3 and throttle != 0 and steering != 0:
		boost += 5 * state.step * slip_curve
	elif slip_curve > 0.8:
		boost -= state.step * 8.0
	else:
		boost -= state.step * 1.5
	
	boost = clamp(boost, 0, 5)
	if steering == 0:
		throttle_force *= 1 + boost * clamp(1 - (1.7 * slip_curve), 0, 1)

	state.apply_force(throttle_force)
	state.apply_torque(steering_torque)
	state.apply_force(forward_friction)
	state.apply_force(sideways_friction)

	if linear_velocity.length() > 300 or boost > 2.0:
		collision_mask = 1
	else:
		collision_mask = 5
	if state.linear_velocity.length() > 20:
		state.apply_torque(state.linear_velocity.length() * slip_curve * -sign(slip_angle))

	if Input.is_action_pressed("brake"):
		var brake_friction = 350 * -state.linear_velocity.normalized()
		state.apply_force(brake_friction)
		state.apply_torque(-state.angular_velocity * 250)

	if throttle != 0:
		audio_throttle += state.step
		rpm = lerp(rpm, float(clamp(audio_throttle * (throttle_force.length() * 1.5 + state.linear_velocity.length() * 1.5), 400, 7000)), state.step * 5)
	else:
		audio_throttle -= state.step
		rpm = lerp(rpm, 400.0, state.step)
	audio_throttle = clamp(audio_throttle, 0.0, 1)

	$engine_polyphony.update(rpm, audio_throttle, true)

	for i in range(state.get_contact_count()):
		var body = state.get_contact_collider_object(i)

		if body is ZombieBody and not (linear_velocity.length() > 300 or boost > 2.0):
			apply_impulse(-state.get_contact_impulse(i) * 0.1, state.get_contact_local_position(i) - global_position)
		if body is Nuke:
			apply_impulse(-state.get_contact_impulse(i), state.get_contact_local_position(i) - global_position)
