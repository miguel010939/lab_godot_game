extends KinematicBody2D

var speed = 100
var max_speed = 300
var std_acceleration = 1.0
var velocity = Vector2()

const thread_tile_reference = {"ns":0, "sw": 1, "se": 2, "ne": 3, "nw": 4, "ew":5} # referencia de tile IDs
var last_tile = Vector2.ZERO
var target_tile = Vector2.ZERO
var next_tile = Vector2.ZERO
	
var is_atacking = false

var weapon = "javelin"
var sword = preload("res://Player/sword.tscn")
var javelin = preload("res://Player/spear.tscn")

onready var thread_tilemap = get_node("../..").get_child(1)
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
		instantiate_sword("nw")
	elif dir.x > 0 and dir.y < 0:
		anim.play("sword_swing_ne")
		instantiate_sword("ne")
	elif dir.x < 0 and dir.y > 0:
		anim.play("sword_swing_sw")
		instantiate_sword("sw")
	elif dir.x > 0 and dir.y > 0:
		anim.play("sword_swing_se")
		instantiate_sword("se")

func instantiate_sword(quadrant="nw"):
	var new_sword = sword.instance()
	new_sword.adhoc_constructor(quadrant)
	add_child(new_sword)

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
	
	instantiate_javelin(dir)

func instantiate_javelin(dir):
	var new_javelin = javelin.instance()
	new_javelin.throw_direction(dir)
	add_child(new_javelin)
	
func lay_thread():
	# inicializa los tiles para dibujar el hilo
	if last_tile == Vector2.ZERO and target_tile == Vector2.ZERO and next_tile == Vector2.ZERO:
		next_tile = thread_tilemap.world_to_map(self.position)
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
			
	if next_tile != thread_tilemap.world_to_map(self.position):
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
		
func pick_up_thread():
	var current_tile = thread_tilemap.world_to_map(self.position)
	var current_cell = thread_tilemap.get_cell(current_tile.x, current_tile.y)
	# borra en el caso de que haya algo
	if current_cell != thread_tilemap.INVALID_CELL:
		thread_tilemap.set_cell(current_tile.x, current_tile.y, -1)


func _on_AnimationPlayer_animation_finished(anim_name):
	is_atacking=false
