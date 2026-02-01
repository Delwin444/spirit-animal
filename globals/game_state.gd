extends Node


signal mask_added(mask: Mask)
signal player_died()
signal mask_equipped(mask_type: String)


var collected_masks := [];
var player : Player = null;
var max_player_health = 100
var player_health : float = max_player_health : set = _set_player_health
var equipped_mask_type : String : set = _set_equipped_mask_type
const MASK_TYPE_CHEETAH = "cheetah"
const MASK_TYPE_KANGAROO = "kangaroo"
const MASK_TYPE_LLAMA = "llama"



func add_mask(mask: Mask) -> void:
	for collected_mask in collected_masks:
		if collected_mask.type == mask.type:
			return
	collected_masks.push_back(mask)
	mask_added.emit(mask)


func damage_to_player(damage: float) -> void:
	player_health -= damage


# can't use static typehinting, gdscript doesn't support nullable yet
func get_collected_mask_by_type(mask_type: String):
	for collected_mask in collected_masks:
		if collected_mask.type == mask_type:
			return collected_mask


func _set_player_health(new_player_health) -> void:
	player_health = max(new_player_health, 0)
	if player_health == 0:
		player_died.emit()


func equip_mask(mask_type: String) -> void:
	equipped_mask_type = mask_type


func _set_equipped_mask_type(new_mask_type: String) -> void:
	if new_mask_type == equipped_mask_type:
		return
	
	equipped_mask_type = new_mask_type
	mask_equipped.emit(new_mask_type)
	
