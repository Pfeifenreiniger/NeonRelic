extends Sprite2D


###----------NODE REFERENCES----------###

@onready var hit_area:Area2D = $HitArea as Area2D


###----------PROPERTIES----------###

var start_position:Vector2
var target_position:Vector2
var direction:Vector2 = Vector2.ZERO
var can_move:bool = false
var move_speed:int = 500


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	_init_laser_timeout()


###----------METHODS: PER FRAME CALLED----------###

func _process(delta:float) -> void:
	move(delta)


###----------METHODS----------###

func _init_laser_timeout() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()


func shot(drone_position:Vector2, player_position:Vector2) -> void:
	start_position = drone_position
	target_position = player_position
	direction = (target_position - start_position).normalized()
	rotation_degrees = rad_to_deg(direction.angle())
	can_move = true


func move(delta:float) -> void:
	if can_move:
		position += direction * move_speed * delta


###----------METHODS: CONNECTED SIGNALS----------###

func _on_hit_area_body_entered(body:Node2D) -> void:
	if "IS_PLAYER" in body:
		body.health_handler.get_damage(5)
		queue_free()
