extends Node2D

var gore_score: int	= 0
var used_nukes: int = 0
var used_time: int = 0
var completed_objectives: int = 0
var total_objectives: int = 0

var time_since_last_kill: float = 0
var combo_kills = 0
var combo_reqs = 3
var combo_multiplier: int = 1
var current_scene

func _process(delta: float) -> void:
	time_since_last_kill += delta
	if time_since_last_kill > get_combo_time_limit():
		reset_combo()

func add_gore() -> void:

	# Add this kill
	combo_kills += 1

	# Check for level up
	if combo_kills >= combo_reqs:
		combo_kills -= combo_reqs   # keep overflow
		combo_multiplier += 1
		combo_reqs *= 2

	time_since_last_kill = 0

	gore_score += combo_multiplier * 100	

func reset_combo() -> void:
	combo_kills = 0
	combo_multiplier = 1
	combo_reqs = 3

func get_combo_time_limit() -> float:
	return max(1.5, 5.0 / (1.0 + 0.1 * (combo_multiplier - 1)))

func calc_final_score() -> int:
	# straightfroward for gore
	var points_from_gore = gore_score
	
	# if they complete a stage, that's an automatic slick
	# if they complete a stage in 10 seconds, that's an automatic very slick
	var points_from_time = max(30000, 81000 - used_time * 100)
	
	# 10000 point penalty per extra nuke
	var points_from_nukes = -10000 * (used_nukes - completed_objectives)
	
	# just determines if they get a game over or not
	# automatic lame if they didn't finish the objectives
	var points_from_objectives = 1 if completed_objectives == total_objectives else 0
	
	return (points_from_gore + points_from_time + points_from_nukes) * points_from_objectives

func reset() -> void:
	gore_score = 0
	used_nukes = 0
	used_time = 0
	completed_objectives = 0
	total_objectives = 0
