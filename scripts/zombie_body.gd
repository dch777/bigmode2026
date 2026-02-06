class_name ZombieBody extends RigidBody2D

var target: RigidBody2D
@onready var head = $"../head"
var dead = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if dead:
		return

	var force = Vector2()

	if target:
		var to_target = target.global_position - global_position

		force += to_target.normalized() * 130.0

	var straight = $straight.is_colliding() and $straight.get_collider() != target
	var right = $right.is_colliding() and $right.get_collider() != target
	var left = $left.is_colliding() and $left.get_collider() != target

	if straight:
		force = force.project(-global_transform.x)
		var dist = $straight.get_collision_point() - global_position
		force += (100 - dist.length()) * -global_transform.x
	if left:
		var dist = $left.get_collision_point() - global_position
		force = force.length() * global_transform.y * (120 - dist.length()) / 100
		if !straight:
			force += 40 * global_transform.x
	if right:
		var dist = $right.get_collision_point() - global_position
		force = force.length() * -global_transform.y * (120 - dist.length()) / 100
		if !straight:
			force += 40 * global_transform.x

	var damp = -linear_velocity * 0.1
	apply_central_force(force + damp)

	var facing = global_transform.x
	var sideways_velocity = state.linear_velocity.slide(facing)
	var slip_angle = state.linear_velocity.angle_to(facing) if state.linear_velocity.length() > 1.0 else 0.0
	var slip_curve = abs(slip_angle) / PI if abs(slip_angle) > PI/8 else 1.0
	var sideways_friction = 10 * slip_curve * -sideways_velocity.normalized()

	state.apply_force(sideways_friction)

	var goal = global_position + force
	var error = wrapf(goal.angle_to_point(state.transform.origin) - global_rotation + PI, -PI, PI)
	state.apply_torque(1000 * error - 200 * angular_velocity)

	# if target:
	# 	goal = target.global_position
	error = wrapf(goal.angle_to_point(head.global_transform.origin) - head.global_rotation + PI, -PI, PI)
	# $joint.motor_target_velocity = 2 * error - head.angular_velocity

	for i in range(state.get_contact_count()):
		var body = state.get_contact_collider_object(i)

		if body is Tank and body.linear_velocity.length() > 150 and state.get_contact_impulse(i).length() > 0.4:
			head.apply_impulse(-state.get_contact_impulse(i))
			die()
		elif body is not Tank and body is not ZombieBody and body is RigidBody2D and (body.linear_velocity - linear_velocity).length() > 300:
			head.apply_impulse(-state.get_contact_impulse(i))
			die()
		elif body == target and body is RigidBody2D:
			body.apply_force(global_transform.x * 300)

# 	if (head.global_position - $joint.global_position).length() > 4:
# 		print((head.global_position - $joint.global_position).length())
# 		die()

func die():
	$joint.node_a = ""

	$oof.playing = true

	$body.visible = false
	$fallen_body.visible = true
	$fallen_body.global_rotation = head.linear_velocity.angle()

	head.linear_damp = 5.0
	head.z_index = 0
	head.collision_layer = 0
	head.collision_mask = 0
	head.dead = true

	angular_damp = 10.0
	linear_damp = 5.0
	z_index = 0
	dead = true
	$CollisionShape2D.set_deferred("disabled", true)

func screen_exited():
	if dead:
		queue_free()
