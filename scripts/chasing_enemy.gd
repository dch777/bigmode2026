extends RigidBody2D

@export var target: RigidBody2D
@export var player: Player
@export var patrol: Vector2
@export var alert_time = 4.0	# measured in secs

@onready var lens: Lens = $lens
@onready var alert_timer = 0.0
@onready var state = 0	# 0 - idle, 1 - alert, 2 - chasing

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$DefaultHitbox.disabled = false
	$ChasingHitbox.disabled = true

func _physics_process(delta: float) -> void:
	var to_target = target.global_position - global_position
	var to_player = player.tank.global_position - global_position
	var to_patrol = patrol - global_position
	var target_to_patrol = target.global_position - patrol

	# patrol mechanic
	var force = Vector2(0.0, 0.0)
	if target_to_patrol.length() < 1000:
		if alert_timer != alert_time:	# within range, start raising alertness
			alert_timer = min(alert_time, alert_timer + delta)
		else:	# fully alert, chase
			force = to_target.normalized() * 150.0 + to_target * 0.1
			lens.active = true
			$AnimatedSprite2D.play("chase")
	else:
		force = to_patrol * 0.1
		lens.active = false
		alert_timer = max(0, alert_timer - delta)	# decrease alertness
		$AnimatedSprite2D.play("default")
		


	# fear mechanic
	if to_player.length() < 300 and to_target.length() > 30:
		force += -to_player.normalized() * (300 - to_player.length()) * 2.0
	if to_player.length() < 200:
		force += -to_player.normalized() * 3.0
	var damp = -linear_velocity * 0.1

	# move
	apply_central_force(force + damp)
	
	# look
	if alert_timer > 0 and alert_timer < alert_time:
		look_at(target.global_position)
		$Alert.visible = true
	else:
		look_at(global_position + linear_velocity)
		$Alert.visible = false
	
	$DefaultHitbox.disabled = true
	$ChasingHitbox.disabled = false
