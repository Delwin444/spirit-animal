@tool
extends Area2D

var can_be_opened = false
var already_opened = false

const WHITE_KEY = "white"
const OLD_KEY = "old"
const NORMAL_KEY = "normal"
const GOLD_KEY = "gold"
const SCORE_POINTS = 100

enum chest_type {WHITE_KEY, OLD_KEY, NORMAL_KEY, GOLD_KEY}

@onready var animation_sprite = %AnimatedSprite2D
@onready var animation_player = %AnimationPlayer
@onready var mask_wrapper = %MaskWrapper
@onready var chest_open_sound = %ChestOpenSound
@export var mask : Mask
@export_enum(NORMAL_KEY, OLD_KEY, GOLD_KEY, WHITE_KEY) var type: String = NORMAL_KEY


func _ready() -> void:
	if Engine.is_editor_hint():
		# don't loop animation sprite indefinitely in editor, just load correct chest type once
		animation_sprite.animation_looped.connect(_on_editor_animation_finished)
	animation_sprite.play(str("idle_", type))


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and Input.is_action_just_pressed("open_chest") and can_be_opened and not already_opened:
		open()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		can_be_opened = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		can_be_opened = false


func open() -> void:
	chest_open_sound.play()
	animation_sprite.play(str("opening_", type))
	animation_sprite.animation_finished.connect(transfer_mask)
	already_opened = true


func add_mask_to_game_state() -> void:
	GameState.add_mask(mask)
	GameState.score += SCORE_POINTS


func transfer_mask() -> void:
	var mask_node = Sprite2D.new()
	mask_node.texture = mask.idle_sprite
	mask_node.scale = Vector2(0.05, 0.05)
	mask_wrapper.add_child(mask_node)
	animation_player.play("mask_transfer")
	animation_player.animation_finished.connect(move_mask_to_player)


func move_mask_to_player(animation_name: String) -> void:
	if (animation_name == "mask_transfer"):
		var tween = create_tween()
		tween.tween_property(mask_wrapper, "global_position", GameState.player.mask_position_marker.global_position, 0.2)
		tween.finished.connect(remove_mask_wrapper)


func remove_mask_wrapper() -> void:
	mask_wrapper.queue_free()
	GameState.equip_mask(mask.type)


func _on_editor_animation_finished() -> void:
	animation_sprite.pause()
