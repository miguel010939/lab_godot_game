extends KinematicBody2D
class_name PlayerPlatform


export var speed = 75
export var jump_velocity = -150
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var velocity = Vector2()

var is_atacking = false

var weapon = "spear"
var spear = preload("res://Player/spear.tscn")

# timer para sincronizar el lanzamiento de la lanza con la finalizacion de la carga en la animacion
onready var spear_animation_timer = get_node("Timers/SpearThrowTimer")
var spear_throw_direction = Vector2(1, 2)


onready var anim = get_node("AnimationPlayer")
onready var player_sprite = get_node("AnimatedSprite")

func _physics_process(_delta):

	
	if not is_on_floor():
		velocity.y += gravity * _delta
	else:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_velocity
		
		if Input.is_action_pressed("ui_left"):
			velocity.x-=speed
		if Input.is_action_pressed("ui_right"):
			velocity.x+=speed
	if not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		velocity.x = move_toward(velocity.x, 0, _delta*2000)

	
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

	
	if Input.is_action_just_pressed("ui_use_weapon"):
		spear_throw()
		is_atacking = true
	if not is_atacking:
		if velocity.x != 0:
			anim.play("Moving")
		else:
			anim.play("Idle")
		
	velocity.move_toward(Vector2.ZERO, 20)
	move_and_slide(velocity, Vector2.UP)
		

func spear_throw(): # spear throwing animations
	spear_throw_direction = get_global_mouse_position() - self.position
	# animaciones diferentes segun la direccion de lanzamiento
	if spear_throw_direction.x < 0 and spear_throw_direction.y < 0:
		player_sprite.flip_h = true
		anim.play("javelin_throw_nw")
	elif spear_throw_direction.x > 0 and spear_throw_direction.y < 0:
		player_sprite.flip_h = false
		anim.play("javelin_throw_ne")
	elif spear_throw_direction.x < 0 and spear_throw_direction.y > 0:
		player_sprite.flip_h = true
		anim.play("javelin_throw_sw")
	elif spear_throw_direction.x > 0 and spear_throw_direction.y > 0:
		player_sprite.flip_h = false
		anim.play("javelin_throw_se")
	# cronometra el tiempo de la primera parte de la animacion de carga
	spear_animation_timer.start()

func instantiate_spear(dir):
	var new_spear = spear.instance()
	# configura la direccion de lanzamiento en el propio objeto Spear
	new_spear.throw_direction(dir)
	add_child(new_spear)

func damage_taken():
	var tween = get_tree().create_tween()
	tween.tween_property(player_sprite, "modulate", Color.red, 0.15)
	tween.tween_property(player_sprite, "modulate", Color.white, 0.2)


func _on_AnimationPlayer_animation_finished(_anim_name):
	# de momento no veo necesidad de espcificar la animacion terminada: cualquier annimacion que termine significa que ya no esta atacando
	is_atacking=false


func _on_SpearThrowTimer_timeout():
	# lanza la lanza
	instantiate_spear(spear_throw_direction)
	
