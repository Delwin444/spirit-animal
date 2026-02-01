extends Area2D

@export var speed := 1200.0
@export var lifetime := 2.0  # Seconds before auto-destroying
@export var damage := 50

var direction := Vector2.RIGHT
var time_alive := 0.0

func _ready() -> void:
	# Connect to detect hits
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Normalize direction
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Rotate to face direction
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	# Auto-destroy after lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.get_damage(damage)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Hit an enemy or damageable area
	if area.has_method("take_damage"):
		area.take_damage(1)
	queue_free()
