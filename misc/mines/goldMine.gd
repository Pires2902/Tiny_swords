extends Node2D

@onready var gold_player = GameManager.player_gold

@export var required_hold_time: float = 2.0
var hold_time: float = 0.0

var is_player_entered: bool = false 

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func _process(delta: float):
	if is_player_entered == false:return
	
	if Input.is_action_pressed("interact"):
		hold_time += delta
		if hold_time >= required_hold_time:
			pickGold()
			# Reinicia o hold_time
			hold_time = 0.0
	else:
		hold_time = 0.0

func pickGold():
	gold_player += 2

func on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		var player: Player = body
		is_player_entered = true
