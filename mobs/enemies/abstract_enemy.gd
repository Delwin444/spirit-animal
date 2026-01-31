class_name Enemy


extends CharacterBody2D


var notice_area: Area2D
var can_fly := false
var contact_damage_timer : Timer


@export var fall_gravity := 6000
@export var max_fall_speed := 15000
@export var behavior: Behavior
@export var contact_damage := 10
@export var weapon_damage := 30
@export var contact_damage_timeout := .5


func _ready() -> void:
	notice_area.body_entered.connect(behavior.body_endered_notice_area)
	notice_area.body_exited.connect(behavior.body_exited_notice_area)
	contact_damage_timer = Timer.new()
	contact_damage_timer.one_shot = true
	contact_damage_timer.wait_time = contact_damage_timeout
	add_child(contact_damage_timer)


func _physics_process(delta: float) -> void:
	if not can_fly:
		apply_gravity(delta)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y += fall_gravity * delta
		
		velocity.y = minf(velocity.y, max_fall_speed)


func handle_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Player:
			collision_with_player()


func collision_with_player() -> void:
	if contact_damage_timer.time_left == 0:
		collision_hurt_player()
		contact_damage_timer.start()


func collision_hurt_player() -> void:
	GameState.damage_to_player(contact_damage)
