extends KinematicBody2D

var speed = 100
var max_speed = 300
var std_acceleration = 1.0
var velocity = Vector2()

func _physics_process(delta):
	velocity=Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x-=1
	if Input.is_action_pressed("ui_right"):
		velocity.x+=1
	if Input.is_action_pressed("ui_up"):
		velocity.y-=1
	if Input.is_action_pressed("ui_down"):
		velocity.y+=1
		
	if velocity==Vector2.ZERO:
		speed = 100
	elif speed < max_speed:
		speed+= std_acceleration*delta
		
	velocity=velocity.normalized()*speed
	move_and_slide(velocity)

