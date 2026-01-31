class_name Nuke extends RigidBody2D

@export var player: Player

var is_exploding = false
var pushed_bodies: Dictionary[RigidBody2D, bool]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_exploding:
		$BlastRadius/CollisionShape2D.scale += Vector2(0.25, 0.25)
		player.camera.global_position = player.camera.global_position.lerp(global_position, 4 * delta)
		player.camera.zoom = player.camera.zoom.lerp(Vector2(0.5, 0.5), delta)

func explode() -> void:
	await get_tree().create_timer(8.0).timeout

	$BlastRadius.monitoring = true
	player.camera.top_level = true
	player.camera.global_position = player.tank.global_position
	is_exploding = true
	freeze = true

	$Explosion1.emitting = true
	$Explosion2.emitting = true

func blast_radius_entered(body: Node2D):
	if body is RigidBody2D and !pushed_bodies.has(body):
		pushed_bodies.set(body, true)
		var dir = (body.global_position - global_position).normalized()
		body.apply_impulse(dir * 1000)
