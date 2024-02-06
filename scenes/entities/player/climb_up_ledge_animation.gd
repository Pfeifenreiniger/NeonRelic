extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------METHODS: DO ANIMATION----------###

func climb_up_ledge(direction:String) -> void:
	# tween config
	var tween = get_tree().create_tween()
	var animation_duration:float = 0.9
	
	# player pos offset
	var player_x_offset:float = 15
	var player_y_offset:float = 36
	
	var to_pos_x:float
	if direction == "left":
		to_pos_x = player.global_position.x - player_x_offset
	else:
		to_pos_x = player.global_position.x + player_x_offset
	
	var to_pos_y:float = player.global_position.y - player_y_offset
	
	tween.tween_property(player, "global_position", Vector2(to_pos_x, to_pos_y), animation_duration)
