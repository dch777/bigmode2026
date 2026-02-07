class_name Nuke extends RigidBody2D

@export var player: Player
@export var breakout_mode: bool = false
@export var next_scene: PackedScene

@onready var blast_zone = $BlastZone/CollisionShape2D
@onready var camera: Camera2D = get_viewport().get_camera_2d()

var is_exploding = false
var pushed_bodies: Dictionary[RigidBody2D, bool]

signal end_game

func _ready() -> void:
	#explode()
	pass

func _process(delta: float) -> void:
	if is_exploding:
		blast_zone.shape.radius = min(blast_zone.shape.radius * 1.05, 10000.0)
		if !breakout_mode and next_scene != null:
			camera.global_position = camera.global_position.lerp(global_position, 4 * delta)
			camera.zoom = camera.zoom.lerp(Vector2(0.5, 0.5), delta)

	elif breakout_mode and Input.is_action_just_pressed("start"):
		explode()

func explode() -> void:
	$BlastZone.monitoring = true
	camera.particle_material.set_shader_parameter("explosion", global_position)
	camera.particle_material.set_shader_parameter("is_exploding", true)

	if !breakout_mode and next_scene != null:
		camera.top_level = true
		camera.global_position = player.tank.global_position

	is_exploding = true
	freeze = true

	$NukeBall.visible = false
	$Explosion1.emitting = true
	$Explosion2.emitting = true
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D2.play()

	await get_tree().create_timer(3.2).timeout

	camera.particle_material.set_shader_parameter("is_exploding", false)

	if breakout_mode or next_scene != null:
		TransitionScreen.transition(next_scene)
	
	queue_free()

func blast_radius_entered(body: Node2D):
	if body is RigidBody2D and body is not Bullet:
		pushed_bodies.set(body, true)
		var dir = (body.global_position - global_position).normalized()
		body.apply_impulse(dir * 200)
	
	if body is ZombieHead:
		body.zombie_body.die()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if breakout_mode:
		var deg = snapped(state.linear_velocity.angle(), PI/4)
		if fmod(deg, PI/2) == 0:
			deg += PI/4
		state.linear_velocity = Vector2.from_angle(deg) * max(state.linear_velocity.length(), 500.0)

func _on_center_o_mass_death() -> void:
	camera.top_level = true
	#camera.particle_material.set_shader_parameter("explosion", global_position)
	#camera.particle_material.set_shader_parameter("is_exploding", true)
	
	$AnimationPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	$AnimationPlayer.play("death")

	process_mode = Node.PROCESS_MODE_DISABLED
