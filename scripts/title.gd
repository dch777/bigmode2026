extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("title")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "title":
		$punch_a_rock.play()
		$crack.visible = true
		$Timer.start()


func _on_timer_timeout() -> void:
	$glass_bottle_smash.play()
	$alt_background.visible = true
	$Path2D/PathFollow2D/alt_name.visible = true
	$alt_crack.visible = true


func _on_glass_bottle_smash_finished() -> void:
	$Timer2.start()


func _on_timer_2_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
