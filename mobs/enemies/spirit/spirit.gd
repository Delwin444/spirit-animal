extends Enemy
class_name Spirit

@onready var visual: Node2D = $Node2D
@onready var tile_map: TileMapLayer = $TileMapLayer

func _ready() -> void:
	notice_area = %NoticeArea
	behavior.enemy = self
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	move_and_slide()
	handle_collisions()
	update_facing_direction()

func update_facing_direction() -> void:
	if velocity.x != 0:
		visual.scale.x = -sign(velocity.x) * abs(visual.scale.x)
