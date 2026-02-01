class_name Mask

extends Sprite2D

@export_enum(
	GameState.MASK_TYPE_CHEETAH,
	GameState.MASK_TYPE_KANGAROO,
	GameState.MASK_TYPE_LLAMA
) var type : String

@export var selection_sound : AudioStreamMP3
