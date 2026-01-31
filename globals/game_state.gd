extends Node


signal mask_added(mask: Mask)
signal player_died()


var collected_masks := [];
var player : Player = null;
var max_player_health = 100
var player_health : float = max_player_health : set = _set_player_health


func add_mask(mask: Mask) -> void:
	for collected_mask in collected_masks:
		if collected_mask.type == mask.type:
			return
	collected_masks.push_back(mask)
	mask_added.emit(mask)


func damage_to_player(damage: float) -> void:
	player_health -= damage


func _set_player_health(new_player_health) -> void:
	player_health = max(new_player_health, 0)
	if player_health == 0:
		player_died.emit()
