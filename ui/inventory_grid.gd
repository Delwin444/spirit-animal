extends GridContainer

func _ready():
	GameState.mask_added.connect(add_mask_to_inventory)
	
func add_mask_to_inventory(mask: Mask):
	if mask == null:
		return
	var mask_button = MaskButton.new();
	mask_button.texture_normal = mask.texture;
	mask_button.mask_type = mask.type
	mask_button.ignore_texture_size = true
	mask_button.custom_minimum_size = Vector2(100, 200)
	mask_button.stretch_mode = TextureButton.STRETCH_SCALE
	
	add_child(mask_button)
