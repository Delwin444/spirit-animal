extends Control

@onready var score = $Score

func _ready() -> void:
	GameState.score_updated.connect(set_score_label)


func set_score_label(new_score):
	score.text = "SCORE: " + str(new_score)
