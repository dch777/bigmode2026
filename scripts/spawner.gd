extends Node2D

@export var enemy: PackedScene
@export var wave_size: int = 5
@export var min_spawn_time: float = 2.0
@export var max_spawn_time: float = 2.0

@export var player: Player
@export var nuke: Nuke

func _ready():
	get_tree().create_timer(randf_range(min_spawn_time, max_spawn_time)).timeout.connect(spawn_wave)

func spawn_wave():
	if enemy and visible:
		var current_scene = get_tree().get_current_scene()
		var lens_pos: Vector2 = get_viewport().get_camera_2d().get_screen_center_position() + 1.5 * (global_position - get_viewport().get_visible_rect().size / 2.0) 

		for i in range(wave_size):
			if current_scene.find_child("zombies").get_child_count() > 20:
				continue

			var new_enemy = enemy.instantiate()
			new_enemy.global_position = lens_pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			if randf() >= 0.1:
				new_enemy.target = current_scene.find_child("Player").tank
			else:
				new_enemy.target = current_scene.find_child("nuke")
			current_scene.find_child("zombies").add_child(new_enemy)

	get_tree().create_timer(randf_range(min_spawn_time, max_spawn_time)).timeout.connect(spawn_wave)
