extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player') as CharacterBody2D


###----------PROPERTIES----------###

@onready var side_roll_tween:Tween
const BASE_PLAYER_X_OFFSET:float = 250
var current_player_x_offset:float = BASE_PLAYER_X_OFFSET
const BASE_ANIMATION_DURATION:float = 0.9
var current_animation_duration:float = BASE_ANIMATION_DURATION


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	check_side_roll_environment_collision()


###----------METHODS----------###

func do_side_roll(direction:String) -> void:
	# tween config
	side_roll_tween = get_tree().create_tween()
	
	var to_pos_x:float
	if direction == "left":
		to_pos_x = player.global_position.x - current_player_x_offset
	else:
		to_pos_x = player.global_position.x + current_player_x_offset

	var to_pos_y:float = player.global_position.y
	
	side_roll_tween.tween_property(player, "global_position", Vector2(to_pos_x, to_pos_y), current_animation_duration)


func check_side_roll_environment_collision() -> void:
	if player.side_collision_boxes_handler.is_environment_collision_left or player.side_collision_boxes_handler.is_environment_collision_right:
		if side_roll_tween != null:
			side_roll_tween.stop()

