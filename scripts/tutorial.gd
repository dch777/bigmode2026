extends Node2D

var spawned = false

func _on_nuke_spawn_area_entered(body):
	if body is Tank and !spawned:
		Fatcopter.drop_nuke(Vector2(500, 4192))
		spawned = true

func _on_activate_target_area_entered(body):
	if body is Tank:
		$target.set_active(true)
