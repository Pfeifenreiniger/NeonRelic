extends Area2D


###----------PROPERTIES----------###

@export_enum("left", "right") var border_side:String


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


###----------METHODS: CONNECTED SIGNALS----------###

func _on_body_entered(body:Node2D) -> void:
	if "IS_ENEMY" in body:
		body.movement_handler.direction.x = 0
		body.is_at_platform_border = true
		if body.x_axis_direction == "left" && border_side == "left":
			body.x_axis_direction = "right"
		elif body.x_axis_direction == "right" && border_side == "right":
			body.x_axis_direction = "left"


func _on_body_exited(body:Node2D) -> void:
	if "IS_ENEMY" in body:
		body.is_at_platform_border = false
