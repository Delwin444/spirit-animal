class_name Mask

extends Sprite2D

@onready var area := %Area2D
@export var type :String = "base"


func _on_area_2d_body_entered(player: Player) -> void:
	player.collect_mask(self)
	hide()
