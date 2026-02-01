extends Camera2D

func _process(delta: float):
	var size = get_viewport().get_visible_rect().size / 2
	$GPUParticles2D.visibility_rect = Rect2(-size/2, size)
