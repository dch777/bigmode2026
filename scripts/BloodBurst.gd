extends Node2D
class_name BloodBurst

const DROPLET_SCENE := preload("res://prefabs/blood_droplet.tscn")

@export var droplet_count := 60              # baseline
@export var droplet_count_max := 140         # hard cap for performance
@export var speed_min := 140.0
@export var speed_max := 420.0
@export var spread := PI                    # PI = cone, TAU = full circle
@export var scatter_radius := 3.0

func spawn(impact_dir: Vector2, intensity: float = 1.0) -> void:
	# Defer so we never spawn physics bodies during flush
	call_deferred("_spawn_deferred", impact_dir, intensity)

func _spawn_deferred(impact_dir: Vector2, intensity: float) -> void:
	var dir := impact_dir.normalized()
	if dir.length() < 0.001:
		dir = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

	# spray opposite impact direction
	var base_angle := dir.angle() + PI

	# scale droplet count safely
	var n := int(round(droplet_count * clampf(intensity, 0.25, 3.0)))
	n = min(n, droplet_count_max)

	for i in range(n):
		var d := DROPLET_SCENE.instantiate() as RigidBody2D
		get_tree().current_scene.add_child(d)

		d.global_position = global_position + Vector2(
			randf_range(-scatter_radius, scatter_radius),
			randf_range(-scatter_radius, scatter_radius)
		)

		var a := base_angle + randf_range(-spread * 0.5, spread * 0.5)

		# small speed variance; intensity makes it punchier if you want
		var sp: float = randf_range(speed_min, speed_max) * lerp(0.9, 1.2, clampf(intensity - 1.0, 0.0, 1.0))
		d.linear_velocity = Vector2.RIGHT.rotated(a) * sp
		d.angular_velocity = randf_range(-8.0, 8.0)

	queue_free()
