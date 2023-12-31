extends Node

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')
@onready var climb_up_ledge_animation:Node = $ClimbUpLedgeAnimation
@onready var side_roll_animation:Node = $SideRollAnimation
@onready var whip_attack_charge_shader_animation:Node = $WhipAttackAnimation/WhipAttackChargeShaderAnimation


func select_animation() -> void:
	player.animations.stop()
	player.animations.play(player.current_animation)
	if player.start_run_animation:
		player.animations.set_frame(4)
		player.start_run_animation = false
	player.animation_to_change = false
	if player.loop_animation:
		player.animation_frames_forwards = true


func climb_up_ledge(direction:String) -> void:
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


###----------CONNECTED SIGNALS----------###

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
			player.hitbox_handler.resize_hitbox(false, true)
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

	elif player.ledge_climb_handler.is_climbing_ledge:
		player.ledge_climb_handler.is_climbing_ledge = false
		player.loop_animation = true
		player.animation_to_change = true
		if "left" in player.current_animation:
			player.current_animation = "stand_left"
		else:
			player.current_animation = "stand_right"
	
	elif player.is_rolling:
		player.is_rolling = false
		player.stamina_handler.stamina_can_refresh = true
		player.loop_animation = true
		player.animation_to_change = true
		player.animations_handler.side_roll_animation.side_roll_tween = null
	
	elif player.is_attacking:
		# whip attack
		if "whip_attack" in player.current_animation:
			var side = ""
			if "right" in player.current_animation:
				side = "right"
			else:
				side = "left"
			if "1" in player.current_animation:
				if not player.weapon_handler.current_weapon.charges_whip_attack:
					# ToDo: if charge animation was played -> stop it
					player.current_animation = "stand_whip_attack_%s_2" % side
					player.animation_to_change = true
					player.can_whip_attack_charge = false
					player.weapon_handler.current_weapon.reset_whip_attack_damage()
					player.invulnerable_handler.become_invulnerable(0.5, false)
					whip_attack_charge_shader_animation.stop_whip_attack_shader_animation()
				else:
					if not whip_attack_charge_shader_animation.do_whip_attack_shader_animation:
						player.animations.pause()
						whip_attack_charge_shader_animation.start_whip_attack_shader_animation()
			elif "2" in player.current_animation:
				# play whip attack
				if not player.weapon_handler.current_weapon.do_attack_animation:
					player.weapon_handler.current_weapon.attack_side = side
					player.weapon_handler.current_weapon.visible = true
					player.weapon_handler.current_weapon.set_pos_to_player(side)
					player.weapon_handler.current_weapon.reset_hitbox_size()
					player.weapon_handler.current_weapon.play('attack_%s' % side)
					player.weapon_handler.current_weapon.init_attack_animation(side)
				# change to attack 3 animation
				if player.weapon_handler.current_weapon.do_attack_animation and player.weapon_handler.current_weapon.done_attack_animation:
					player.weapon_handler.current_weapon.finish_attack_animation()
					player.animation_to_change = true
					player.current_animation = "stand_whip_attack_%s_3" % side
			elif "3" in player.current_animation:
				# change to stand animation
				player.loop_animation = true
				player.animation_to_change = true
				player.current_animation = "stand_%s" % side
				player.is_attacking = false
				player.can_whip_attack_charge = true
				player.stamina_handler.stamina_can_refresh = true
