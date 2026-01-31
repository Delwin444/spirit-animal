extends Node

var collected_masks := [];

func add_mask(mask) -> void:
	if mask is Mask:
		for collected_mask in collected_masks:
			if collected_mask.type == mask.type:
				return
		collected_masks.push_back(mask)
