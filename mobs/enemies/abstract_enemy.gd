class_name Enemy


extends CharacterBody2D


var notice_area: Area2D
var can_fly := false
var contact_damage_timer : Timer
var damage_effect_tween : Tween


@export var fall_gravity := 6000
@export var max_fall_speed := 15000
@export var behavior: Behavior
@export var contact_damage := 10
@export var weapon_damage := 30
@export var contact_damage_timeout := .5
@export var movement_speed := 5000
@export var max_health := 100
@export var score_points := 50


@onready var health : float = max_health : set = set_health
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var hurt_box : Area2D = %HurtBox

func _ready() -> void:
	GameState.mask_equipped.connect(_on_mask_change)
	notice_area.body_entered.connect(behavior.body_endered_notice_area)
	notice_area.body_exited.connect(behavior.body_exited_notice_area)
	contact_damage_timer = Timer.new()
	contact_damage_timer.one_shot = true
	contact_damage_timer.wait_time = contact_damage_timeout
	add_child(contact_damage_timer)
	behavior.speed = movement_speed
	if hurt_box:
		hurt_box.area_entered.connect(hurt)


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


func hurt(hurt_object: Area2D) -> void:
	get_damage(20)


func get_damage(damage_amount: float) -> void:
	health -= damage_amount


func set_health(new_health: float) -> void:
	health = max(0, new_health)
	if health == 0:
		die()
	
	if health > 0:
		if not damage_effect_tween:
			damage_effect_tween = get_tree().create_tween()
		damage_effect_tween.tween_property(self, "modulate", Color(0.4, 0, 0), 0.2)
		damage_effect_tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func die() -> void:
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
		GameState.score += score_points
		animation_player.animation_finished.connect(_on_animation_finished)
	
	if not animation_player or not animation_player.has_animation("death"):
		queue_free()


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "death":
		queue_free()


func _on_mask_change(mask_type: String):
	if mask_type == GameState.MASK_TYPE_RAM:
		set_collision_layer_value(1, false)
	if not mask_type == GameState.MASK_TYPE_RAM:
		set_collision_layer_value(1, true)
