extends Area2D
class_name Sword

# rota el sprite dependiendo del cuadrante
# no muy elegante, pero de momento funciona
func adhoc_constructor(quadrant="nw"):
	match quadrant:
		"nw":
			get_child(1).rotation_degrees = 0
		"ne":
			get_child(1).rotation_degrees = 90
		"sw":
			get_child(1).rotation_degrees = 270
		"se":
			get_child(1).rotation_degrees = 180
		_:
			queue_free()
		



func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		body.damage_taken()
