extends RigidBody2D

@export var target: RigidBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	var to_target = target.global_position - global_position
	var distance = to_target.length()

	var force = to_target.normalized() * distance * 5.0
	var damp = -linear_velocity * 1.0

	apply_central_force(force + damp)
	look_at(target.global_position)
	
	$AnimatedSprite2D.play("chase")
