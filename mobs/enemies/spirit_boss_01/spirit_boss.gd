extends Enemy

class_name Spirit_Boss

@onready var sweep_attack_animator = $Area2D/SweepAttackAnimator

var can_attack: bool = true
var attack_cooldown: float = 1.0

func _ready() -> void:
	notice_area = %NoticeArea
	behavior.enemy = self
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	move_and_slide()
	handle_collisions()

func attack() -> void:
	if can_attack:
		sweep_attack_animator.play("boss_attack")
		can_attack = false
		
		# Start cooldown timer
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
