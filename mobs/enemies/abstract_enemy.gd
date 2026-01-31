class_name Enemy

extends CharacterBody2D

var notice_area: Area2D
var can_fly := false
@export var fall_gravity := 6000
@export var max_fall_speed := 15000
@export var behavior: Behavior

func _ready() -> void:
	notice_area.body_entered.connect(behavior.body_endered_notice_area)
	notice_area.body_exited.connect(behavior.body_exited_notice_area)

func _physics_process(delta: float) -> void:
	if not can_fly:
		apply_gravity(delta)
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y += fall_gravity * delta
		
		velocity.y = minf(velocity.y, max_fall_speed)
