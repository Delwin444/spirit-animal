extends GridContainer

func _ready():
	GameState.mask_added.connect(add_mask_to_inventory)
	
func add_mask_to_inventory(mask: Mask):
	if mask == null:
		return
	var sprite2d = TextureRect.new();
	sprite2d.texture = mask.texture;
	
	add_child(sprite2d)
