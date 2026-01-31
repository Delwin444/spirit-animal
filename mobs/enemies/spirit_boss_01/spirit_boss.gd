extends Enemy

class_name Spirit_Boss

func _ready() -> void:
	notice_area = %NoticeArea
	behavior.enemy = self
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	move_and_slide()
	handle_collisions()
	
