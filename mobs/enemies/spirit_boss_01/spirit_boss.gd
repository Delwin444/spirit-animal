extends Enemy
class_name Spirit_Boss

@onready var visual: Node2D = $Node2D
@onready var openmouth = $Node2D/ClosedMouth
@onready var open_mouth_small = $Node2D/OpenMouthSmall
@onready var open_mouth_large = $Node2D/OpenMouthLarge

var can_attack: bool = true
var attack_cooldown: float = 1.0

# Dashing
@export var dash_speed := 700.0
@export var dash_duration := 0.8
@export var dash_cooldown := 5.0
var dashing := false
var dash_time_left := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector2.ZERO

func _ready() -> void:
	notice_area = %NoticeArea
	behavior.enemy = self
	super()
	
	# Initialize mouth visibility
	openmouth.visible = true
	open_mouth_small.visible = false
	open_mouth_large.visible = false

func _physics_process(delta: float) -> void:
	# Update dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# Check if should dash (e.g., when player is detected and cooldown ready)
	if should_dash() and not dashing and dash_cooldown_timer <= 0:
		start_dash()
	
	# Process dash if active
	if dashing:
		process_dash(delta)
	else:
		# Normal behavior when not dashing
		super(delta)
	
	move_and_slide()
	handle_collisions()
	update_facing_direction()
	attack()

func should_dash() -> bool:
	# Dash towards player if they're in notice range
	# You can customize this condition based on your game logic
	if GameState.player and notice_area:
		var player_in_range = false
		for body in notice_area.get_overlapping_bodies():
			if body == GameState.player:
				player_in_range = true
				break
		return player_in_range
	return false

func start_dash() -> void:
	# Calculate direction towards player
	if GameState.player:
		dash_direction = (GameState.player.global_position - global_position).normalized()
	else:
		# Fallback to facing direction
		dash_direction = Vector2(sign(visual.scale.x), 0)
	
	# Start mouth animation (windup)
	show_mouth_animation()

func show_mouth_animation() -> void:
	# Show small mouth as windup
	openmouth.visible = false
	open_mouth_small.visible = true
	
	# Wait 700ms before opening large and starting dash
	await get_tree().create_timer(0.7).timeout
	
	# Now start the actual dash
	dashing = true
	dash_time_left = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Show large mouth during dash
	open_mouth_small.visible = false
	open_mouth_large.visible = true
	
	await get_tree().create_timer(dash_duration).timeout
	
	# Back to closed
	open_mouth_large.visible = false
	openmouth.visible = true

func process_dash(delta: float) -> void:
	dash_time_left -= delta
	
	if dash_time_left <= 0:
		dashing = false
		return
	
	# Set velocity to dash speed in dash direction
	velocity = dash_direction * dash_speed

func update_facing_direction() -> void:
	if velocity.x != 0:
		visual.scale.x = -sign(velocity.x) * abs(visual.scale.x)

func attack() -> void:
	if can_attack:
		can_attack = false
		
		# Start cooldown timer
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
