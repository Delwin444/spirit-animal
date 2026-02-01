extends Node


signal mask_added(mask: Mask)
signal player_health_changed(player_health: float)
signal player_died()
signal mask_equipped(mask_type: String)
signal score_updated(score: float)


var collected_masks := [];
var player : Player = null;
var max_player_health = 100
var player_health : float = max_player_health : set = _set_player_health
var equipped_mask_type : String : set = _set_equipped_mask_type
var score := 0 : set = _set_score
var is_inventory_open := false
const MAX_SCORE = 9999
const MASK_TYPE_CHEETAH = "cheetah"
const MASK_TYPE_KANGAROO = "kangaroo"
const MASK_TYPE_LLAMA = "llama"
const MASK_TYPE_RAM = "ram"



func add_mask(mask: Mask) -> void:
	for collected_mask in collected_masks:
		if collected_mask.type == mask.type:
			return
	collected_masks.push_back(mask)
	mask_added.emit(mask)


func damage_to_player(damage: float) -> void:
	player_health -= damage
	player.play_take_damage_effect()


# can't use static typehinting, gdscript doesn't support nullable yet
func get_collected_mask_by_type(mask_type: String):
	for collected_mask in collected_masks:
		if collected_mask.type == mask_type:
			return collected_mask


func _set_player_health(new_player_health) -> void:
	player_health = max(new_player_health, 0)
	player_health_changed.emit(player_health)
	if player_health == 0:
		player_died.emit()


func equip_mask(mask_type: String) -> void:
	equipped_mask_type = mask_type


func _set_equipped_mask_type(new_mask_type: String) -> void:
	if new_mask_type == equipped_mask_type:
		return
	
	equipped_mask_type = new_mask_type
	mask_equipped.emit(new_mask_type)


func _set_score(new_score: float) -> void:
	new_score = min(new_score, MAX_SCORE)
	score = new_score
	score_updated.emit(score)
