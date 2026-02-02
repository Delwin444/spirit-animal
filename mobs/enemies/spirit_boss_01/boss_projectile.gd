extends AnimatedSprite2D

signal projectile_finished

@export var speed := 400.0  # Speed of the projectile
@export var beam_duration := 3.0  # How long the beam lasts
@export var beam_scale := Vector2(0.5, 0.5)  # Scale of the beam sprite
var direction := Vector2.RIGHT
var time_alive := 0.0
var is_active := false

@onready var hitbox: Area2D = $Hitbox  # You'll need to add this as a child node

func _ready() -> void:
	# Set scale
	scale = beam_scale
	
	# Setup hitbox if it exists
	if hitbox:
		hitbox.body_entered.connect(_on_body_entered)
		hitbox.area_entered.connect(_on_area_entered)
	
	# Normalize direction to left or right only
	direction.y = 0
	if direction.x == 0:
		direction.x = 1
	direction = direction.normalized()
	
	# Rotate to face direction (0 for right, 180 for left)
	rotation = 0.0 if direction.x > 0 else PI
	
	# Flip sprite if needed instead of rotating
	flip_h = direction.x < 0
	
	# Start beam animation
	play("default")  # Make sure you have a "default" animation or change this
	is_active = true

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	# Move the projectile
	position += direction * speed * delta
	
	# Track time
	time_alive += delta
	
	# Auto-destroy after duration
	if time_alive >= beam_duration:
		finish_projectile()

func _on_body_entered(body: Node2D) -> void:
	# Hit the player
	if body is Player:
		GameState.damage_to_player(5)
		finish_projectile()

func _on_area_entered(area: Area2D) -> void:
	# Hit something else
	if area.has_method("take_damage"):
		area.take_damage(1)
		finish_projectile()

func finish_projectile() -> void:
	if not is_active:
		return
	
	is_active = false
	projectile_finished.emit()
	queue_free()
