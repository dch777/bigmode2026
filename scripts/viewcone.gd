class_name ViewCone extends Area2D

var bodies_in_range: Dictionary[RigidBody2D, bool]
var suspected_bodies: Dictionary[RigidBody2D, bool]
var detected_bodies: Dictionary[RigidBody2D, bool]
var enabled: bool = true

func _process(delta):
	var space_state = get_world_2d().direct_space_state

	for body in bodies_in_range.keys():
		var angle = wrapf(body.global_position.angle_to_point(global_transform.origin) - global_rotation, -PI, PI)
		var to_body = body.global_position - global_position

		var query = PhysicsRayQueryParameters2D.create(global_position + to_body.normalized() * 32, body.global_position)
		var result = space_state.intersect_ray(query)

		if result and result.collider == body and abs(angle) > 5 * PI / 6:
			suspected_bodies.set(body, true)
		else:
			suspected_bodies.erase(body)

	if enabled and suspected_bodies.size() > 0 and $suspicion.texture_scale < $danger.texture_scale:
		$suspicion.texture_scale += 0.01
	elif $suspicion.texture_scale > 0:
		$suspicion.texture_scale -= 0.01

	for body in suspected_bodies:
		var to_body = body.global_position - global_position
		if to_body.length() <= $suspicion.texture_scale * 512 - 400:
			detected_bodies.set(body, true)

func _on_body_entered(body: Node2D):
	if body is Tank or body is Turret or body is Nuke:
		bodies_in_range.set(body, true)

func _on_body_exited(body: Node2D):
	bodies_in_range.erase(body)
	suspected_bodies.erase(body)
	detected_bodies.erase(body)
