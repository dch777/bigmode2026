extends Node2D

@onready var viewport := $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon_to_png()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func polygon_to_png():
	await RenderingServer.frame_post_draw

	var image: Image = viewport.get_texture().get_image()

	image.save_png("res://scenic_view.png")
