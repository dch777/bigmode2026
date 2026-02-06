extends Node2D

@export var enemy: PackedScene
@export var wave_size: int = 5
@export var min_spawn_time: float = 2.0
@export var max_spawn_time: float = 2.0

@export var player: Player
@export var nuke: Nuke

func _ready():
	spawn_wave()

func spawn_wave():
	if enemy:
		for i in range(wave_size):
			var new_enemy = enemy.instantiate()
			new_enemy.global_position = Vector2(randf_range(-100, 100), randf_range(-100, 100))
			if randf() > 0.5:
				new_enemy.target = player.tank
			else:
				new_enemy.target = nuke
			add_child(new_enemy)

		get_tree().create_timer(randf_range(min_spawn_time, max_spawn_time)).timeout.connect(spawn_wave)
