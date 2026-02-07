class_name ZombieHead extends RigidBody2D

var dead: bool = false
@onready var zombie_body = $"../body"
@onready var joint = $"../body/joint"

func _integrate_forces(state):
	if dead:
		return

	for i in range(state.get_contact_count()):
		var body = state.get_contact_collider_object(i)

		if body is Bullet:
			apply_impulse(body.linear_velocity.normalized() * 100)
			zombie_body.die()
		if body is Turret and state.get_contact_impulse(i).length() > 10:
			apply_impulse(-state.get_contact_impulse(i) * 0.9)
			body.apply_impulse(-state.get_contact_impulse(i) * 0.9, state.get_contact_collider_position(i) - body.global_position)
			zombie_body.die()

func screen_exited():
	if dead:
		queue_free()
