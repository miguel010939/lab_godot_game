extends Area2D
class_name Sword

var enemy
var quad
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
	quad = quadrant
	


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy") and is_in_quadrant(body):
		body.damage_taken()

func is_in_quadrant(enemy):
	var quadrant
	var dir = (enemy.position - self.global_position)

	if dir.y > 0:
		if dir.x > 0:
			quadrant="se"
		else:
			quadrant="sw"
	else:
		if dir.x > 0:
			quadrant="ne"
		else:
			quadrant="nw"
	
	return quadrant == self.quad
