extends Control

func _on_button_1_button_up():
	TransitionScreen.transition(load("res://levels/tutorial.scn"))

func _on_button_2_button_up():
	TransitionScreen.transition(load("res://levels/t_bone.scn"))

func _on_button_3_button_up():
	TransitionScreen.transition(load("res://levels/no_mans_land.scn"))
