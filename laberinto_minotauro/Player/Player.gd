extends KinematicBody2D
class_name Player
export var speed = 100
#onready var game = get_node("/root/Game")
var health = Game.player_health

var velocity = Vector2()

const thread_tile_reference = {"ns":0, "sw": 1, "se": 2, "ne": 3, "nw": 4, "ew":5} # referencia de tile IDs
var last_tile = Vector2.ZERO
var target_tile = Vector2.ZERO
var next_tile = Vector2.ZERO
export var thread_remaining = 100

var is_atacking = false

var weapon = "spear"
var sword = preload("res://Player/sword.tscn")
var spear = preload("res://Player/spear.tscn")

# timer para sincronizar el espadazo con la finalizacion de la primera parte de la animacion de la estocada
onready var sword_animation_timer = get_node("Timers/SwordSwingTimer")
var quadrant_sword_swing
# timer para sincronizar el lanzamiento de la lanza con la finalizacion de la carga en la animacion
onready var spear_animation_timer = get_node("Timers/SpearThrowTimer")
var spear_throw_direction = Vector2(1, 2)

onready var thread_tilemap = get_node("../").get_child(2)
onready var anim = get_node("AnimationPlayer")
onready var player_sprite = get_node("AnimatedSprite")

func _physics_process(_delta):
	velocity = Vector2.ZERO
	check_alive()

	if Input.is_action_pressed("ui_left"):
		velocity.x-=1
	if Input.is_action_pressed("ui_right"):
		velocity.x+=1
	if Input.is_action_pressed("ui_up"):
		velocity.y-=1
	if Input.is_action_pressed("ui_down"):
		velocity.y+=1
	
	
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

	# deja hilo
	if Input.is_action_pressed("ui_set_thread"):
		lay_thread()
	# resetea las variables de posicion de los tiles
	if Input.is_action_just_released("ui_set_thread"):
		last_tile = Vector2.ZERO
		target_tile = Vector2.ZERO
		next_tile = Vector2.ZERO
	# recoge el hilo
	if Input.is_action_pressed("ui_remove_thread"):
		pick_up_thread()
		
	if Input.is_action_just_pressed("ui_main_weapon"): # typing "1" selects primary weapon: sword
		weapon = "sword"
	if Input.is_action_just_pressed("ui_secondary_weapon"): # typing "2" selects secondary weapon: spear
		weapon = "spear"
	
	if Input.is_action_just_pressed("ui_use_weapon"):
		if weapon=="sword":
			# animacion de la estocada de Player en el cuadrante correspondiente
			quadrant_sword_swing = sword_swing()
			# inicia el temporizador
			sword_animation_timer.start()
		elif weapon=="spear":
			spear_throw()
		is_atacking = true
	if not is_atacking:
		if velocity.x != 0 or velocity.y != 0:
			anim.play("Moving")
		else:
			anim.play("Idle")
		
		
	velocity=velocity.normalized()*speed
# warning-ignore:return_value_discarded
	move_and_slide(velocity)
		
func sword_swing(): # sword swinging animations
	var dir = get_global_mouse_position() - self.position
	if dir.x < 0 and dir.y < 0:
		player_sprite.flip_h = true
		anim.play("sword_swing_nw")
		return "nw"
	elif dir.x > 0 and dir.y < 0:
		player_sprite.flip_h = false
		anim.play("sword_swing_ne")
		return "ne"
	elif dir.x < 0 and dir.y > 0:
		player_sprite.flip_h = true
		anim.play("sword_swing_sw")
		return "sw"
	elif dir.x > 0 and dir.y > 0:
		player_sprite.flip_h = false
		anim.play("sword_swing_se")
		return "se"
	else:
		return

func instantiate_sword(quadrant="nw"):
	var new_sword = sword.instance()
	new_sword.adhoc_constructor(quadrant)
	add_child(new_sword)

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
	
# 
func lay_thread():
	# inicializa los tiles para dibujar el hilo
	if last_tile == Vector2.ZERO and target_tile == Vector2.ZERO and next_tile == Vector2.ZERO:
		next_tile = thread_tilemap.world_to_map(self.position)
		# extrapola una tile inicial "virtual" según la direccion opuesta de la velocidad actual
		if self.velocity.abs().aspect() >= 1:
			if self.velocity.x>0:
				target_tile = next_tile + Vector2.LEFT
			else:
				target_tile = next_tile + Vector2.RIGHT
		else:
			if self.velocity.y>0:
				target_tile = next_tile + Vector2.DOWN
			else:
				target_tile = next_tile + Vector2.UP
			
	if next_tile != thread_tilemap.world_to_map(self.position) and thread_remaining>0:
		# actualiza las variables comodin
		last_tile = target_tile
		target_tile = next_tile
		next_tile = thread_tilemap.world_to_map(self.position)
		# desplazamientos respecto a la celda que hay que dibujar
		var d1 = next_tile - target_tile
		var d2 = last_tile - target_tile
		var corner = "ns" 
		# el tipo de la esquina para el tile
		if (d1 == Vector2.RIGHT or d2 == Vector2.RIGHT) and (d1 == Vector2.UP or d2 == Vector2.UP):
			corner = "ne"
		elif (d1 == Vector2.LEFT or d2 == Vector2.LEFT) and (d1 == Vector2.UP or d2 == Vector2.UP):
			corner = "nw"
		elif (d1 == Vector2.LEFT or d2 == Vector2.LEFT) and (d1 == Vector2.DOWN or d2 == Vector2.DOWN):
			corner = "sw"
		elif (d1 == Vector2.RIGHT or d2 == Vector2.RIGHT) and (d1 == Vector2.DOWN or d2 == Vector2.DOWN):
			corner = "se"
		elif (d1 == Vector2.DOWN and d2 == Vector2.UP) or (d1 == Vector2.UP and d2 == Vector2.DOWN):
			corner = "ns"
		elif (d1 == Vector2.RIGHT and d2 == Vector2.LEFT) or (d1 == Vector2.LEFT and d2 == Vector2.RIGHT):
			corner = "ew"
		# dibuja la celda 
		thread_tilemap.set_cell(target_tile.x, target_tile.y, thread_tile_reference[corner])
		thread_remaining -= 1
		
func pick_up_thread():
	var current_tile = thread_tilemap.world_to_map(self.position)
	var current_cell = thread_tilemap.get_cell(current_tile.x, current_tile.y)
	# borra en el caso de que haya algo
	if current_cell != thread_tilemap.INVALID_CELL:
		thread_tilemap.set_cell(current_tile.x, current_tile.y, -1)
		thread_remaining += 1

func damage_taken():
	var tween = get_tree().create_tween()
	tween.tween_property(player_sprite, "modulate", Color.red, 0.15)
	tween.tween_property(player_sprite, "modulate", Color.white, 0.2)
	
	health -= Game.enemy_A_dmg



func _on_AnimationPlayer_animation_finished(_anim_name):
	# de momento no veo necesidad de espcificar la animacion terminada: cualquier annimacion que termine significa que ya no esta atacando
	is_atacking=false


func _on_SwordSwingTimer_timeout():
	# "crea" la espada
	instantiate_sword(quadrant_sword_swing)

func _on_SpearThrowTimer_timeout():
	# lanza la lanza
	instantiate_spear(spear_throw_direction)
	
func check_alive():
	if health <= 0:
		queue_free()
		get_tree().change_scene("res://Menus/Menu.tscn")


func _on_ButtonTP_pressed():
	self.position.x = get_parent().checkpoint_X
	self.position.y = get_parent().checkpoint_Y 
