extends TextureButton

class_name MaskButton

var mask_type : String


func _ready() -> void:
	pressed.connect(_on_pressed)
	GameState.mask_equipped.connect(_on_mask_equipped)


func _on_pressed() -> void:
	if (mask_type):
		GameState.equip_mask(mask_type)


func _on_mask_equipped(new_mask_type: String) -> void:
	if new_mask_type == mask_type:
		modulate = Color(1, 1, 1, 1)
	if not new_mask_type == mask_type:
		modulate = Color(0.6, 0.6, 0.6, 1)
