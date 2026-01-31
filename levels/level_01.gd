extends Node2D

func _process(_delta: float):
	$SubViewport/brush.position = $Player/Tank.position
	$SubViewport/brush.rotation = $Player/Tank.rotation
	$SubViewport/brush.visible = $Player/Tank.skidding
	pass
