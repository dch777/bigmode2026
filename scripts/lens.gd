class_name Lens extends Camera2D

@export var priority: int = 0
@export var color: Color = Color.BLACK
@export var active: bool = true

@onready var view: Viewport = $CanvasLayer/SubViewport
@onready var indicator = $CanvasLayer/circle
@onready var canvas_layer = $CanvasLayer

func _ready():
	custom_viewport = view
	enabled = true
	view.world_2d = get_viewport().world_2d
	
	indicator.texture.gradient = indicator.texture.gradient.duplicate()
	indicator.texture.gradient.set_color(0, color)
	indicator.target = self
	canvas_layer.layer = priority

func _process(delta):
	indicator.active = active
