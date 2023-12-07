extends KinematicBody2D

const SPEED = 300.0
var direction= Vector2.ZERO
var velocity = Vector2.ZERO

func throw_direction(dir: Vector2):
	direction = dir.normalized()
	# velocidad segun la direccion
	velocity=direction*SPEED
	var angle = atan(direction.y/direction.x)*(360/(2*PI))
	# gira el sprite para que tenga sentido, segun la direccion de lanzamiento
	if direction.x <= 0:
		get_child(0).rotation_degrees += angle-90.0
	else:
		get_child(0).rotation_degrees += angle+90.0

func _physics_process(delta):
	
	move_and_slide(velocity)
	
