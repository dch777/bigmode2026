class_name Player extends Node2D

@export var camera: Camera2D
@onready var tank: Tank = find_child("body")

signal end_game

func _on_center_of_mass_death() -> void:
	# keep the snow effect
	$body/Camera2D.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# everything else gets disabled
	$body.process_mode = Node.PROCESS_MODE_DISABLED
	$turret.process_mode = Node.PROCESS_MODE_DISABLED
	$balance_turret.process_mode = Node.PROCESS_MODE_DISABLED
	$turret_pin.process_mode = Node.PROCESS_MODE_DISABLED
	$balance_pin.process_mode = Node.PROCESS_MODE_DISABLED
	
	$AnimationPlayer.play("death")
	
	# propagate up, lets level script reset
	emit_signal("end_game")
