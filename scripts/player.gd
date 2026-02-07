class_name Player extends Node2D

@export var camera: Camera2D
@onready var tank: Tank = $body
@onready var turret: Turret = $turret
@onready var game_over_screen = load("res://ui/game_over.tscn")


func _process(delta):
	get_window().title = "fps: " + str(Engine.get_frames_per_second())

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
		
	# transition to game over
	await get_tree().create_timer(1.0).timeout
	TransitionScreen.transition(game_over_screen)
