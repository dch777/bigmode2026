class_name Zombie extends Node2D

@export var target: Node2D
@onready var body = $body
@onready var head = $head

var death_timer = 0.0
var dithering = 0.0

func _ready():
	body.global_position = global_position
	head.global_position = global_position + Vector2(-3, 0)

func _process(delta):
	if body and target:
		body.target = target
	
	if body == null or body.dead == true:
		death_timer += delta
	
	if death_timer > 5.0:
		modulate = Color(1.0, 1.0, 1.0, lerp(modulate.a, 0.0, delta * 5))

	if death_timer > 6.0 or (body == null and head == null) or (body != null and target != null and (target.global_position - body.global_position).length() > 1500):
		queue_free()
