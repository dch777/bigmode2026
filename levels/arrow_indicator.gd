extends AnimatedSprite2D

@export var target: Node2D   # drag your Nuke node here
@export var margin: float = 32.0

func _process(_delta: float) -> void:
	if not is_instance_valid(target):
		hide()
		return

	var vp: Viewport = get_viewport()
	var screen_rect: Rect2 = vp.get_visible_rect()
	var inner_rect: Rect2 = screen_rect.grow(-margin)

	# Convert world position → screen position (respects active Camera2D)
	var target_screen: Vector2 = target.get_global_transform_with_canvas().origin

	# If target is on-screen, hide arrow
	if inner_rect.has_point(target_screen):
		hide()
		return

	show()

	# Screen center
	var center: Vector2 = screen_rect.size * 0.5

	# Direction to target in screen space
	var rel: Vector2 = target_screen - center

	# Clamp arrow to screen edge
	var half: Vector2 = inner_rect.size * 0.5
	var scale: float = max(abs(rel.x) / half.x, abs(rel.y) / half.y)
	position = center + rel / scale

	# Arrow sprite points UP by default
	rotation = rel.angle() + deg_to_rad(90.0)
