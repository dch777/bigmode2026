class_name Turret extends RigidBody2D

@export var kp: float = 10000.0
@export var ki: float = 100.0
@export var kd: float = 1000.0

var _integral: float = 0.0
var _int_max = 200

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var error = wrapf(get_global_mouse_position().angle_to_point(global_position) - global_rotation, -PI, PI)
	var delta = state.get_step()

	var P = kp * error

	_integral = wrapf(_integral + (error * delta), -256, 256)
	var I = ki * _integral

	var D = kd * -angular_velocity

	state.apply_torque(P + I + D)
