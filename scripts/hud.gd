extends CanvasLayer

@export var total_countdown_time = 30.0
@export var player: Player

var detonate_timer: float = 0.0
var dial_dither = false
var dash_dither = false

var dial_intensity = 0.0
var dash_intensity = 0.0

var time_elapsed = 0.0

func _ready() -> void:
	$AnimationPlayer.play("wobble")

func _process(delta: float) -> void:
	$dial_container/dial/indicator.rotation = clamp(lerp($dial_container/dial/indicator.rotation, PI * player.tank.linear_velocity.length() / (3.0 * 240.0), delta * 5.0), 0, PI + 0.1)
	$dashboard/base/compass.rotation = player.tank.global_rotation + PI/2

	if dash_dither:
		dash_intensity = lerp(dash_intensity, 0.5, 5 * delta)
		dash_dither = false
	else:
		dash_intensity = lerp(dash_intensity, 0.0, 5 * delta)

	if dial_dither:
		dial_intensity = lerp(dial_intensity, 0.5, 5 * delta)
		dial_dither = false
	else:
		dial_intensity = lerp(dial_intensity, 0.0, 5 * delta)
	$dashboard.material.set_shader_parameter("intensity", dash_intensity)
	$dial_container.material.set_shader_parameter("intensity", dial_intensity)

	if Input.is_action_just_pressed("detonate"):
		if detonate_timer <= 0:
			detonate_timer = 3
		else:
			var nuke = get_tree().get_current_scene().find_child("nuke")
			if nuke:
				nuke.explode()

	$dashboard/base/button_down.visible = Input.is_action_pressed("detonate") and detonate_timer > 0


	if detonate_timer > 0:
		detonate_timer -= delta
		$dashboard/base/flap_down.hide()
		$dashboard/base/flap_up.show()
	else:
		$dashboard/base/flap_down.show()
		$dashboard/base/flap_up.hide()

	# if !$Timer.is_stopped():
	# 	$dashboard/base/danger.visible = (detonate_timer > 0 or $Timer.time_left < 10) and int(Time.get_unix_time_from_system()) % 2 == 1
	# 	$warning_mask.visible = ($Timer.time_left < 10) and int(Time.get_unix_time_from_system()) % 2 == 1
	# 	if int(Time.get_unix_time_from_system()) % 2 == 1 and $Timer.time_left < 10 and !$Warning.playing:
	# 		$Warning.play()
	# else:
	# 	$dashboard/base/danger.visible = false
	# 	$warning_mask.visible = false

	$dashboard/base/reloading.visible = player.turret.cooldown_timer > 0

	time_elapsed += delta
	var time_string = format_time(time_elapsed)
	# if $Timer.time_left == 0 and int(2 * Time.get_unix_time_from_system()) % 2 == 0:
	# 	time_string = "  :  "

	for i in range(5):
		if ord(time_string[i]) - ord("0") < 10 and ord(time_string[i]) - ord("0") >= 0:
			$dashboard/tubes.get_child(i).texture.region.position.x = (ord(time_string[i]) - ord("0")) * 32
		elif time_string[i] == ":":
			$dashboard/tubes.get_child(i).texture.region.position.x = 10 * 32
		else:
			$dashboard/tubes.get_child(i).texture.region.position.x = 12 * 32
			
	# scoring hud stuff
	$GoreScore.text = str(StatCounter.gore_score).pad_zeros(12)
	if StatCounter.combo_kills > 0:
		$GoreMultiplier.text = "x" + str(StatCounter.combo_kills)
	else:
		$GoreMultiplier.text = ""
	StatCounter.used_time = time_elapsed

func format_time(t: float) -> String:
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 100)

	return "%02d:%02d" % [minutes, seconds]

func get_color(t: float) -> Color:
	if t > 2.0 * total_countdown_time / 3.0:
		return Color("#63c74d")

	elif t > total_countdown_time / 3.0:
		return Color("#fee761")

	else:
		return Color("#ff0044")
