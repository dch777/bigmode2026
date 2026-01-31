extends Node2D

var is_exploding = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_exploding:
		$BlastRadius/CollisionShape2D.scale += Vector2(0.5, 0.5)	# TODO add forces
		pass

func explode() -> void:
	is_exploding = true
	
	$Explosion1.emitting = true
	$Explosion2.emitting = true
