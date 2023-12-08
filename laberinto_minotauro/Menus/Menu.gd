extends Node2D



func _on_ButtonPlay_pressed():
	get_tree().change_scene("res://Levels/Labyrinth/LabLvl1.tscn")


func _on_ButtonQuit_pressed():
	get_tree().quit()


func _on_ButtonOptions_pressed():
	get_tree().change_scene("res://Menus/Options.tscn")
