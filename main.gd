extends Node2D

@onready var inventory = %InventoryWrapper
@onready var hurt_sound = preload("res://player/player_assets/sfx_hurtPlayer.mp3")
var mask_selection_audio_player : AudioStreamPlayer2D
var player_hurt_audio_player : AudioStreamPlayer2D

func _ready() -> void:
	GameState.mask_added.connect(_on_mask_added)
	GameState.player_health_changed.connect(_on_player_health_changed)
	mask_selection_audio_player = AudioStreamPlayer2D.new();
	player_hurt_audio_player = AudioStreamPlayer2D.new();
	player_hurt_audio_player.volume_db = 20
	add_child(mask_selection_audio_player)
	add_child(player_hurt_audio_player)


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

func _on_player_health_changed(new_health: float) -> void:
	player_hurt_audio_player.stream = hurt_sound
	player_hurt_audio_player.play()
