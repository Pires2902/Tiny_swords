extends Node


@export var speed: float = 1

var enemy: Enemy

var sprite: AnimatedSprite2D 


func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	enemy.health
	pass


func _physics_process(delta: float):
	#Parar com GameOver
	if GameManager.is_game_over: return
	#Calcular direção
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()
	
	#Movimento
	enemy.velocity = input_vector * speed * 100 
	enemy.move_and_slide()
	
	#Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
	
	
	pass
	

	
