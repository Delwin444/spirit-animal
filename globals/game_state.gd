extends Node

signal mask_added(mask: Mask)

var collected_masks := [];
var player : Player = null;

func add_mask(mask: Mask) -> void:
	for collected_mask in collected_masks:
		if collected_mask.type == mask.type:
			return
	collected_masks.push_back(mask)
	mask_added.emit(mask)
