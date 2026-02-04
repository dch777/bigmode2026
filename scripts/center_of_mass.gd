extends Area2D

signal death

func die() -> void:
	emit_signal("death")
