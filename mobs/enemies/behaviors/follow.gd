extends Behavior

class_name Follow

func _physics_process(delta: float) -> void:
	if noticed_player:
		var direction = enemy.global_position.direction_to(GameState.player.global_position)
		
		if not enemy.can_fly:
			direction.y = 0
			
		enemy.velocity = speed * direction * delta
	if not noticed_player:
		enemy.velocity = Vector2.ZERO
