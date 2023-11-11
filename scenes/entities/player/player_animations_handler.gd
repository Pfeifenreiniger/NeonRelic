extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


func select_animation() -> void:
	player.animations.stop()
	player.animations.play(player.current_animation)
	if player.start_run_animation:
		player.animations.set_frame(4)
		player.start_run_animation = false
	player.animation_to_change = false
	if player.loop_animation:
		player.animation_frames_forwards = true


func climb_up_ledge(direction:String):
	# tween config
	var tween = get_tree().create_tween()
	var animation_duration:float = 0.9
	
	# player pos offset
	var player_x_offset:int = 15
	var player_y_offset:int = 36
	
	var to_pos_x:int
	if direction == "left":
		to_pos_x = player.global_position.x - player_x_offset
	else:
		to_pos_x = player.global_position.x + player_x_offset
	
	var to_pos_y:int = player.global_position.y - player_y_offset
	
	tween.tween_property(player, "global_position", Vector2(to_pos_x, to_pos_y), animation_duration)


func on_animation_finished():
	if player.loop_animation:
		player.animations.stop()
		if player.animation_frames_forwards:
			player.animations.play_backwards(player.current_animation)
			player.animation_frames_forwards = false
		else:
			player.animations.play(player.current_animation)
			player.animation_frames_forwards = true
	
	# to-duck animation is a one-way animation (to ducking-animation or to stand-animation)
	elif player.to_duck:
		player.to_duck = false
		if player.will_duck:
			player.will_duck = false
			player.is_duck = true
			player.resize_hit_box(false, true)
			if "left" in player.current_animation:
				player.current_animation = "duck_left"
			else:
				player.current_animation = "duck_right"
		else:
			if "left" in player.current_animation:
				player.current_animation = "stand_left"
			else:
				player.current_animation = "stand_right"
		
		player.loop_animation = true
		player.animation_to_change = true

	elif player.is_climbing_ledge:
		player.is_climbing_ledge = false
		player.loop_animation = true
		player.animation_to_change = true
		if "left" in player.current_animation:
			player.current_animation = "stand_left"
		else:
			player.current_animation = "stand_right"
		

