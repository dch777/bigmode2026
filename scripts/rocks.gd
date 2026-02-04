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

@export var collider_shape: Shape2D
@export_flags_2d_physics var collider_layer: int = 1
@export_flags_2d_physics var collider_mask: int = 1

func _ready():
	_update_multimesh()

func _update_multimesh():
	if Engine.is_editor_hint():
		queue_redraw()

	$StaticBody2D.collision_layer = collider_layer
	$StaticBody2D.collision_mask = collider_mask
	multimesh.instance_count = round(draw_box.get_area() * density / pow(320, 2))
	for i in multimesh.instance_count:
		var angle = randf_range(-PI, PI)
		var pos = Vector2(randf_range(draw_box.position.x, draw_box.end.x),
						  randf_range(draw_box.position.y, draw_box.end.y))

		multimesh.set_instance_transform_2d(i, Transform2D(angle, pos))

		if !Engine.is_editor_hint():
			var new_collider = CollisionShape2D.new()
			new_collider.shape = collider_shape
			new_collider.position = pos
			new_collider.rotation = angle
			$StaticBody2D.add_child(new_collider)

func _draw():
	if Engine.is_editor_hint():
		draw_rect(draw_box, Color(0.0, 0.0, 0.0, 0.2))
