extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var ingame_camera:Camera2D = get_tree().get_first_node_in_group('ingame_camera')

# button press timers
@onready var jump_button_press_timer:Timer = $ButtonPressTimers/JumpButtonPressTimer

var player_roll_action_inputs = {
	"right" : 0,
	"left" : 0
}


func _ready():
	jump_button_press_timer.timeout.connect(on_jump_button_press_timer_timeout)


func move_x() -> void:
	if check_if_player_can_horizontally_move():
		# run right / left or stand idle
		if Input.is_action_pressed("ingame_move_right"):
			player.direction.x = 1
			if player.current_animation != "run_right":
				player.current_animation = "run_right"
				player.animation_to_change = true
				player.loop_animation = true
				player.start_run_animation = true
		elif Input.is_action_pressed("ingame_move_left"):
			player.direction.x = -1
			if player.current_animation != "run_left":
				player.current_animation = "run_left"
				player.animation_to_change = true
				player.loop_animation = true
				player.start_run_animation = true
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

		# check roll-action to right / left
		if Input.is_action_just_released("ingame_move_right"):
			var button_move_right_press_timestamp = Time.get_ticks_msec() / 10
			if not player.is_rolling:
				if button_move_right_press_timestamp - player_roll_action_inputs["right"] <= 50:
					player.current_animation = "roll_right"
					player.loop_animation = false
					player.animation_to_change = true
					player.is_rolling = true
					player.animations_handler.do_side_roll("right")
				else:
					player_roll_action_inputs["right"] = button_move_right_press_timestamp
		elif Input.is_action_just_released("ingame_move_left"):
			var button_move_left_press_timestamp = Time.get_ticks_msec() / 10
			if not player.is_rolling:
				if button_move_left_press_timestamp - player_roll_action_inputs["left"] <= 50:
					player.current_animation = "roll_left"
					player.loop_animation = false
					player.animation_to_change = true
					player.is_rolling = true
					player.is_rolling = true
					player.animations_handler.do_side_roll("left")
				else:
					player_roll_action_inputs["left"] = button_move_left_press_timestamp

		player.velocity.x = player.direction.x * player.current_speed


func move_y(delta):
	if not player.is_on_floor(): # player not on ground
		# apply gravity when player is not ducking or climbing a ledge
		if not check_if_player_is_ducking() and not player.is_climbing_ledge:
			player.velocity.y += player.current_gravity * delta
		
		# checks if jump button was released (-> short jump)
		if Input.is_action_just_released("ingame_jump") and player.is_jumping:
			if not jump_button_press_timer.is_stopped():
				jump_button_press_timer.stop()
		
		# if gravity influenced player's physic -> check if he is falling
		if player.velocity.y > 0  and not player.is_climbing_ledge:
			if not player.is_falling:
				player.is_jumping = false
				player.is_rolling = false
				if player.animations_handler.side_roll_tween != null:
					player.animations_handler.side_roll_tween.stop()
				player.is_falling = true
				player.direction.y = 1
				if "left" in player.current_animation:
					player.current_animation = "fall_down_left"
				else:
					player.current_animation = "fall_down_right"
				player.loop_animation = false
				player.animation_to_change = true
	else: # player on ground
		if player.is_falling:
			player.is_falling = false
			player.direction.y = 0
		# ground-y-movement only possible when player's not currently climbing up a ledge, is attacking or is rolling
		if not player.is_climbing_ledge and not player.is_attacking and not player.is_rolling:
			# player jumping
			if Input.is_action_pressed("ingame_jump") and not check_if_player_is_ducking():
				action_input_jump()
			# player ducking
			elif Input.is_action_pressed("ingame_duck") and not check_if_player_is_vertically_moving():
				action_input_duck()


func move(delta):
	player.move_and_slide()


func check_ingame_control_key_inputs(delta):
	check_input_climb_up_ledge()
	check_input_whip_attack()
	move_x()
	move_y(delta)
	move(delta)


func check_if_player_can_horizontally_move() -> bool:
	if not player.to_duck and not player.is_duck and not player.is_jumping and not player.is_falling and not player.is_climbing_ledge and not player.is_attacking and not player.is_rolling:
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
		ingame_camera.desc_camera_y_axis = false
		ingame_camera.asc_camera_y_axis = true
		
		if "left" in player.current_animation:
			player.current_animation = "to_duck_left"
			player.animations.play_backwards(player.current_animation)
		else:
			player.current_animation = "to_duck_right"
			player.animations.play_backwards(player.current_animation)


func action_input_duck():
	if player.direction.x == 0 and not check_if_player_is_ducking():
		player.to_duck = true
		player.will_duck = true
		if "left" in player.current_animation:
			player.current_animation = "to_duck_left"
		else:
			player.current_animation = "to_duck_right"
		player.loop_animation = false
		player.animation_to_change = true
		ingame_camera.asc_camera_y_axis = false
		ingame_camera.desc_camera_y_axis = true


func action_input_jump():
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
		jump_button_press_timer.start()


func check_input_climb_up_ledge():
	if Input.is_action_pressed("ingame_climb_up_ledge"):
		action_input_climb_up_ledge()


func action_input_climb_up_ledge():
	# if player is currently in an ledge area -> can climb up (if player is facing correct ledge side)
	if player.current_ledge_to_climb_area != null:
		if player.ledge_climb_area.overlaps_area(player.current_ledge_to_climb_area):
			if not player.is_climbing_ledge and check_if_ledge_side_fits(player.current_ledge_to_climb_area):
				player.is_jumping = false
				player.is_falling = false
				player.is_climbing_ledge = true
				player.direction.y = 0
				player.velocity.y = 0
				player.animation_to_change = true
				player.loop_animation = false
				if "right" in player.current_animation:
					player.current_animation = "climb_up_ledge_right"
					player.animations_handler.climb_up_ledge("right")
				else:
					player.current_animation = "climb_up_ledge_left"
					player.animations_handler.climb_up_ledge("left")


func check_if_ledge_side_fits(ledge_area:Area2D) -> bool:
	if ("right" in player.current_animation and ledge_area.ledge_side == "left") or ("left" in player.current_animation and ledge_area.ledge_side == "right"):
		return true
	else:
		return false


func check_input_whip_attack():
	if Input.is_action_pressed("ingame_whip_attack"):
		if not player.is_attacking:
			# initial input
			action_input_init_whip_attack()
			player.weapon_handler.select_current_weapon("whip")
		else:
			if not player.weapon_handler.current_weapon.charges_whip_attack and player.can_whip_attack_charge:
				player.weapon_handler.current_weapon.charges_whip_attack = true
				player.can_whip_attack_charge = false
	else:
		if player.weapon_handler.current_weapon != null and 'IS_WHIP' in player.weapon_handler.current_weapon:
			if player.weapon_handler.current_weapon.charges_whip_attack:
				player.weapon_handler.current_weapon.charges_whip_attack = false
				player.can_whip_attack_charge = false


func action_input_init_whip_attack():
	if player.is_duck:
		pass
		# ToDo: implement player ducking whip attacks
	else:
		# do standing whip attack if player's on ground
		if check_if_player_can_horizontally_move():
			if not player.is_attacking:
				player.can_whip_attack_charge = true
				player.direction.x = 0
				player.velocity.x = 0
				player.is_attacking = true
				player.loop_animation = false
				player.animation_to_change = true
				if "right" in player.current_animation:
					player.current_animation = "stand_whip_attack_right_1"
				else:
					player.current_animation = "stand_whip_attack_left_1"


###----------CONNECTED SIGNALS----------###

func on_jump_button_press_timer_timeout():
	var current_large_jump_velocity_addition:int = int(abs(player.current_jump_velocity) * player.LARGE_JUMP_VELOCITY_ADDITION_MULTIPLIER)
	player.velocity.y -= current_large_jump_velocity_addition
