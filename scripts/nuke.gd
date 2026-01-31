extends Node2D

@onready var blast_zone = $BlastZone/CollisionShape2D

var is_exploding = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_exploding:
		blast_zone.shape.radius = min(blast_zone.shape.radius * 1.05, 10000.0) # TODO add forces
		pass

func explode() -> void:
	is_exploding = true
	
	$Explosion1.emitting = true
	$Explosion2.emitting = true
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D2.play()
