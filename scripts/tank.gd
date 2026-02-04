class_name Tank extends RigidBody2D

@export var default_throttle: float = 0.0

var skidding: bool = false

var audio_throttle: float
var rpm: float

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

	var scaled_speed = forward_velocity.length() / 170.0
	var acceleration_curve = 170 * (scaled_speed + 0.5) * exp(-(scaled_speed - 2.0))
	var throttle_force = acceleration_curve * facing * throttle

	var slip_angle = state.linear_velocity.angle_to(facing if sign(throttle) >= 0 else -facing) if state.linear_velocity.length() > 1.0 else 0.0
	var steer_curve = exp(-state.linear_velocity.length()) + 1
	var steering_torque = 750 * steer_curve * steering

	if Input.is_action_pressed("brake") and state.linear_velocity.length() > 50:
		steering_torque *= 1.5
	
	state.apply_force(throttle_force)
	state.apply_torque(steering_torque)

	var forward_friction = 35 * -forward_velocity.normalized()
	var slip_curve = abs(slip_angle) / PI if abs(slip_angle) > PI/8 and steering != 0.0 else 1.0
	var sideways_friction = 175 * slip_curve * -sideways_velocity.normalized()

	state.apply_force(forward_friction)
	state.apply_force(sideways_friction)

	if Input.is_action_pressed("brake"):
		var brake_friction = 350 * -state.linear_velocity.normalized()
		state.apply_force(brake_friction)

	skidding = default_throttle != 0 or \
			(abs(slip_angle) > PI/6 and state.linear_velocity.length() > 150) or \
			(Input.is_action_pressed("brake") and abs(slip_angle) > PI/6 and state.linear_velocity.length() > 70) or \
			(Input.is_action_pressed("brake") and state.linear_velocity.length() > 200)

	if throttle != 0:
		audio_throttle += state.step
		rpm = clamp(audio_throttle * (throttle_force.length() * 1.5 + state.linear_velocity.length() * 1.5), 400, 7000)
	else:
		audio_throttle -= state.step
		rpm = lerp(rpm, 400.0, state.step)
	audio_throttle = clamp(audio_throttle, 0.0, 1)

	$engine_polyphony.update(rpm, audio_throttle, true)
