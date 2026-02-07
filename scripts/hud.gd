extends CanvasLayer

@export var total_countdown_time = 30.0
@export var nuke: Nuke
@export var player: Player

var detonate_timer: float = 0.0

func _ready() -> void:
	$Timer.wait_time = total_countdown_time
	$Timer.start()
	
	$AnimationPlayer.play("wobble")

func _process(delta: float) -> void:
	$Label.add_theme_color_override("font_color", get_color($Timer.time_left))
	$Label.text = format_time($Timer.time_left)

	$dial_container/dial/indicator.rotation = clamp(lerp($dial_container/dial/indicator.rotation, PI * player.tank.linear_velocity.length() / (3.0 * 240.0), delta * 5.0), 0, PI + 0.1)
	$dashboard/base/compass.rotation = player.tank.global_rotation + PI/2

	if Input.is_action_just_pressed("detonate"):
		if detonate_timer <= 0:
			detonate_timer = 3
		else:
			$Timer.start(0.01)
			$dashboard/base/button_down.show()

	if detonate_timer > 0:
		detonate_timer -= delta
		$dashboard/base/flap_down.hide()
		$dashboard/base/flap_up.show()
	else:
		$dashboard/base/flap_down.show()
		$dashboard/base/flap_up.hide()

	$dashboard/base/danger.visible = (detonate_timer > 0 or $Timer.time_left < 10) and int(2 * Time.get_unix_time_from_system()) % 2 == 1
	$dashboard/base/reloading.visible = player.turret.cooldown_timer > 0

	var time_string = format_time($Timer.time_left)
	if $Timer.time_left == 0 and int(2 * Time.get_unix_time_from_system()) % 2 == 0:
		time_string = "  :  "

	for i in range(5):
		if ord(time_string[i]) - ord("0") < 10 and ord(time_string[i]) - ord("0") >= 0:
			$dashboard/tubes.get_child(i).texture.region.position.x = (ord(time_string[i]) - ord("0")) * 32
		elif time_string[i] == ":":
			$dashboard/tubes.get_child(i).texture.region.position.x = 10 * 32
		else:
			$dashboard/tubes.get_child(i).texture.region.position.x = 12 * 32
			
	# scoring hud stuff
	$GoreScore.text = str(StatCounter.gore_score).pad_zeros(12)
	$GoreMultiplier.text = "x" + str(StatCounter.combo_multiplier)
	

func format_time(t: float) -> String:
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 100)

	return "%02d:%02d" % [minutes, seconds]

func timeout():
	if nuke:
		nuke.explode()

func get_color(t: float) -> Color:
	if t > 2.0 * total_countdown_time / 3.0:
		return Color("#63c74d")

	elif t > total_countdown_time / 3.0:
		return Color("#fee761")

	else:
		return Color("#ff0044")
