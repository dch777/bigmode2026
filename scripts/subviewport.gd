class_name SkidCanvas extends SubViewport


@export var brush: Node2D
@export var player: Player

func _process(_delta: float):
	brush.position = player.tank.global_position
	brush.rotation = player.tank.rotation
	brush.visible = player.tank.skidding
