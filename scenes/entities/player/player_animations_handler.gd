extends Node
class_name PlayerAnimationsHandler

###----------CUSTOM SIGNALS----------###

signal start_or_end_block_animation(start:bool, side:String, player_is_ducking:bool)
signal change_block_animation_status(status:String, side:String, player_is_ducking:bool)


###----------SCENE REFERENCES----------###

@onready var player:Player = get_tree().get_first_node_in_group('player') as Player


###----------NODE REFERENCES----------###

@onready var climb_up_ledge_animation:Node = $ClimbUpLedgeAnimation as Node
@onready var side_roll_animation:Node = $SideRollAnimation as Node
@onready var whip_attack_charge_shader_animation:Node = $WhipAttackAnimation/WhipAttackChargeShaderAnimation as Node
@onready var sword_attack_animation:Node = $SwordAttackAnimation as Node
@onready var block_animation:Node = $BlockAnimation as Node
@onready var animations:AnimatedSprite2D = $Animations as AnimatedSprite2D


###----------PROPERTIES----------###

var current_animation:String
var animation_to_change:bool = false
var start_run_animation:bool = false
var loop_animation:bool = false
var animation_frames_forwards:bool = true
var injured_animation:bool = false


###----------PROPERTIES: CUSTOM SIGNALS----------###

signal throw_secondary_weapon_frame


###----------METHODS: AT SCENE TREE ENTER CALLED----------###

func _ready() -> void:
	# set up animations
	animations.animation_finished.connect(on_animation_finished)
	animations.frame_changed.connect(on_frame_changed)
	current_animation = "run_right"
	loop_animation = true
	
	await player.ready
	player.health_handler.update_current_player_health_in_percent.connect(_on_update_current_player_health_in_percent)


###----------METHODS: PER FRAME CALLED----------###

func _process(_delta:float) -> void:
	place_animations_sprites_at_players_position()
	_check_if_stand_injured_idle_animation()
	if animation_to_change:
		select_animation()


###----------METHODS----------###

func place_animations_sprites_at_players_position() -> void:
	animations.global_position = player.global_position


func select_animation() -> void:
	animations.stop()
	if injured_animation:
		if "run" in current_animation:
			current_animation = current_animation.replace("run", "walk_injured")
		elif current_animation == "stand_left" || current_animation == 'stand_right':
			current_animation = current_animation.replace("stand", "stand_injured")
	animations.play(current_animation)
	if start_run_animation && !injured_animation:
		animations.set_frame(4)
		start_run_animation = false
	animation_to_change = false
	if loop_animation:
		animation_frames_forwards = true


func _check_if_stand_injured_idle_animation() -> void:
	if injured_animation:
		if current_animation == "stand_left" || current_animation == 'stand_right':
			animation_to_change = true


func _after_attack_change_to_idle_animation(side:String) -> void:
	loop_animation = true
	animation_to_change = true
	player.movement_handler.is_attacking = false
	player.stamina_handler.stamina_can_refresh = true
	if "stand" in current_animation:
		if injured_animation:
			current_animation = "stand_injured_%s" % side
		else:
			current_animation = "stand_%s" % side
	
	else:
		current_animation = "duck_%s" % side
		if !Input.is_action_pressed("down"):
			# BUG: (workaround) simulate duck-input and key-release from player for proper animation
			Input.action_press("down")
			await get_tree().create_timer(0.25).timeout
			Input.action_release("down")


###----------CONNECTED SIGNALS----------###

func _on_update_current_player_health_in_percent(percentage:float) -> void:
	if percentage < Globals.percentage_for_injured:
		injured_animation = true
	else:
		injured_animation = false
		if "walk_injured" in current_animation:
			current_animation = current_animation.replace("walk_injured", "run")
		elif "stand_injured" in current_animation:
			current_animation = current_animation.replace("_injured", '')


func on_animation_finished() -> void:
	if loop_animation:
		animations.stop()
		if injured_animation and "walk_injured" in current_animation:
			animations.play(current_animation)
		elif animation_frames_forwards:
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
			player.weapon_handler.secondary_weapons.adjust_secondary_weapon_start_position('duck')
			if "left" in current_animation:
				current_animation = "duck_left"
			else:
				current_animation = "duck_right"
		else:
			if "left" in current_animation:
				current_animation = "stand_left" if not injured_animation else "stand_injured_left"
			else:
				current_animation = "stand_right" if not injured_animation else "stand_injured_right"
		
		loop_animation = true
		animation_to_change = true

	elif player.movement_handler.is_climbing_ledge:
		player.movement_handler.is_climbing_ledge = false
		loop_animation = true
		animation_to_change = true
		if "left" in current_animation:
			current_animation = "stand_left" if not injured_animation else "stand_injured_left"
		else:
			current_animation = "stand_right" if not injured_animation else "stand_injured_right"
	
	elif player.movement_handler.is_rolling:
		player.movement_handler.is_rolling = false
		player.stamina_handler.stamina_can_refresh = true
		loop_animation = true
		animation_to_change = true
		side_roll_animation.side_roll_tween = null
	
	elif player.movement_handler.is_attacking:
		var side:String = ""
		if "right" in current_animation:
			side = "right"
		else:
			side = "left"
		
		# whip attack
		if "whip_attack" in current_animation:
			if "1" in current_animation:
				if !player.weapon_handler.current_weapon.charges_whip_attack:
					# if charge animation was played -> stop it
					if "stand" in current_animation:
						current_animation = "stand_whip_attack_%s_2" % side
					else:
						current_animation = "duck_whip_attack_%s_2" % side
					animation_to_change = true
					player.weapon_handler.current_weapon.can_whip_attack_charge = false
					player.weapon_handler.current_weapon.reset_whip_attack_damage()
					player.invulnerable_handler.invulnerability_component.become_invulnerable(0.5, false)
					whip_attack_charge_shader_animation.stop_whip_attack_shader_animation()
				else:
					if !whip_attack_charge_shader_animation.do_whip_attack_shader_animation:
						animations.pause()
						whip_attack_charge_shader_animation.start_whip_attack_shader_animation()
			elif "2" in current_animation:
				# play whip attack
				if !player.weapon_handler.current_weapon.do_attack_animation:
					player.weapon_handler.current_weapon.attack_side = side
					player.weapon_handler.current_weapon.visible = true
					player.weapon_handler.current_weapon.set_pos_to_player(side)
					player.weapon_handler.current_weapon.hitbox_zone.reset_hitbox_size()
					player.weapon_handler.current_weapon.play('attack_%s' % side)
					player.weapon_handler.current_weapon.init_attack_animation(side)
				# change to attack 3 animation
				if player.weapon_handler.current_weapon.do_attack_animation\
				&& player.weapon_handler.current_weapon.done_attack_animation:
					player.weapon_handler.current_weapon.finish_attack_animation()
					animation_to_change = true
					if "stand" in current_animation:
						current_animation = "stand_whip_attack_%s_3" % side
					else:
						current_animation = "duck_whip_attack_%s_3" % side
			elif "3" in current_animation:
				# change to idle animation
				player.weapon_handler.current_weapon.can_whip_attack_charge = true
				_after_attack_change_to_idle_animation(side)
				
		elif "sword_attack" in current_animation:
			player.animations_handler.sword_attack_animation.stop_attack()
			for i in 3:
				player.weapon_handler.current_weapon.deactivate_hitbox(i + 1)
			_after_attack_change_to_idle_animation(side)
			
	elif player.movement_handler.is_throwing:
		player.movement_handler.is_throwing = false
		current_animation = current_animation.split('_throw_')[0] + "_" + current_animation.split('_throw_')[1]
		loop_animation = true
		animation_to_change = true
		if "duck" in current_animation && !Input.is_action_pressed("down"):
			# BUG: (workaround) simulate duck-input and key-release from player for proper animation
			Input.action_press("down")
			await get_tree().create_timer(0.25).timeout
			Input.action_release("down")
	
	elif player.movement_handler.is_blocking:
		var side:String = ""
		if "right" in current_animation:
			side = "right"
		else:
			side = "left"
		
		if "go" in current_animation:
			current_animation = current_animation.replace("go", "do")
			loop_animation = true
			animation_to_change = true
			change_block_animation_status.emit("do", side, player.movement_handler.is_duck)
		
		elif "done" in current_animation:
			current_animation = current_animation.replace("_done_block", "")
			loop_animation = true
			animation_to_change = true
			
			var shield_hitbox_name:String = current_animation
			player.block_shield_handler.deactivate_hitbox(shield_hitbox_name)
			
			player.movement_handler.is_blocking = false
			start_or_end_block_animation.emit(false, side, player.movement_handler.is_duck)


func on_frame_changed() -> void:
	# frame index 4 starts actually throw of secondary weapon (e.g. grenade)
	if "throw" in current_animation:
		if animations.frame == 4:
			throw_secondary_weapon_frame.emit()
			
