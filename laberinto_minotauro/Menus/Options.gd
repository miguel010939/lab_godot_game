extends Node2D



func _on_ButtonEasy_pressed():
	Game.player_health = 16
	Game.enemy_A_health = 8
	
	get_tree().change_scene("res://Menus/Menu.tscn")


func _on_ButtonNormal_pressed():
	Game.player_health = 12
	Game.enemy_A_health = 12
	
	get_tree().change_scene("res://Menus/Menu.tscn")


func _on_ButtonHard_pressed():
	Game.player_health = 8
	Game.enemy_A_health = 16
	
	get_tree().change_scene("res://Menus/Menu.tscn")
