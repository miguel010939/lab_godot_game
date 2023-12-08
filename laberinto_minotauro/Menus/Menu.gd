extends Node2D



func _on_ButtonPlay_pressed():
	get_tree().change_scene("res://LabLvl1.tscn")


func _on_ButtonQuit_pressed():
	get_tree().quit()
