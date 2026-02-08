extends CanvasLayer

@onready var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	hide()

func _on_main_menu_button_up() -> void:
	TransitionScreen.transition(load("res://entities/level_select.tscn"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.visible = not self.visible
		Engine.time_scale = 0.00001 if self.visible else 1
