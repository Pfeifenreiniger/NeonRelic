extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


func check_player_duck_key_input_status():
	# check if player does not want to duck anymore
	if player.direction.x == 0 and Input.is_action_just_released("ingame_duck"):
		if player.is_duck:
			player.is_duck = false
			player.to_duck = true
			player.resize_hit_box(true, false)

		elif player.to_duck:
			# play remaining to-duck animation backwards
			var last_frame:int = player.animations.frame
			player.animations.stop()
			player.animations.set_frame(last_frame)
		
		player.will_duck = false
		player.loop_animation = false
		
		if "left" in player.current_animation:
			player.current_animation = "to_duck_left"
			player.animations.play_backwards(player.current_animation)
		else:
			player.current_animation = "to_duck_right"
			player.animations.play_backwards(player.current_animation)


func check_if_player_can_horizontally_move() -> bool:
	if not player.to_duck and not player.is_duck and not player.is_jumping and not player.is_falling:
		return true
	else:
		return false


func check_if_player_is_vertically_moving() -> bool:
	if player.is_falling or player.is_jumping:
		return true
	else:
		return false


func check_if_player_is_ducking() -> bool:
	if player.to_duck or player.is_duck:
		return true
	else:
		return false


func move_x() -> void:
	if check_if_player_can_horizontally_move():
		if Input.is_action_pressed("ingame_move_right"):
			player.direction.x = 1
			if player.current_animation != "run_right":
				player.current_animation = "run_right"
				player.animation_to_change = true
				player.loop_animation = true
		elif Input.is_action_pressed("ingame_move_left"):
			player.direction.x = -1
			if player.current_animation != "run_left":
				player.current_animation = "run_left"
				player.animation_to_change = true
				player.loop_animation = true
		else:
			player.direction.x = 0
			if not "stand" in player.current_animation and check_if_player_can_horizontally_move():
				if "right" in player.current_animation:
					player.current_animation = "stand_right"
					player.loop_animation = true
				else:
					player.current_animation = "stand_left"
					player.loop_animation = true
				player.animation_to_change = true
		player.velocity.x = player.direction.x * player.current_speed


func move_y(delta):
	# apply gravity
	if not player.is_on_floor():
		if not check_if_player_is_ducking():
			player.velocity.y += player.current_gravity * delta
		if player.velocity.y > 0:
			if not player.is_falling:
				player.is_jumping = false
				player.is_falling = true
				player.direction.y = 1
				if "left" in player.current_animation:
					player.current_animation = "fall_down_left"
				else:
					player.current_animation = "fall_down_right"
				player.loop_animation = false
				player.animation_to_change = true
	else:
		if player.is_falling:
			player.is_falling = false
			player.direction.y = 0
		# player jumping
		if Input.is_action_pressed("ingame_jump") and not check_if_player_is_ducking():
			if player.direction.y == 0 and not check_if_player_is_vertically_moving():
				player.direction.y = -1
				player.is_jumping = true
				if "left" in player.current_animation:
					player.current_animation = "jump_up_left"
				else:
					player.current_animation = "jump_up_right"
				player.loop_animation = false
				player.animation_to_change = true
				player.velocity.y += player.current_jump_velocity
		# player ducking
		elif Input.is_action_pressed("ingame_duck") and not check_if_player_is_vertically_moving():
			if player.direction.x == 0 and not check_if_player_is_ducking():
				player.to_duck = true
				player.will_duck = true
				if "left" in player.current_animation:
					player.current_animation = "to_duck_left"
				else:
					player.current_animation = "to_duck_right"
				player.loop_animation = false
				player.animation_to_change = true


func move(delta):
	move_x()
	move_y(delta)
	player.move_and_slide()
