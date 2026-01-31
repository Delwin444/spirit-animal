extends Behavior

class_name KeepDistance

func _physics_process(delta: float) -> void:
	# race condition if behavior is ready before parent enemy node
	if not enemy:
		return
	
	if noticed_player:
		var direction = GameState.player.global_position.direction_to(enemy.global_position)
		
		if not enemy.can_fly:
			direction.y = 0
			
		enemy.velocity = speed * direction * delta
	if not noticed_player:
		enemy.velocity = Vector2.ZERO
