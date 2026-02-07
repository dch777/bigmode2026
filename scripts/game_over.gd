extends Control

@onready var rainbow_shader = load("res://assets/shaders/rainbow.gdshader")
@onready var rainbow_mat = ShaderMaterial.new()

var gore_score: int	= 10000
var used_time: int = 1
var stage_time: int = 1
var completed_all_objectives: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# display some stuff
	$GoreScore.text = str(gore_score)
	$TimeUsed.text = str(used_time)
	
	# do some calculations
	var final_score = (gore_score + (stage_time - used_time) / stage_time * 8000) * completed_all_objectives
	
	# display more stuff
	var total_radness: String
	if final_score >= 10000: # SOOPA SLICK
		rainbow_mat.shader = rainbow_shader
		$TotalRadness.material = rainbow_mat
		total_radness = "SOOPA SLICK!"
	elif final_score >= 8000: # VERY SLICK
		$TotalRadness.add_theme_color_override("font_color", Color("63c74d"))
		total_radness = "VERY SLICK"
	elif final_score >= 5000: # SLICK
		$TotalRadness.add_theme_color_override("font_color", Color("feae34"))
		total_radness = "SLICK"
	else: # LAME
		$TotalRadness.add_theme_color_override("font_color", Color("ff0044"))
		total_radness = "LAME"
	$TotalRadness.text = total_radness

	# show em
	$AnimationPlayer.play("slam")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
