extends Node2D

@onready var inventory = %Inventory

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		inventory.show()
	if Input.is_action_just_pressed("ui_close_dialog") and inventory.visible == true:
		inventory.hide()
