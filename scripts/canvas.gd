class_name Canvas extends SubViewport

@export var brush: Node2D
@export var tank: Node2D

func _process(_delta: float):
	brush.position = tank.position
	brush.rotation = tank.rotation
	brush.visible = tank.skidding
