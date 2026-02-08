extends CanvasLayer

@onready var is_paused = false
@export var LEVEL_NUM = '1'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	hide()

func _on_main_menu_button_up() -> void:
	#TransitionScreen.transition()
	#await get_tree().create_timer(0.5).timeout
	#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	#await TransitionScreen.on_transition_finished
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.visible = not self.visible
		Engine.time_scale = 0.00001 if self.visible else 1
