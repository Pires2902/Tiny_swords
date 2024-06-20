extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel
@onready var monsters_label: Label = %MonstersLabel
@onready var gold_label: Label = %GoldLabel

func _process(delta: float):
	# Update labels
	timer_label.text = GameManager.time_elepsed_string
	meat_label.text = str(GameManager.meat_counter)
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	gold_label.text = str(GameManager.player_gold)
