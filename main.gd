extends Node2D

@onready var inventory = %InventoryWrapper
var mask_selection_audio_player : AudioStreamPlayer2D

func _ready() -> void:
	GameState.mask_added.connect(_on_mask_added)
	mask_selection_audio_player = AudioStreamPlayer2D.new();
	add_child(mask_selection_audio_player)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		inventory.show()
	if Input.is_action_just_pressed("ui_close_dialog") and inventory.visible == true:
		inventory.hide()


func _on_mask_added(mask: Mask) -> void:
	if not mask.selection_sound:
		return
	
	if mask_selection_audio_player.playing:
		mask_selection_audio_player.stop()
	
	mask_selection_audio_player.stream = mask.selection_sound
	mask_selection_audio_player.play()
	
