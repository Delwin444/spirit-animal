class_name Player

extends CharacterBody2D

enum State {
	GROUND,
	JUMP,
	FALL
}

const MAX_JUMPS := 2

@export var acceleration := 700
@export var deceleration := 1400
@export var max_fall_speed := 250

@export var jump_horizontal_distance := 80
@export var jump_height := 50
@export var jump_time_to_peak := 0.37
@export var jump_time_to_descent := 0.3
@export var jump_cut_value := 15

@export var double_jump_height := 30
@export var double_jump_time_to_peak := 0.3
@export var double_jump_time_to_descent := 0.25

var direction_x := 0.0
var current_state: State = State.GROUND

# State-specific variables
var jump_released := false
var coyote_time_active := false
var jump_count := 0

var active_mask_sprite: Sprite2D;

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var mask_position_marker: Marker2D = %MaskPositionMarker
@onready var projectile_spawn_point: Marker2D = %ProjectileSpawnPoint

# Primary jump calculations
@onready var max_speed := calculate_max_speed(jump_horizontal_distance, jump_time_to_peak, jump_time_to_descent)
@onready var jump_speed := calculate_jump_speed(jump_height, jump_time_to_peak)
@onready var jump_gravity := calculate_jump_gravity(jump_height, jump_time_to_peak)
@onready var fall_gravity := calculate_fall_gravity(jump_height, jump_time_to_descent)
@onready var jump_cut_speed := fall_gravity / jump_cut_value

# Double jump calculations
@onready var double_jump_speed := calculate_jump_speed(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_gravity := calculate_jump_gravity(double_jump_height, double_jump_time_to_peak)
@onready var double_jump_fall_gravity := calculate_fall_gravity(double_jump_height, double_jump_time_to_descent)

# Combat stuff
@onready var attacking = false

@onready var top_attack_animation = $AnimatedSprite2D/BasicAttack/SwordTop/TopAttackAnimation
@onready var bottom_attack_animation = $AnimatedSprite2D/BasicAttack/SwordBottom/BottomAttackAnimation
@onready var left_attack_animation = $AnimatedSprite2D/BasicAttack/SwordLeft/LeftAttackAnimation
@onready var right_attack_animation = $AnimatedSprite2D/BasicAttack/SwordRight/RightAttackAnimation

# Dashing
@onready var dashing = false
@export var dash_speed := 250.0
@export var dash_duration := 0.2
@export var dash_cooldown := 0.5
var dash_time_left := 0.0
var dash_direction := Vector2.ZERO
var dash_cooldown_timer := 0.0
var is_invincible = false

# Projectile
@export var projectile_scene: PackedScene = preload("res://player/projectile.tscn")
@export var projectile_cooldown := 0.3
var projectile_cooldown_timer := 0.0
var last_move_direction := Vector2.RIGHT  # Track for projectile direction

func _ready() -> void:
	_transition_to_state(current_state)
	GameState.player = self
	
	# Connect all attack animations to the finished handler
	top_attack_animation.animation_finished.connect(_on_attack_finished)
	bottom_attack_animation.animation_finished.connect(_on_attack_finished)
	left_attack_animation.animation_finished.connect(_on_attack_finished)
	right_attack_animation.animation_finished.connect(_on_attack_finished)

func _process(delta: float) -> void:
	pass

func attack():
	if attacking:
		return
	
	attacking = true
	
	# Check directional input and play corresponding attack
	if Input.is_action_pressed("move_up"):
		top_attack_animation.play("top_attack")
	elif Input.is_action_pressed("move_down"):
		bottom_attack_animation.play("bottom_attack")
	elif Input.is_action_pressed("move_left"):
		left_attack_animation.play("left_attack")
	elif Input.is_action_pressed("move_right"):
		right_attack_animation.play("right_attack")
	else:
		# Default attack based on last facing direction
		if animated_sprite.flip_h:
			left_attack_animation.play("left_attack")
		else:
			right_attack_animation.play("right_attack")

func _on_attack_finished(anim_name: String) -> void:
	attacking = false

func dash():
	if dashing or dash_cooldown_timer > 0:
		return
	
	dashing = true
	is_invincible = true
	dash_time_left = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Determine dash direction
	if direction_x != 0:
		dash_direction = Vector2(direction_x, 0)
	else:
		# Dash in facing direction if not moving
		dash_direction = Vector2(-1 if animated_sprite.flip_h else 1, 0)

func process_dash(delta: float) -> void:
	dash_time_left -= delta
	
	if dash_time_left <= 0:
		dashing = false
		is_invincible = false
		print("Iframes over")
		return
	
	# Set velocity to dash speed
	velocity.x = dash_direction.x * dash_speed
	velocity.y = 0  # Cancel gravity

func get_shoot_direction() -> Vector2:
	# Get 8-directional input
	var input_x = Input.get_axis("move_left", "move_right")
	var input_y = Input.get_axis("move_up", "move_down")
	
	if input_x != 0 or input_y != 0:
		var dir = Vector2(input_x, input_y).normalized()
		last_move_direction = dir
		return dir
	
	# If no input, use last direction or facing direction
	if last_move_direction != Vector2.ZERO:
		return last_move_direction
	
	# Fallback to facing direction
	return Vector2(-1 if animated_sprite.flip_h else 1, 0)

func shoot_projectile():
	if projectile_cooldown_timer > 0 or projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	
	# Use spawn point if it exists, otherwise use player position with offset
	if projectile_spawn_point:
		projectile.global_position = projectile_spawn_point.global_position
	else:
		projectile.global_position = global_position + Vector2(0, -40)  # Offset upward
	
	projectile.direction = get_shoot_direction()
	
	get_parent().add_child(projectile)
	projectile_cooldown_timer = projectile_cooldown

func _physics_process(delta: float) -> void:
	direction_x = signf(Input.get_axis("move_left", "move_right"))
	
	# Update all cooldowns
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if projectile_cooldown_timer > 0:
		projectile_cooldown_timer -= delta
	
	# CHECK ATTACK INPUT FIRST - before any state processing
	if Input.is_action_just_pressed("basic_attack"):
		attack()
	
	# CHECK PROJECTILE INPUT
	if Input.is_action_just_pressed("shoot"):
		shoot_projectile()
	
	# Check for dash input
	if Input.is_action_just_pressed("dash") and not dashing and dash_cooldown_timer <= 0:
		dash()
	
	# If dashing, override normal behavior
	if dashing:
		process_dash(delta)
		move_and_slide()
		return
	
	# Normal state processing
	match current_state:
		State.GROUND:
			process_ground_state(delta)
		State.JUMP:
			process_jump_state(delta)
		State.FALL:
			process_fall_state(delta)
	
	apply_gravity(delta)
	move_and_slide()


## Applies gravity to the player based on the current state, to get the exact
## jump and fall timings and peak heights we calculated.
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= 0:
			# When falling, we check if this is after a double jump
			if jump_count == 2 and not jump_released:
				velocity.y += double_jump_fall_gravity * delta
			else:
				velocity.y += fall_gravity * delta
		else:
			# When rising, check if this is from a double jump
			if jump_count == 2 and not jump_released:
				velocity.y += double_jump_gravity * delta
			else:
				velocity.y += jump_gravity * delta
		velocity.y = minf(velocity.y, max_fall_speed)


## Calculates the maximum horizontal speed based on jump parameters
func calculate_max_speed(distance: float, time_to_peak: float, time_to_descent: float) -> float:
	return distance / (time_to_peak + time_to_descent)


## Calculates the initial jump velocity needed to reach a certain height
## Returns a negative value so you can directly apply it to velocity.y
func calculate_jump_speed(height: float, time_to_peak: float) -> float:
	return (-2.0 * height) / time_to_peak


## Calculates the gravity to apply while rising during a jump to reach the desired height
func calculate_jump_gravity(height: float, time_to_peak: float) -> float:
	return (2.0 * height) / pow(time_to_peak, 2.0)


## Calculates the gravity to apply while falling to get a consistent parabolic jump that matches the desired height
func calculate_fall_gravity(height: float, time_to_descent: float) -> float:
	return (2.0 * height) / pow(time_to_descent, 2.0)


func process_ground_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump(jump_speed)

	var is_moving := absf(direction_x) > 0.0
	if is_moving:
		velocity.x += acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)

		animated_sprite.flip_h = direction_x < 0.0
		animated_sprite.play("Run")

		# Track ranged attack direction
		last_move_direction = Vector2(direction_x, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

		animated_sprite.play("Idle")

	if not is_on_floor():
		_transition_to_state(State.FALL)



func process_jump_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		jump(double_jump_speed)
	elif Input.is_action_just_released("jump"):
		if velocity.y < 0 and velocity.y < -jump_cut_speed and not jump_released:
			velocity.y = -jump_cut_speed
			jump_released = true

	if is_on_ceiling():
		velocity.y = 0

	if is_on_floor():
		_transition_to_state(State.GROUND)

	if velocity.y >= 0:
		_transition_to_state(State.FALL)

	if direction_x != 0:
		velocity.x += acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		animated_sprite.flip_h = direction_x < 0.0

		last_move_direction = Vector2(direction_x, 0)


func process_fall_state(delta: float) -> void:
	if is_on_floor():
		_transition_to_state(State.GROUND)
		return

	if Input.is_action_just_pressed("jump"):
		if coyote_time_active:
			jump(jump_speed)
		elif jump_count < MAX_JUMPS:
			jump(double_jump_speed)

	if direction_x != 0.0:
		velocity.x += acceleration * direction_x * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
		animated_sprite.flip_h = direction_x < 0.0
		
		last_move_direction = Vector2(direction_x, 0)



## Performs a jump with specified force
## Handles both regular jumps and double jumps
func jump(jump_force: float) -> void:

	if current_state == State.GROUND:
		# First jump from ground
		jump_count = 1
		_transition_to_state(State.JUMP)
	else:
		# This could be a coyote jump or a double jump
		if coyote_time_active:
			# If we're in coyote time, this is still the first jump
			jump_count = 1
			_transition_to_state(State.JUMP)
		else:
			# Double jump
			jump_count = 2
			animated_sprite.play("Jump")
			play_tween_jump()

	velocity.y = jump_force


func _transition_to_state(new_state: State) -> void:
	var previous_state := current_state
	current_state = new_state

	# Exit previous state
	match previous_state:
		State.GROUND:
			pass
		State.JUMP:
			jump_released = false
		State.FALL:
			coyote_time_active = false

	# Enter new state
	match current_state:
		State.GROUND:
			floor_snap_length = 8.0

			if previous_state == State.FALL:
				play_tween_touch_ground()
				jump_count = 0

		State.JUMP:
			floor_snap_length = 0.0
			animated_sprite.play("Jump")

		State.FALL:
			floor_snap_length = 0.0
			animated_sprite.play("Fall")

			if previous_state == State.GROUND:
				coyote_time_active = true
				get_tree().create_timer(0.1).timeout.connect(func(): coyote_time_active = false)


func play_tween_touch_ground() -> void:
	var tween := create_tween()
	tween.tween_property(animated_sprite, "scale", Vector2(1.1, 0.9), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2(0.9, 1.1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.15)


func play_tween_jump() -> void:
	var tween := create_tween()
	tween.tween_property(animated_sprite, "scale", Vector2(1.2, 0.8), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2(0.8, 1.2), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.15)


func collect_mask(mask: Mask) -> void:
	GameState.add_mask(mask)
	
	if (active_mask_sprite is not Sprite2D):
		active_mask_sprite = Sprite2D.new()
		
	active_mask_sprite.texture = mask.texture
	active_mask_sprite.position = mask_position_marker.position
	active_mask_sprite.scale = mask.scale
	
	if !active_mask_sprite.get_parent():
		self.add_child(active_mask_sprite);
	
