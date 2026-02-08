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
	var scene_name = next.resource_path.get_file().get_basename()
	
	if scene_name == "title":
		AudioController.pause()
	elif scene_name == "game_over":
		AudioController.pause()
	else:
		AudioController.play_menu_music()
	
	next_scene = next
	animation_player.play("fade_out")
