class_name Zombie extends Node2D

@export var target: Node2D
@onready var body = $body
@onready var head = $head

func _process(delta):
	if body:
		body.target = target
	
	if body == null and head == null:
		queue_free()
