class_name Arm extends RigidBody2D

@export var kp: float = 1000.0
@export var ki: float = 100.0
@export var kd: float = 500.0

var _prev_error: float = 0.0
var _integral: float = 0.0
var _int_max = 200

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var error = wrapf(get_global_mouse_position().angle_to_point(position) - global_rotation, -PI, PI)
	var delta = state.get_step()

	var P = kp * error

	_integral = wrapf(_integral + (error * delta), -256, 256)
	var I = ki * _integral

	var derivative = (error - _prev_error) / delta
	var D = kd * derivative

	state.apply_torque(P + I + D)

	_prev_error = error
