class_name Canvas extends SubViewport

@export var brush: Node2D
@export var tank: Tank

func _process(_delta: float):
	brush.position = tank.position
	brush.rotation = tank.rotation
	brush.visible = tank.skidding
