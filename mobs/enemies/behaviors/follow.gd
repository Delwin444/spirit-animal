extends Behavior

class_name Follow

func _physics_process(delta: float) -> void:
	if noticed_player:
		var directory = enemy.global_position.direction_to(GameState.player.global_position)
		enemy.velocity = speed * directory * delta
	if not noticed_player:
		enemy.velocity = Vector2.ZERO
