extends GridContainer

@onready var maxAmountOfMasks = 0

func _ready():
	GameState.mask_added.connect(add_mask_to_inventory)
	
func add_mask_to_inventory(mask: Mask):
	if mask == null:
		return
	var mask_button = MaskButton.new();
	mask_button.texture_normal = mask.idle_sprite;
	mask_button.mask_type = mask.type
	mask_button.ignore_texture_size = true
	mask_button.custom_minimum_size = Vector2(100, 200)
	mask_button.stretch_mode = TextureButton.STRETCH_SCALE
	
	add_child(mask_button)
	maxAmountOfMasks += 1

func get_inv_controller_dir():
	var inputRight = 0
	var inputLeft = 0
	var itemSelected = 0
	
	if Input.is_action_just_pressed("inv_right"):
		inputRight = 1
	
	if Input.is_action_just_pressed("inv_left"):
		inputLeft = 1
	itemSelected = inputRight - inputLeft
	if itemSelected <= 0: itemSelected = maxAmountOfMasks
	elif itemSelected >= maxAmountOfMasks: itemSelected = 0
	
	return itemSelected
