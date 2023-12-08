extends KinematicBody2D

#onready var game = get_node("/root/Game")

export var sight_range = 150
export var speed = 1
var velocity = Vector2()
var health = Game.enemy_A_health

var rng = RandomNumberGenerator.new()
var player_detected = false
var player

onready var sprite = get_node("AnimatedSprite")
onready var animation = get_node("AnimationPlayer")
onready var ray1 = get_node("RayCast_1")
onready var ray2 = get_node("RayCast_2")
onready var area_atack = get_node("AreaAtack")

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	check_alive()
	
	detect_player()
	if player_detected:
		look_at_player()
		chase_player()
	
	animate()
	velocity=velocity.normalized()*speed
	move_and_slide(velocity)

func animate():
	if velocity.x < 0:
		sprite.flip_h=true
	else:
		sprite.flip_h=false
	
	if velocity.x == 0 and velocity.y == 0:
		animation.play("idle")
	else:
		animation.stop()

func damage_taken(amount):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color.red, 0.15)
	tween.tween_property(sprite, "modulate", Color.white, 0.2)
	
	health -= amount

func detect_player():
	if ray1.is_colliding() and ray1.get_collider().is_in_group("player"):
		player_detected=true
		player = ray1.get_collider()
	elif ray2.is_colliding() and ray2.get_collider().is_in_group("player"):
		player_detected=true
		player = ray2.get_collider()
	else:
		player_detected=false

func chase_player():
	velocity = (player.position-self.position).normalized()

func look_at_player():
	var direction = (player.position-self.position).normalized()
	ray1.cast_to.x = sight_range*direction.x
	ray1.cast_to.y = sight_range*direction.y
	ray2.cast_to.x = sight_range*direction.x
	ray2.cast_to.y = sight_range*direction.y

func look_around():
	var direction = random_direction()
	ray1.cast_to.x = sight_range*cos(direction)
	ray1.cast_to.y = sight_range*sin(direction)
	ray2.cast_to.x = sight_range*cos(direction)
	ray2.cast_to.y = sight_range*sin(direction)
	if ray1.cast_to.x < 0:
		sprite.flip_h=true
	else:
		sprite.flip_h=false
	
func random_direction():
	var dir_4 = rng.randi_range(0, 3)
	var dir_cont = rng.randfn(0.0, 0.25)
	return dir_cont + dir_4*PI/2
	
	

func _on_TimerLookAround_timeout():
	if not player_detected:
		look_around()

func atack(body):
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", (body.position-self.position)*0.85, 0.25)
	tween.tween_property(sprite, "position", Vector2.ZERO, 0.3)
	body.health -= 1
	body.damage_taken()

func _on_AreaAtack_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_detected=true
		look_at_player()
		atack(body)


func _on_AreaAtack_body_exited(body):
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("spear"):
		damage_taken(Game.spear_dmg)
		body.queue_free()


func _on_TimerDmgOverTime_timeout():
	if area_atack.overlaps_body(player):
		player.damage_taken()

func check_alive():
	if health <= 0:
		queue_free()
