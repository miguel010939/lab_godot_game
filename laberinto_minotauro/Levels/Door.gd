extends Node2D

onready var anim_sprite = get_node("AnimatedSprite")
onready var timer_change_scene = get_node("TimerChangeScene")
onready var door = get_node("Area2D")
export var scene: String

var open = false
var player

func _physics_process(delta):
	if open and door.overlaps_body(player) and Input.is_action_just_pressed("ui_accept"):
		enter_door()

func enter_door():
	print("were going in")
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(self.get_parent(), "modulate", Color.black, 0.5)
	tween2.tween_property(self.get_parent().get_child(0).get_child(0).get_child(0), "modulate", Color.black, 0.5)
	timer_change_scene.start()
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		open = true
		player = body
		anim_sprite.play("open")


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		open = false
		anim_sprite.play("open", true)
		#anim_sprite.frame=0


func _on_TimerChangeScene_timeout():
	get_tree().change_scene(scene)
