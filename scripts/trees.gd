@tool
extends MultiMeshInstance2D

@export var draw_box: Rect2:
	get:
		return draw_box
	set(value):
		if value != draw_box:
			draw_box = value
			_update_multimesh()

@export var density: float:
	get:
		return density
	set(value):
		if value != density:
			density = value
			_update_multimesh()

func _ready():
	_update_multimesh()

func _update_multimesh():
	multimesh.instance_count = round(draw_box.get_area() * density / pow(32, 2))
	for i in multimesh.instance_count:
		var angle = snapped(randf_range(-PI, PI), PI/4)
		var pos = Vector2(randf_range(draw_box.position.x, draw_box.end.x),
						  randf_range(draw_box.position.y, draw_box.end.y))

		multimesh.set_instance_transform_2d(i, Transform2D(angle, pos))
