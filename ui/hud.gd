extends Control

@onready var score = $Score
@onready var health = $Health

func _ready() -> void:
	GameState.score_updated.connect(set_score_label)
	GameState.player_health_changed.connect(set_health_label)


func set_score_label(new_score):
	score.text = "SCORE: " + str(new_score)

func set_health_label(new_health):
	health.text = "HEALTH: " + str(new_health)
	
