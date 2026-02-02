class_name Nuke extends RigidBody2D

@export var player: Player
@onready var blast_zone = $BlastZone/CollisionShape2D

var is_exploding = false
var pushed_bodies: Dictionary[RigidBody2D, bool]

func _ready() -> void:
	explode()
	pass

func _process(delta: float) -> void:
	if is_exploding:
		blast_zone.shape.radius = min(blast_zone.shape.radius * 1.05, 10000.0)
		player.camera.global_position = player.camera.global_position.lerp(global_position, 4 * delta)
		player.camera.zoom = player.camera.zoom.lerp(Vector2(0.5, 0.5), delta)
		var size = get_viewport().get_visible_rect().size / (player.camera.zoom)
		player.camera.particle_material.set_shader_parameter("window_size", size)

func explode() -> void:
	await get_tree().create_timer(20.0).timeout

	$BlastZone.monitoring = true
	player.camera.top_level = true
	player.camera.particle_material.set_shader_parameter("explosion", global_position)
	player.camera.particle_material.set_shader_parameter("is_exploding", true)
	player.camera.global_position = player.tank.global_position
	is_exploding = true
	freeze = true

	$Explosion1.emitting = true
	$Explosion2.emitting = true
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D2.play()

func blast_radius_entered(body: Node2D):
	if body is RigidBody2D:
		print(body)
		pushed_bodies.set(body, true)
		var dir = (body.global_position - global_position).normalized()
		body.apply_impulse(dir * 1000)
