class_name Background extends TileMapLayer

@export var area_scene: PackedScene = preload("res://prefabs/damp_area.tscn")

func _ready():
	for cell in get_used_cells():
		var data = get_cell_tile_data(cell)
		if data:
			var damping = data.get_custom_data("damping")
			if damping > 0:
				var area = area_scene.instantiate()
				area.position = map_to_local(cell)
				area.linear_damp = damping
				add_child(area)
