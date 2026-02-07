extends Sprite2D

@export var active: bool = false
@export var next_scene: PackedScene

func _ready():
	$lens/CanvasLayer/circle/mask.active = active

func set_active(a):
	active = a
	$lens/CanvasLayer/circle/mask.active = active
	$lens/CanvasLayer/circle/mask.spawn_wave()

func body_entered(body):
	if body is Nuke:
		body.next_scene = next_scene

func body_exited(body):
	if body is Nuke:
		body.next_scene = null
