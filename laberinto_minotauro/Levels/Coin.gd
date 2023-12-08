extends Area2D

onready var sound_effect = get_node("AudioStreamPlayer2D")
onready var anim_sprite = get_node("AnimatedSprite")


func _ready():
	anim_sprite.play("rotating")

func _on_Coin_body_entered(body):
	if body.is_in_group("player"):
		sound_effect.play()
		Game.gold_coins += 1
		queue_free()
