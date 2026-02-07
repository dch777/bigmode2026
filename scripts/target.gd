class_name Target extends Sprite2D

@export var active: bool = false
@export var next_scene: PackedScene
@export var max_enemies: int = 25

func _ready():
	$lens/CanvasLayer/circle/mask.active = active
	$lens/CanvasLayer/circle/mask.max_enemies = max_enemies

func set_active(a):
	active = a
	$lens/CanvasLayer/circle/mask.active = active
	$lens/CanvasLayer/circle/mask.spawn_wave()

func body_entered(body):
	if body is Nuke:
		body.next_scene = next_scene
		body.target = self

func body_exited(body):
	if body is Nuke:
		body.next_scene = null
		body.target = null
