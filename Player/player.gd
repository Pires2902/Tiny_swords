class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed = 3

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene

@export_category("life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@export var gold: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitBox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $ProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var is_runing: bool = false
var was_runing: bool = false
var is_attacking: bool = false
var attack_direction: Vector2
var attack_cooldown: float = 0.0
var last_attack_time: float = 0.0
var attack_interval: float = 0.6
var attack_animations: Array = ["attack_side_1", "attack_side_2"]
var current_attack_animation: int = 0
var hitBox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
var input_interact:bool

signal meat_colected(value:int)

func _ready():
	GameManager.player = self
	meat_colected.connect(func(value: int): 
		GameManager.meat_counter += 1
	)

#Processamento p/s (void Update)
func _process(delta: float):
	GameManager.player_position = position
	GameManager.player_gold = gold
	GameManager.player_interact = input_interact
	#Ler Input
	read_Input()
	
	#Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	#Processar animação e rotação do sprite
	play_run_idle_animation()
	rotate_sprite()
	
	#Processar dano
	update_hitbox_detection(delta)
	
	#Ritual
	update_ritual(delta)
	
	# Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

#Processamento p/s da fisica 
func _physics_process(delta: float):
	# Modificar vocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking == true:
		if input_vector.y != 0:
			velocity = Vector2.ZERO
			target_velocity = Vector2.ZERO
		else:
			target_velocity *= 0.10

	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

#Processar comando do jogador
func read_Input():
	# Definir o input vector
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	
	#Apagar deadZone do input_vector
	var deadZone = 0.15
	if abs(input_vector.x) < deadZone:
		input_vector.x = 0
	if abs(input_vector.y) < deadZone:
		input_vector.y = 0.0
	
	#Definir interação
	input_interact = Input.is_action_just_pressed("interact")
	
	#atualizar o is_runing
	was_runing = is_runing
	is_runing = not input_vector.is_zero_approx()

#Idle ou Run
func play_run_idle_animation():
	# Tocar animação
	if not is_attacking:
		if was_runing != is_runing:
			if is_runing:
				animation_player.play("run")
			else:
				animation_player.play("idle")

#Girar sprite
func rotate_sprite():
	#Girar sprite
	if !is_attacking:
		if input_vector.x > 0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true

#Atacar
func attack(): 
	if is_attacking:
		return

	choose_attack_type()

	#Configurar temporizador
	attack_cooldown = attack_interval
	#Tocar ataque
	is_attacking = true

#Processar o tipo do ataque
func choose_attack_type():
	if input_vector.y > 0:
		attack_direction = Vector2.DOWN
		animation_player.play("attack_down_"+str(current_attack_animation + 1))
		current_attack_animation = (current_attack_animation + 1)%2
		attack_interval = 0.9
	elif input_vector.y < 0:
		attack_direction = Vector2.UP
		animation_player.play("attack_up_"+str(current_attack_animation + 1))
		current_attack_animation = (current_attack_animation + 1)%2
		attack_interval = 0.9
	else:
		if sprite.flip_h:
				attack_direction = Vector2.LEFT
		else:
				attack_direction = Vector2.RIGHT
		animation_player.play(attack_animations[current_attack_animation])
		current_attack_animation = (current_attack_animation + 1) % attack_animations.size()
		attack_interval = 0.6

#Processar ritual
func update_ritual(delta: float):
	ritual_cooldown -= delta
	if ritual_cooldown > 0:return
	ritual_cooldown = ritual_interval
	
	#criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


#Contar cooldown do ataque
func update_attack_cooldown(delta: float):
	#Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_runing = false
			animation_player.play("idle")

#Processar dano nos inimigos
func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0:
				enemy.damage(sword_damage)

#Detectar inimigos
func update_hitbox_detection(delta: float):
	#Temporizador
	hitBox_cooldown -= delta
	if hitBox_cooldown > 0:return
	
	#Frequencia (2x p/ segundo)
	hitBox_cooldown = 0.5
	
	#Verificar inimigo
	var damage_amount 
	var bodies = hitBox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var enemy_name = enemy.name
			if enemy_name == "goblin":
				damage_amount = 10
			elif enemy_name == "pawn":
				damage_amount = 5
			else:
				damage_amount = 1
			
			damage(damage_amount)

#Processar dano recebido
func damage(amount: int):
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health,"/",max_health)
	
	#Piscar Node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#Processar morte
	if health <= 0:
		die()

#Processar morte
func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player morreu")
	queue_free()

#Processar cura
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)
	return health
