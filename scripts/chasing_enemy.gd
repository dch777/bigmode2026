extends RigidBody2D

@export var target: RigidBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$DefaultHitbox.disabled = false
	$ChasingHitbox.disabled = true

func _physics_process(delta: float) -> void:
	var dir = target.global_position - global_position
	var distance = dir.length()
		
	dir = dir.normalized()
		
	apply_central_force(dir * 30.0)	# recoil
	
	look_at(target.global_position)
	
	$AnimatedSprite2D.play("chase")
	$DefaultHitbox.disabled = true
	$ChasingHitbox.disabled = false
