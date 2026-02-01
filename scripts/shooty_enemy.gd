extends RigidBody2D

@export var target: RigidBody2D

var shoot = false

func _physics_process(delta: float) -> void:	
	if shoot:
		var dir = target.global_position - global_position
		var distance = dir.length()
		
		dir = dir.normalized()
		
		target.apply_central_impulse(dir * 10000.0)	# shoot player
		apply_central_impulse(-1 * dir * 10.0)	# recoil
		
		shoot = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group(target.get_groups()[0])):
		$Timer.start()

func _on_timer_timeout() -> void:
	shoot = true
