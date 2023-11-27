extends KinematicBody2D

var speed = 100
var max_speed = 300
var std_acceleration = 1.0
var velocity = Vector2()

var is_atacking = false

var weapon = "sword"

onready var anim = get_node("AnimationPlayer")

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
		
	
	if velocity.x < 0:
		get_node("AnimatedSprite").flip_h = true
	elif velocity.x > 0:
		get_node("AnimatedSprite").flip_h = false
	
	if Input.is_action_just_pressed("ui_main_weapon"): # typing "1" selects primary weapon: sword
		weapon = "sword"
	if Input.is_action_just_pressed("ui_secondary_weapon"): # typing "2" selects secondary weapon: javelin
		weapon = "javelin"
	
	if Input.is_action_just_pressed("ui_use_weapon"):
		if weapon=="sword":
			sword_swing()
		elif weapon=="javelin":
			javelin_throw()
		
		is_atacking = true
	if not is_atacking:
		if velocity.x != 0 or velocity.y != 0:
			anim.play("Moving")
		else:
			anim.play("Idle")
		
		
	velocity=velocity.normalized()*speed
	move_and_slide(velocity)
		
func sword_swing(): # sword swinging animations
	var dir = get_global_mouse_position() - self.position
	if dir.x < 0 and dir.y < 0:
		anim.play("sword_swing_nw")
	elif dir.x > 0 and dir.y < 0:
		anim.play("sword_swing_ne")
	elif dir.x < 0 and dir.y > 0:
		anim.play("sword_swing_sw")
	elif dir.x > 0 and dir.y > 0:
		anim.play("sword_swing_se")

func javelin_throw(): # javelin throwing animations
	var dir = get_global_mouse_position() - self.position
	if dir.x < 0 and dir.y < 0:
		anim.play("javelin_throw_nw")
	elif dir.x > 0 and dir.y < 0:
		anim.play("javelin_throw_ne")
	elif dir.x < 0 and dir.y > 0:
		anim.play("javelin_throw_sw")
	elif dir.x > 0 and dir.y > 0:
		anim.play("javelin_throw_se")



func _on_AnimationPlayer_animation_finished(anim_name):
	is_atacking=false
