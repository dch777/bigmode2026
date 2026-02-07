class_name Zombie extends Node2D

@export var target: Node2D
@onready var body = $body
@onready var head = $head

func _ready():
	body.global_position = global_position
	head.global_position = global_position + Vector2(-3, 0)

func _process(delta):
	if body and target:
		body.target = target
	
	if (body == null and head == null) or (body != null and target != null and (target.global_position - body.global_position).length() > 1500):
		queue_free()
