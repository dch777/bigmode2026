extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var next_scene: PackedScene

func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_packed(next_scene)
		animation_player.play("fade_in")
		
func transition(next: PackedScene):
	next_scene = next
	animation_player.play("fade_out")
