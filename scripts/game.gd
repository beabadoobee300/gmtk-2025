extends Node2D

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		# escape key
		end_game();
		

func end_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn");
