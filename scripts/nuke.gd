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
		if !breakout_mode:
			camera.global_position = camera.global_position.lerp(global_position, 4 * delta)
			camera.zoom = camera.zoom.lerp(Vector2(0.5, 0.5), delta)
		# var size = get_viewport().get_visible_rect().size / (player.camera.zoom)
		# player.camera.particle_material.set_shader_parameter("window_size", size)

	elif breakout_mode and Input.is_action_just_pressed("start"):
		explode()
	
func explode() -> void:
	await get_tree().create_timer(1.0).timeout

	$BlastZone.monitoring = true
	camera.top_level = true
	camera.particle_material.set_shader_parameter("explosion", global_position)
	camera.particle_material.set_shader_parameter("is_exploding", true)
	if !breakout_mode:
		camera.global_position = player.tank.global_position

	is_exploding = true
	freeze = true

	$Explosion1.emitting = true
	$Explosion2.emitting = true
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D2.play()

	if breakout_mode:
		await get_tree().create_timer(3.2).timeout
		TransitionScreen.transition(next_scene)
		
	# TODO idk where, but you can emit signal "end_game" to trigger rest. signal must be handled by level script

func blast_radius_entered(body: Node2D):
	if body is RigidBody2D:
		pushed_bodies.set(body, true)
		var dir = (body.global_position - global_position).normalized()
		body.apply_impulse(dir * 1000)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if breakout_mode:
		var deg = snapped(state.linear_velocity.angle(), PI/4)
		if fmod(deg, PI/2) == 0:
			deg += PI/4
		state.linear_velocity = Vector2.from_angle(deg) * max(state.linear_velocity.length(), 500.0)


func _on_center_o_mass_death() -> void:
	$AnimationPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	$AnimationPlayer.play("death")

	process_mode = Node.PROCESS_MODE_DISABLED
	
	emit_signal("end_game")
