extends Camera2D

@onready var particle_material: Material = $GPUParticles2D.process_material

func _process(delta: float):
	var size = get_viewport().get_visible_rect().size / 2
	$GPUParticles2D.visibility_rect = Rect2(-size/2, size)
