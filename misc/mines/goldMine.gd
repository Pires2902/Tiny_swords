extends Node2D

@export var cooldown: int = 5
var gold_cooldown: float = 0.0
var hold_time: float = 0.0
var is_player_entered: bool = false

@onready var player: Player = null

func _ready():
	$Area2D.body_entered.connect(on_body_entered)
	$Area2D.body_exited.connect(on_body_exited)
	gold_cooldown = cooldown
	
func _process(delta: float):
	if not is_player_entered or player == null:
		return
	
	gold_cooldown -= delta
	# Verificar se o jogador está interagindo
	if GameManager.player_interact:
		if gold_cooldown <= 0:
			pickGold()
			gold_cooldown = cooldown

func pickGold():
	player.gold += 2
	print("Player gold:", player.gold)

func on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		player = body
		is_player_entered = true

func on_body_exited(body: Node2D):
	if body.is_in_group("Player"):
		player = null
		is_player_entered = false
		hold_time = 0.0
