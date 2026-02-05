class_name Turret extends RigidBody2D

@export var kp: float = 10000.0
@export var ki: float = 100.0
@export var kd: float = 1000.0

@export var active: bool = false
@export var breakout_mode: bool = false
@export var bullet: PackedScene

@export var attraction_force: float = 800.0

var _integral: float = 0.0
var _int_max = 200
var goal_rotation = 0.0
var cooldown_timer = 0.0

@onready var body = $"../body"

func calculate_error(state: PhysicsDirectBodyState2D) -> float:
	var error = wrapf(get_global_mouse_position().angle_to_point(state.transform.origin) - global_rotation, -PI, PI)
	# if Input.is_action_pressed("lock_turret"):
	# 	error = wrapf(goal_rotation - (rotation - body.rotation), -PI, PI)
	return error

func _process(delta):
	if active:
		$attractor.gravity = attraction_force if Input.is_action_pressed("lock_turret") else 0

		cooldown_timer -= delta
		if Input.is_action_just_pressed("shoot") and cooldown_timer <= 0:
			cooldown_timer = 5.0
			$TankTurret.play("shoot")

			var new_bullet = bullet.instantiate()
			new_bullet.top_level = true
			new_bullet.global_rotation = global_rotation + PI
			new_bullet.global_position = $end.global_position

			var dir = Vector2.from_angle(global_rotation + PI)
			new_bullet.linear_velocity = dir * 1000
			body.apply_impulse(-dir * 500)
			add_child(new_bullet)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# if Input.is_action_just_pressed("lock_turret"):
	# 	goal_rotation = rotation - body.rotation

	var error = calculate_error(state)
	var delta = state.get_step()

	if breakout_mode:
		if abs(global_position.x) > 740:
			state.transform.origin.x = -740 * sign(global_position.x)
			error = calculate_error(state)
			state.transform = state.transform.rotated_local(error)
		if abs(global_position.y) > 420:
			state.transform.origin.y = -420 * sign(global_position.y)
			error = calculate_error(state)
			state.transform = state.transform.rotated_local(error)

	var P = kp * error

	_integral = wrapf(_integral + (error * delta), -256, 256)
	var I = ki * _integral

	var D = kd * -angular_velocity

	state.apply_torque(P + I + D)
