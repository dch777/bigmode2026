extends RigidBody2D

@export var target: RigidBody2D
@export var player: Player
@export var patrol: Vector2

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$DefaultHitbox.disabled = false
	$ChasingHitbox.disabled = true

func _physics_process(delta: float) -> void:
	var to_target = target.global_position - global_position
	var to_player = player.tank.global_position - global_position
	var to_patrol = patrol - global_position
	var target_to_patrol = target.global_position - patrol

	var force = Vector2(0.0, 0.0)
	if target_to_patrol.length() < 1000:
		force = to_target.normalized() * 200.0 + to_target * 0.1
		$AnimatedSprite2D.play("chase")
	else:
		force = to_patrol * 0.1
		$AnimatedSprite2D.play("default")

	if to_player.length() < 300 and to_target.length() > 30:
		force += -to_player.normalized() * (300 - to_player.length()) * 2.0
	if to_player.length() < 200:
		force += -to_player.normalized() * 3.0
	var damp = -linear_velocity * 0.1

	apply_central_force(force + damp)
	look_at(global_position + linear_velocity)
	
	$DefaultHitbox.disabled = true
	$ChasingHitbox.disabled = false
