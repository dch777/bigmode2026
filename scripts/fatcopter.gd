extends Node2D

var nuke_scene: PackedScene = preload("res://entities/nuke.tscn")
var nuke_dropped
var goal: Vector2
var active: bool = false

func _process(delta):
	if visible:
		$blades.rotation += 0.1

	if active:
		if (global_position - goal).length() < 10:
			var nuke = nuke_scene.instantiate()
			nuke.global_position = $nuke_location.global_position
			nuke.name = "nuke"
			get_tree().get_current_scene().add_child(nuke)
			nuke.owner = get_tree().get_current_scene()

			active = false
		else:
			global_position = global_position.move_toward(goal, 500 * delta)
			look_at(goal)
	elif visible and !active:
		global_position += 500 * delta * global_transform.x

func drop_nuke(nuke_pos: Vector2):
	goal = nuke_pos
	global_position = get_tree().get_current_scene().find_child("Player").tank.global_position - Vector2(720, 0)
	active = true
	visible = true

func screen_entered():
	# visible = active
	pass

func screen_exited():
	visible = active
