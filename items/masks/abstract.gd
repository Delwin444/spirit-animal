class_name Mask

extends Resource

@export_enum(
	GameState.MASK_TYPE_CHEETAH,
	GameState.MASK_TYPE_KANGAROO,
	GameState.MASK_TYPE_LLAMA,
	GameState.MASK_TYPE_RAM
) var type : String

@export var selection_sound : AudioStreamMP3
@export var idle_sprite : Texture2D
@export var run_sprite : Texture2D
