extends CanvasLayer

@export var total_countdown_time = 30.0

func _ready() -> void:
	$Timer.wait_time = total_countdown_time
	$Timer.start()

func _process(delta: float) -> void:
	$Label.add_theme_color_override("font_color", get_color($Timer.time_left))
	$Label.text = format_time($Timer.time_left)

func format_time(t: float) -> String:
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func get_color(t: float) -> Color:
	if t > 2.0 * total_countdown_time / 3.0:
		return Color("#63c74d")

	elif t > total_countdown_time / 3.0:
		return Color("#fee761")

	else:
		return Color("#ff0044")
