extends Control

@onready var rainbow_shader = load("res://assets/shaders/rainbow.gdshader")
@onready var supa_slick_audio = load("res://assets/audio/freesound_community-badass-victory-85546.mp3")
@onready var regular_audio = load("res://assets/audio/universfield-video-game-bonus-323603.mp3")
@onready var lame_audio = load("res://assets/audio/freesound_community-wrong-buzzer-6268.mp3")
@onready var rainbow_mat = ShaderMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# display some stuff
	$GoreScore.text = str(StatCounter.gore_score)
	
	$NukesUsed.add_theme_color_override("font_color", Color("63c74d") if StatCounter.used_nukes <= StatCounter.completed_objectives else Color("ff0044"))
	$NukesUsed.text = str(StatCounter.used_nukes)
	
	$BasesDestroyed.add_theme_color_override("font_color", Color("63c74d") if StatCounter.completed_objectives == StatCounter.total_objectives else Color("ff0044"))
	$BasesDestroyed.text = str(StatCounter.completed_objectives) + " of " + str(StatCounter.total_objectives)
	
	$TimeUsed.text = str(StatCounter.used_time)
	
	# do some calculations
	var final_score = StatCounter.calc_final_score()
	print(final_score)
	
	# display more stuff
	var total_radness: String
	if final_score >= 100000: # SOOPA SLICK
		rainbow_mat.shader = rainbow_shader
		$RadnessString.material = rainbow_mat
		$RadnessString.text = "SUPA SLICK"
		
		$ScoreTune.stream = supa_slick_audio
		$ScoreTune.volume_db = 7
	elif final_score >= 80000: # VERY SLICK
		$RadnessString.add_theme_color_override("font_color", Color("63c74d"))
		$RadnessString.text = "VERY SLICK"
		
		$ScoreTune.stream = regular_audio
		$ScoreTune.volume_db = 4
	elif final_score >= 30000: # SLICK
		$RadnessString.add_theme_color_override("font_color", Color("feae34"))
		$RadnessString.text = "SLICK"

		$ScoreTune.stream = regular_audio
		$ScoreTune.volume_db = 4
	else: # LAME
		$RadnessString.add_theme_color_override("font_color", Color("ff0044"))
		$RadnessString.text = "LAME"

		$ScoreTune.stream = lame_audio
		$ScoreTune.volume_db = -7
	
	$TotalRadness.text = str(final_score)

	# show em
	$AnimationPlayer.play("slam")
