extends Node


###----------SCENE REFERENCES----------###

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group('player')


###----------NODE REFERENCES----------###

@onready var climb_up_ledge_animation:Node = $ClimbUpLedgeAnimation
@onready var side_roll_animation:Node = $SideRollAnimation
@onready var whip_attack_charge_shader_animation:Node = $WhipAttackAnimation/WhipAttackChargeShaderAnimation
@onready var animations:AnimatedSprite2D = $Animations


###----------PROPERTIES----------###

var current_animation:String
var animation_to_change:bool = false
var start_run_animation:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true


###----------METHODS: AT INITIATION CALLED----------###

func _ready() -> void:
	# set up animations
	animations.animation_finished.connect(on_animation_finished)
	current_animation = "run_right"
	loop_animation = true


###----------METHODS: PER FRAME CALLED----------###

func _process(delta) -> void:
	place_animations_sprites_at_players_position()
	if animation_to_change:
		select_animation()


###----------METHODS----------###

func place_animations_sprites_at_players_position() -> void:
	animations.global_position = player.global_position


func select_animation() -> void:
	animations.stop()
	animations.play(current_animation)
	if start_run_animation:
		animations.set_frame(4)
		start_run_animation = false
	animation_to_change = false
	if loop_animation:
		animation_frames_forwards = true


###----------CONNECTED SIGNALS----------###

func on_animation_finished() -> void:
	if loop_animation:
		animations.stop()
		if animation_frames_forwards:
			animations.play_backwards(current_animation)
			animation_frames_forwards = false
		else:
			animations.play(current_animation)
			animation_frames_forwards = true
	
	# to-duck animation is a one-way animation (to ducking-animation or to stand-animation)
	elif player.movement_handler.to_duck:
		player.movement_handler.to_duck = false
		if player.movement_handler.will_duck:
			player.movement_handler.will_duck = false
			player.movement_handler.is_duck = true
			player.hitbox_handler.resize_hitbox(false, true)
			if "left" in current_animation:
				current_animation = "duck_left"
			else:
				current_animation = "duck_right"
		else:
			if "left" in current_animation:
				current_animation = "stand_left"
			else:
				current_animation = "stand_right"
		
		loop_animation = true
		animation_to_change = true

	elif player.ledge_climb_handler.is_climbing_ledge:
		player.ledge_climb_handler.is_climbing_ledge = false
		loop_animation = true
		animation_to_change = true
		if "left" in current_animation:
			current_animation = "stand_left"
		else:
			current_animation = "stand_right"
	
	elif player.movement_handler.is_rolling:
		player.movement_handler.is_rolling = false
		player.stamina_handler.stamina_can_refresh = true
		loop_animation = true
		animation_to_change = true
		side_roll_animation.side_roll_tween = null
	
	elif player.movement_handler.is_attacking:
		# whip attack
		if "whip_attack" in current_animation:
			var side = ""
			if "right" in current_animation:
				side = "right"
			else:
				side = "left"
			if "1" in current_animation:
				if not player.weapon_handler.current_weapon.charges_whip_attack:
					# ToDo: if charge animation was played -> stop it
					current_animation = "stand_whip_attack_%s_2" % side
					animation_to_change = true
					player.weapon_handler.current_weapon.can_whip_attack_charge = false
					player.weapon_handler.current_weapon.reset_whip_attack_damage()
					player.invulnerable_handler.become_invulnerable(0.5, false)
					whip_attack_charge_shader_animation.stop_whip_attack_shader_animation()
				else:
					if not whip_attack_charge_shader_animation.do_whip_attack_shader_animation:
						animations.pause()
						whip_attack_charge_shader_animation.start_whip_attack_shader_animation()
			elif "2" in current_animation:
				# play whip attack
				if not player.weapon_handler.current_weapon.do_attack_animation:
					player.weapon_handler.current_weapon.attack_side = side
					player.weapon_handler.current_weapon.visible = true
					player.weapon_handler.current_weapon.set_pos_to_player(side)
					player.weapon_handler.current_weapon.hitbox_zone.reset_hitbox_size()
					player.weapon_handler.current_weapon.play('attack_%s' % side)
					player.weapon_handler.current_weapon.init_attack_animation(side)
				# change to attack 3 animation
				if player.weapon_handler.current_weapon.do_attack_animation and player.weapon_handler.current_weapon.done_attack_animation:
					player.weapon_handler.current_weapon.finish_attack_animation()
					animation_to_change = true
					current_animation = "stand_whip_attack_%s_3" % side
			elif "3" in current_animation:
				# change to stand animation
				loop_animation = true
				animation_to_change = true
				current_animation = "stand_%s" % side
				player.movement_handler.is_attacking = false
				player.weapon_handler.current_weapon.can_whip_attack_charge = true
				player.stamina_handler.stamina_can_refresh = true
