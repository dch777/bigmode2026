extends RigidBody2D

@onready var patrol = global_position

@onready var lens: Lens = $lens
@onready var chasing = false

var target: RigidBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	# $DefaultHitbox.disabled = false
	# $ChasingHitbox.disabled = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var to_patrol = patrol - global_position
	
	# patrol mechanic
	var force = Vector2(0.0, 0.0)
	if target != null:
		var to_target = target.global_position - global_position
		var target_to_patrol = target.global_position - patrol

		force = to_target.normalized() * 100.0
		lens.active = true
		$AnimatedSprite2D.play("chase")

		for body in $viewcone.detected_bodies:
			var body_to_patrol = body.global_position - patrol
			if body_to_patrol.length() < 1000:
				if body is Nuke:
					target = body

		if target_to_patrol.length() > 1000:
			target = null
			$viewcone.visible = true
	else:
		if $viewcone.suspected_bodies.size() == 0 and to_patrol.length() > 20.0:
			force = to_patrol * 0.1

		for body in $viewcone.detected_bodies:
			var body_to_patrol = body.global_position - patrol

			if body_to_patrol.length() < 1000:
				$viewcone.visible = false

				if body is Tank:
					target = body
				elif body is Turret:
					target = body.tank
				elif body is Nuke:
					target = body
					break

		lens.active = false
		$AnimatedSprite2D.play("default")
		
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

	if (target == null or $viewcone.suspected_bodies.size() == 0) and linear_velocity.length() > 2.0:
		var goal = (global_position + linear_velocity + force * 0.1)
		var error = wrapf(goal.angle_to_point(state.transform.origin) - global_rotation + PI, -PI, PI)
		state.apply_torque(1000 * error - 200 * angular_velocity)
	if target == null and $viewcone.suspected_bodies.size() > 0:
		state.angular_velocity = clamp(state.angular_velocity, -2, 2)

func collided_with(body):
	if body is Turret and target == null:
		target = body.tank
	if body is Tank:
		if target == null:
			target = body

		if linear_velocity.length() > 50.0:
			var dir = body.global_position - global_position
			body.apply_impulse(dir.normalized() * 300)
