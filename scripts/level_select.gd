extends Control

var level1: PackedScene = preload("res://levels/tutorial.scn")
var level2: PackedScene = preload("res://levels/t_bone.scn")
var level3: PackedScene = preload("res://levels/no_mans_land.scn")

func _on_button_1_button_up():
	TransitionScreen.transition(level1)

func _on_button_2_button_up():
	TransitionScreen.transition(level2)

func _on_button_3_button_up():
	TransitionScreen.transition(level3)
